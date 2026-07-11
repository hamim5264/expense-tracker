import 'package:expense_tracker/features/auth/data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracker/core/error/failure.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;

  Future<String> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  });

  Future<String> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<String> signInWithGoogle();

  Future<void> logout();

  Future<UserModel?> getCurrentUserData();

  Future<UserModel> updateUserProfile({
    required String name,
    required String? username,
    required String? avatarUrl,
    String? currency,
    bool? smsSyncEnabled,
  });

  Future<void> updatePassword(String newPassword);

  Future<String> getSecurityQuestion(String email);

  Future<bool> resetPassword({
    required String email,
    required String answer,
    required String newPassword,
  });

  Future<void> deleteAccount();

  Future<UserModel> updateSecurityQuestionAnswer({
    required String securityQuestion,
    required String securityAnswer,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl(this.supabaseClient, this.googleSignIn);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<String> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw Failure('User is null!');
      }
      return response.user!.id;
    } on AuthException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<String> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'name': name,
          'security_question': securityQuestion,
          'security_answer': securityAnswer,
        },
      );
      if (response.user == null) {
        throw Failure('User is null!');
      }
      return response.user!.id;
    } on AuthException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<String> signInWithGoogle() async {
    try {
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Failure('Google Sign-In cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Failure('Google Sign-In failed: ID Token is null.');
      }

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Failure('User is null!');
      }

      return response.user!.id;
    } on AuthException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await googleSignIn.signOut();
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession == null) return null;

      final userData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', currentUserSession!.user.id)
          .single();

      return UserModel.fromJson(
        userData,
      ).copyWith(email: currentUserSession!.user.email);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String name,
    required String? username,
    required String? avatarUrl,
    String? currency,
    bool? smsSyncEnabled,
  }) async {
    try {
      if (currentUserSession == null) throw Failure('User not logged in!');

      final updateMap = <String, dynamic>{
        'full_name': name,
        'username': username,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (currency != null) {
        updateMap['currency'] = currency;
      }
      if (smsSyncEnabled != null) {
        updateMap['sms_sync_enabled'] = smsSyncEnabled;
      }

      final response = await supabaseClient
          .from('profiles')
          .update(updateMap)
          .eq('id', currentUserSession!.user.id)
          .select()
          .single();

      return UserModel.fromJson(
        response,
      ).copyWith(email: currentUserSession!.user.email);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Failure('Username is already taken!');
      }
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<String> getSecurityQuestion(String email) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select('security_question')
          .eq('email', email)
          .single();

      final question = response['security_question'];
      if (question == null || (question as String).trim().isEmpty) {
        throw Failure('Security question is not set for this account.');
      }
      return question;
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Error: ${e.toString()}');
    }
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String answer,
    required String newPassword,
  }) async {
    try {
      final result = await supabaseClient.rpc(
        'reset_password_with_answer',
        params: {
          'target_email': email,
          'provided_answer': answer,
          'new_password': newPassword,
        },
      );
      return result as bool;
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await supabaseClient.rpc('delete_user_account');
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<UserModel> updateSecurityQuestionAnswer({
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      if (currentUserSession == null) throw Failure('User not logged in!');

      final response = await supabaseClient
          .from('profiles')
          .update({
            'security_question': securityQuestion,
            'security_answer': securityAnswer,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUserSession!.user.id)
          .select()
          .single();

      return UserModel.fromJson(
        response,
      ).copyWith(email: currentUserSession!.user.email);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }
}
