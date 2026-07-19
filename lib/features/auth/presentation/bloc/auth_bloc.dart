import 'package:expense_tracker/features/auth/domain/usecases/delete_account.dart';
import 'package:expense_tracker/features/auth/domain/usecases/update_security_question.dart';
import 'package:expense_tracker/features/auth/domain/usecases/current_user.dart';
import 'package:expense_tracker/features/auth/domain/usecases/get_security_question.dart';
import 'package:expense_tracker/features/auth/domain/usecases/reset_password.dart';
import 'package:expense_tracker/features/auth/domain/usecases/update_password.dart';
import 'package:expense_tracker/features/auth/domain/usecases/update_user_profile.dart';
import 'package:expense_tracker/features/auth/domain/usecases/user_login.dart';
import 'package:expense_tracker/features/auth/domain/usecases/user_logout.dart';
import 'package:expense_tracker/features/auth/domain/usecases/user_sign_in_google.dart';
import 'package:expense_tracker/features/auth/domain/usecases/user_sign_in_facebook.dart';
import 'package:expense_tracker/features/auth/domain/usecases/user_sign_up.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as sf;
import 'package:expense_tracker/core/usecase/usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp userSignUp;
  final UserLogin userLogin;
  final UserSignInGoogle userSignInGoogle;
  final UserSignInFacebook userSignInFacebook;
  final UserLogout userLogout;
  final GetSecurityQuestion getSecurityQuestion;
  final ResetPassword resetPassword;
  final CurrentUser currentUser;
  final UpdateUserProfile updateUserProfile;
  final UpdatePassword updatePassword;
  final DeleteAccount deleteAccount;
  final UpdateSecurityQuestion updateSecurityQuestion;
  StreamSubscription<sf.AuthState>? _authStateSubscription;

  AuthBloc({
    required this.userSignUp,
    required this.userLogin,
    required this.userSignInGoogle,
    required this.userSignInFacebook,
    required this.userLogout,
    required this.getSecurityQuestion,
    required this.resetPassword,
    required this.currentUser,
    required this.updateUserProfile,
    required this.updatePassword,
    required this.deleteAccount,
    required this.updateSecurityQuestion,
  }) : super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthGoogleSignIn>(_onAuthGoogleSignIn);
    on<AuthFacebookSignIn>(_onAuthFacebookSignIn);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogout>(_onAuthLogout);
    on<AuthForgotPasswordFetchQuestion>(_onFetchQuestion);
    on<AuthResetPassword>(_onResetPassword);
    on<AuthUpdateUserProfile>(_onUpdateUserProfile);
    on<AuthUpdatePassword>(_onUpdatePassword);
    on<AuthDeleteAccount>(_onAuthDeleteAccount);
    on<AuthUpdateSecurityQuestionAnswer>(_onAuthUpdateSecurityQuestionAnswer);
    on<AuthSessionChanged>((event, emit) => emit(AuthSuccess(event.user)));
    on<AuthSessionFailure>((event, emit) => emit(AuthFailure(event.message)));

    _authStateSubscription = sf.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) async {
          if (data.event == sf.AuthChangeEvent.signedIn &&
              data.session != null) {
            final res = await currentUser(NoParams());
            res.fold(
              (l) => add(AuthSessionFailure(l.message)),
              (r) => add(AuthSessionChanged(r)),
            );
          }
        });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await currentUser(NoParams());

    res.fold((l) => emit(AuthInitial()), (r) => emit(AuthSuccess(r)));
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await userSignUp(
      UserSignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
        securityQuestion: event.securityQuestion,
        securityAnswer: event.securityAnswer,
      ),
    );

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await userLogin(
      UserLoginParams(email: event.email, password: event.password),
    );

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }

  void _onAuthGoogleSignIn(
    AuthGoogleSignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await userSignInGoogle(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }

  void _onAuthFacebookSignIn(
    AuthFacebookSignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await userSignInFacebook(NoParams());

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (
        _,
      ) {}, // Do nothing on success; wait for the onAuthStateChange stream to handle redirection
    );
  }

  void _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await userLogout(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthInitial()));
  }

  void _onFetchQuestion(
    AuthForgotPasswordFetchQuestion event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await getSecurityQuestion(event.email);

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => emit(AuthQuestionLoaded(r)),
    );
  }

  void _onResetPassword(
    AuthResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await resetPassword(
      ResetPasswordParams(
        email: event.email,
        answer: event.answer,
        newPassword: event.newPassword,
      ),
    );

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => emit(AuthPasswordResetSuccess()),
    );
  }

  void _onUpdateUserProfile(
    AuthUpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await updateUserProfile(
      UpdateUserProfileParams(
        name: event.name,
        username: event.username,
        avatarUrl: event.avatarUrl,
        currency: event.currency,
        smsSyncEnabled: event.smsSyncEnabled,
      ),
    );

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }

  void _onUpdatePassword(
    AuthUpdatePassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await updatePassword(event.password);

    if (res.isLeft()) {
      res.fold((l) => emit(AuthFailure(l.message)), (_) {});
      return;
    }

    if (event.stayLoggedIn) {
      final userRes = await currentUser(NoParams());
      userRes.fold(
        (l) => emit(AuthFailure(l.message)),
        (r) => emit(AuthSuccess(r)),
      );
    } else {
      await userLogout(NoParams());
      emit(AuthInitial());
    }
  }

  void _onAuthDeleteAccount(
    AuthDeleteAccount event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await deleteAccount(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthInitial()));
  }

  void _onAuthUpdateSecurityQuestionAnswer(
    AuthUpdateSecurityQuestionAnswer event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await updateSecurityQuestion(
      UpdateSecurityQuestionParams(
        securityQuestion: event.securityQuestion,
        securityAnswer: event.securityAnswer,
      ),
    );

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }
}
