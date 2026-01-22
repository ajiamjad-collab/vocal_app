import 'package:vocal_app/core/errors/error_mapper.dart';
import 'package:vocal_app/features/profile/data/datasources/user_profile_remote_ds.dart';
import 'user_profile_repository.dart';


class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remote;
  UserProfileRepositoryImpl({required this.remote});

  @override
  Future<String> createUserProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      return await remote.createUserProfile(firstName: firstName, lastName: lastName);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> ensureProfileExistsForGoogleUser({
    required String fallbackFirstName,
    required String fallbackLastName,
  }) async {
    try {
      await remote.ensureProfileExistsForGoogleUser(
        fallbackFirstName: fallbackFirstName,
        fallbackLastName: fallbackLastName,
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
