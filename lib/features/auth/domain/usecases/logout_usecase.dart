import '../../../../features.dart';

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}
