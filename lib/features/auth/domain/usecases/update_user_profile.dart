import 'package:expense_tracker/core/common/entities/user.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateUserProfile implements UseCase<User, UpdateUserProfileParams> {
  final AuthRepository authRepository;

  UpdateUserProfile(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UpdateUserProfileParams params) async {
    return await authRepository.updateUserProfile(
      name: params.name,
      username: params.username,
      avatarUrl: params.avatarUrl,
      currency: params.currency,
      smsSyncEnabled: params.smsSyncEnabled,
    );
  }
}

class UpdateUserProfileParams {
  final String name;
  final String? username;
  final String? avatarUrl;
  final String? currency;
  final bool? smsSyncEnabled;

  UpdateUserProfileParams({
    required this.name,
    this.username,
    this.avatarUrl,
    this.currency,
    this.smsSyncEnabled,
  });
}
