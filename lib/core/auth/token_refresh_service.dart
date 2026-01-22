import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class TokenRefreshService {
  final FirebaseAuth auth;
  StreamSubscription<User?>? _sub;

  TokenRefreshService(this.auth);

  void start({
    required Future<void> Function() onUnauthenticated,
  }) {
    _sub?.cancel();

    // ✅ idTokenChanges emits whenever token refreshes / user changes
    _sub = auth.idTokenChanges().listen(
      (_) {},
      onError: (_) async {
        await onUnauthenticated();
      },
    );
  }

  Future<void> forceRefresh() async {
    final user = auth.currentUser;
    if (user == null) return;
    await user.getIdToken(true);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
