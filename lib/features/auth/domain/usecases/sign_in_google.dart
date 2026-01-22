import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInGoogle {
  final AuthRepository repo;
  SignInGoogle(this.repo);

  Future<AppUser> call({required bool rememberMe}) {
    return repo.signInGoogle(rememberMe: rememberMe);
  }
}
