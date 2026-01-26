/*import '../repositories/user_profile_repository.dart';

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
*/

import 'dart:async';

import '../repositories/user_profile_repository.dart';
import '../../data/datasources/user_profile_remote_ds.dart';

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

  // ✅ NEW (optional use from UI)
  Stream<PublicUserProfile> watchMyPublicProfile() => repo.watchMyPublicProfile();
  Future<void> updateMyName({required String firstName, required String lastName}) =>
      repo.updateMyName(firstName: firstName, lastName: lastName);
  Future<void> setMyProfilePhotoUrl({required String photoUrl}) =>
      repo.setMyProfilePhotoUrl(photoUrl: photoUrl);
}
