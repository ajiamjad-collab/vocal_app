import '../repositories/auth_repository.dart';

class Reauthenticate {
  final AuthRepository repo;
  Reauthenticate(this.repo);

  Future<void> call(String email, String password) {
    return repo.reauthenticateWithPassword(email, password);
  }
}
