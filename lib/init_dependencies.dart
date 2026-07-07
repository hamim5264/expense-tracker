import 'package:expense_tracker/features/auth/domain/usecases/get_security_question.dart';
import 'package:expense_tracker/features/auth/domain/usecases/reset_password.dart';
import 'package:expense_tracker/features/auth/domain/usecases/user_login.dart';
import 'package:expense_tracker/features/auth/domain/usecases/user_logout.dart';
import 'package:expense_tracker/features/auth/domain/usecases/user_sign_in_google.dart';
import 'package:expense_tracker/features/auth/domain/usecases/user_sign_up.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/app_config.dart';
import 'package:get_it/get_it.dart';
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

  serviceLocator.registerLazySingleton(() => Dio());

  _initAuth();
  _initExpense();
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
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
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        userSignInGoogle: serviceLocator(),
        userLogout: serviceLocator(),
        getSecurityQuestion: serviceLocator(),
        resetPassword: serviceLocator(),
      ),
    );
}

void _initExpense() {}
