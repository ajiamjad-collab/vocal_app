import '../repositories/user_profile_repository.dart';

class CreateUserProfile {
  final UserProfileRepository repo;
  CreateUserProfile(this.repo);

  Future<String> call({
    required String firstName,
    required String lastName,
  }) {
    return repo.createUserProfile(firstName: firstName, lastName: lastName);
  }

  Future<void> ensureForGoogle({
    required String fallbackFirstName,
    required String fallbackLastName,
  }) {
    return repo.ensureProfileExistsForGoogleUser(
      fallbackFirstName: fallbackFirstName,
      fallbackLastName: fallbackLastName,
    );
  }
}
