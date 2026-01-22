import 'package:cloud_functions/cloud_functions.dart';

class FunctionsClient {
  final FirebaseFunctions functions;
  FunctionsClient(this.functions);

  Future<T> call<T>(
    String name, {
    Map<String, dynamic> data = const {},
  }) async {
    final res = await functions.httpsCallable(name).call(data);
    return res.data as T;
  }
}
