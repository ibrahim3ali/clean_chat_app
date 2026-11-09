import '../../../../features.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;
  const GetCurrentUserUseCase(this.repository);

  UserEntity? call() {
    return repository.getCurrentUser();
  }
}
