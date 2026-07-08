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
import 'package:expense_tracker/features/auth/domain/usecases/user_sign_up.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/expense/data/datasources/expense_remote_data_source.dart';
import 'package:expense_tracker/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expense/domain/usecases/get_all_expenses.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/app_config.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await Hive.initFlutter();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  serviceLocator.registerLazySingleton(() => Supabase.instance.client);

  serviceLocator.registerLazySingleton(
    () => GoogleSignIn(serverClientId: AppConfig.googleWebClientId),
  );

  serviceLocator.registerLazySingleton(() => Dio());

  _initAuth();
  _initExpense();
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator(), serviceLocator()),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => UserSignInGoogle(serviceLocator()))
    ..registerFactory(() => UserLogout(serviceLocator()))
    ..registerFactory(() => GetSecurityQuestion(serviceLocator()))
    ..registerFactory(() => ResetPassword(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    ..registerFactory(() => UpdateUserProfile(serviceLocator()))
    ..registerFactory(() => UpdatePassword(serviceLocator()))
    ..registerFactory(() => DeleteAccount(serviceLocator()))
    ..registerFactory(() => UpdateSecurityQuestion(serviceLocator()))
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        userSignInGoogle: serviceLocator(),
        userLogout: serviceLocator(),
        getSecurityQuestion: serviceLocator(),
        resetPassword: serviceLocator(),
        currentUser: serviceLocator(),
        updateUserProfile: serviceLocator(),
        updatePassword: serviceLocator(),
        deleteAccount: serviceLocator(),
        updateSecurityQuestion: serviceLocator(),
      ),
    );
}

void _initExpense() {
  serviceLocator
    ..registerFactory<ExpenseRemoteDataSource>(
      () => ExpenseRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<ExpenseRepository>(
      () => ExpenseRepositoryImpl(serviceLocator()),
    )
    ..registerFactory(() => GetAllExpenses(serviceLocator()))
    ..registerLazySingleton(
      () => ExpenseBloc(getAllExpenses: serviceLocator()),
    );
}
