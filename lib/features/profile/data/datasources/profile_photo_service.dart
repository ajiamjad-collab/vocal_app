/*import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ProfilePhotoService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;

  static const String publicProfileCollection = 'Personal';

  ProfilePhotoService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
    FirebaseStorage? storage,
    FirebaseFunctions? functions,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  Future<String> uploadProfilePhoto(File file) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Not signed in");

    // ✅ correct: Users (capital U)
    final usersDoc = await _db.collection('Users').doc(uid).get();
    if (!usersDoc.exists) throw Exception("Users/$uid not found");

    final publicUserId = (usersDoc.data()?['publicUserId'] ?? '').toString().trim();
    if (publicUserId.isEmpty) throw Exception("publicUserId missing in Users/$uid");

    // ✅ Upload to: Personal/{publicUserId}/Profile/profile.jpg
    final ref = _storage.ref().child('$publicProfileCollection/$publicUserId/Profile/profile.jpg');

    final meta = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'uid': uid, 'publicUserId': publicUserId},
    );

    final snap = await ref.putFile(file, meta);
    final url = await snap.ref.getDownloadURL();

    // ✅ Write URL via Cloud Function (server writes Firestore)
    final callable = _functions.httpsCallable('setMyProfilePhotoUrl');
    await callable.call(<String, dynamic>{'photoUrl': url});

    return url;
  }
}
*/
