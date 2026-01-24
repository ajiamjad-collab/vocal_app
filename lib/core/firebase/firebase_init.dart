import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

Future<void> initFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}
