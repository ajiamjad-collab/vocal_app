import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class ReloadUser {
  final AuthRepository repo;
  ReloadUser(this.repo);

  Future<AppUser?> call() => repo.reloadUser();
}
