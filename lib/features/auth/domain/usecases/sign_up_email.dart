import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUpEmail {
  final AuthRepository repo;
  SignUpEmail(this.repo);

  Future<AppUser> call(String email, String password) {
    return repo.signUpEmail(email, password);
  }
}
