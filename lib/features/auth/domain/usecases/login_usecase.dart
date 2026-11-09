import '../../../../features.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<UserEntity> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}
