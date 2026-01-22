import '../repositories/auth_repository.dart';

class SendVerification {
  final AuthRepository repo;
  SendVerification(this.repo);

  Future<void> call() => repo.sendEmailVerification();
}
