import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:vocal_app/features/profile/data/datasources/user_profile_remote_ds.dart';
// ✅ reuse your existing crop/compress flow
import 'package:vocal_app/core/media/helpers/image_helper.dart';
import 'package:vocal_app/core/media/rules/image_rules.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final _auth = GetIt.I<FirebaseAuth>();
  final _storage = GetIt.I<FirebaseStorage>();
  final _db = GetIt.I<FirebaseFirestore>();

  final _remote = GetIt.I<UserProfileRemoteDataSource>();

  // ✅ CHANGED
  static const String publicProfileCollection = "Personal";

  Stream<PublicUserProfile>? _stream;

  @override
  void initState() {
    super.initState();
    _stream = _remote.watchMyPublicProfile();
  }

  Future<void> _editName(PublicUserProfile p) async {
    final firstCtrl = TextEditingController(text: p.firstName);
    final lastCtrl = TextEditingController(text: p.lastName);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit name"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstCtrl,
              decoration: const InputDecoration(labelText: "First name"),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastCtrl,
              decoration: const InputDecoration(labelText: "Second name"),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final first = firstCtrl.text.trim();
    final last = lastCtrl.text.trim();
    if (first.isEmpty || last.isEmpty) {
      _toast("First + Second name required");
      return;
    }

    await _guard(() async {
      await _remote.updateMyName(firstName: first, lastName: last);
      _toast("Name updated");
    });
  }

  // ============================
  // ✅ Upload profile photo
  // ============================
  Future<void> _changePhoto(PublicUserProfile p) async {
    final source = await showModalBottomSheet<_PickSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () => Navigator.pop(context, _PickSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Camera"),
              onTap: () => Navigator.pop(context, _PickSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    await _guard(() async {
      // ✅ Pick + Crop(1:1) + Compress
      final media = await ImageHelper.pickProcessSingle(
        getContext: () => mounted ? context : null,
        useCase: ImageUseCase.profile,
        fromCamera: source == _PickSource.camera,
      );

      if (media == null) return;

      final file = File(media.xfile.path);

      // ✅ MUST be signed in
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception("Not signed in");
      }

      // ✅ Read publicUserId from users/{uid}
      final usersDoc = await _db.collection('Users').doc(uid).get();
      if (!usersDoc.exists) {
        throw Exception("Users/$uid not found. Call createUserProfile first.");
      }

      final publicUserId = (usersDoc.data()?['publicUserId'] ?? '').toString().trim();
      if (publicUserId.isEmpty) {
        throw Exception("publicUserId missing in Users/$uid");
      }

      // ✅ 5MB check (matches rules)
      final bytes = await file.length();
      if (bytes > 5 * 1024 * 1024) {
        throw Exception(
          "Image too large (>5MB). Current: ${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB",
        );
      }


     // 🔍 Detect actual file extension
final ext = path.extension(file.path).toLowerCase(); // .jpg | .jpeg | .png

final fileName = (ext == ".png")
    ? "profile.png"
    : (ext == ".jpeg" ? "profile.jpeg" : "profile.jpg");

final contentType = fileName.endsWith(".png") ? "image/png" : "image/jpeg";

// ✅ Upload to: Personal/{publicUserId}/Profile/profile.(jpg|jpeg|png)
final storagePath = "$publicProfileCollection/$publicUserId/Profile/$fileName";

debugPrint("UPLOAD DEBUG:");
debugPrint(" uid=$uid");
debugPrint(" publicUserId(from Users doc)=$publicUserId");
debugPrint(" p.publicUserId(from stream)=${p.publicUserId}");
debugPrint(" storagePath=$storagePath");
debugPrint(" fileBytes=$bytes");
debugPrint(" contentType=$contentType");

final ref = _storage.ref().child(storagePath);

final meta = SettableMetadata(
  contentType: contentType,
  customMetadata: {
    "uid": uid,
    "publicUserId": publicUserId,
  },
);


      try {
  final snap = await ref.putFile(file, meta);
  final url = await snap.ref.getDownloadURL();

  await _remote.setMyProfilePhotoUrl(photoUrl: url);

  _toast("Photo updated");
} on FirebaseException catch (e) {
  debugPrint("❌ Upload failed: code=${e.code} message=${e.message}");
  rethrow;
}


    });
  }

  Future<void> _signOut() async {
    await _guard(() async {
      await _auth.signOut();
    });
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete account?"),
        content: const Text("This will delete your Firebase Auth user. This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _guard(() async {
      final user = _auth.currentUser;
      if (user == null) return;
      await user.delete(); // may require recent login
    });
  }

  // ✅ FIX: catch order (FirebaseAuthException first)
  Future<void> _guard(Future<void> Function() fn) async {
    try {
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      await fn();
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? e.code);
    } on FirebaseException catch (e) {
      final msg = (e.message ?? "").trim();
      final lower = msg.toLowerCase();

      if (e.code == "unauthorized" ||
          e.code == "permission-denied" ||
          lower.contains("permission")) {
        _toast("Permission denied (403). Check Storage Rules / App Check.");
      } else {
        _toast("${e.code}: $msg".trim());
      }
    } catch (e) {
      _toast(e.toString());
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PublicUserProfile>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text("Error: ${snap.error}"));
        }

        final p = snap.data;
        if (p == null) {
          return const Center(child: Text("Profile not ready yet..."));
        }

        final fullName = p.fullName.isEmpty ? "Unnamed" : p.fullName;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _changePhoto(p),
                      borderRadius: BorderRadius.circular(40),
                      child: CircleAvatar(
                        radius: 34,
                        backgroundImage: (p.photoUrl.isNotEmpty) ? NetworkImage(p.photoUrl) : null,
                        child: (p.photoUrl.isEmpty) ? const Icon(Icons.person, size: 34) : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fullName, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            "Public ID: ${p.publicUserId}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editName(p),
                      icon: const Icon(Icons.edit),
                      tooltip: "Edit name",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Actions", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text("Sign out"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _deleteAccount,
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete account"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Profile", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _row("Full name", fullName),
                    const SizedBox(height: 10),
                    _row("Public ID", p.publicUserId),
                    const SizedBox(height: 10),
                    // ✅ CHANGED
                    _row("Photo stored at","Storage: $publicProfileCollection/${p.publicUserId}/Profile/profile.jpg",),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

enum _PickSource { gallery, camera }
