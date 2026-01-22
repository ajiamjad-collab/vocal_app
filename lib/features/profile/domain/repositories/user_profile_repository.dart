abstract class UserProfileRepository {
  Future<String> createUserProfile({
    required String firstName,
    required String lastName,
  });

  Future<void> ensureProfileExistsForGoogleUser({
    required String fallbackFirstName,
    required String fallbackLastName,
  });
}
