import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInEmail {
  final AuthRepository repo;
  SignInEmail(this.repo);

  Future<AppUser> call(String email, String password, {required bool rememberMe}) {
    return repo.signInEmail(email, password, rememberMe: rememberMe);
  }
}
