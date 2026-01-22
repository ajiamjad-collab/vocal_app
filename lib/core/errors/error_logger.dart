import 'package:flutter/foundation.dart';

import 'app_exception.dart';

class ErrorLogger {
  static void log(Object error, [StackTrace? st]) {
    if (!kDebugMode) return;

    if (error is AppException) {
      debugPrint('❌ AppException: code=${error.code} message=${error.message}');
      if (error.cause != null) debugPrint('   cause: ${error.cause}');
    } else {
      debugPrint('❌ Error: $error');
    }

    if (st != null) debugPrint('   stack: $st');
  }
}
