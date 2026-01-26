/*abstract class UserProfileRepository {
  Future<String> createUserProfile({
    required String firstName,
    required String lastName,
  });

  Future<void> ensureProfileExistsForGoogleUser({
    required String fallbackFirstName,
    required String fallbackLastName,
  });
}
*/

import 'dart:async';
import '../../data/datasources/user_profile_remote_ds.dart';

abstract class UserProfileRepository {
  Future<String> createUserProfile({
    required String firstName,
    required String lastName,
  });

  Future<void> ensureProfileExistsForGoogleUser({
    required String fallbackFirstName,
    required String fallbackLastName,
  });

  // ✅ NEW
  Stream<PublicUserProfile> watchMyPublicProfile();
  Future<void> updateMyName({required String firstName, required String lastName});
  Future<void> setMyProfilePhotoUrl({required String photoUrl});
}
