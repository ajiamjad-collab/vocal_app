import 'package:connectivity_plus/connectivity_plus.dart';

enum NetType { none, wifi, mobile, ethernet, other }

class NetworkInfo {
  final Connectivity _connectivity;

  // ✅ Backward compatible constructor (your old code uses this)
  NetworkInfo(this._connectivity);

  // ✅ Also supports optional injection if you prefer later:
  NetworkInfo.optional({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// ✅ OLD API (kept): bool connectivity check
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// ✅ NEW API: richer online/offline
  Future<NetType> get type async {
    final results = await _connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.none)) return NetType.none;
    if (results.contains(ConnectivityResult.wifi)) return NetType.wifi;
    if (results.contains(ConnectivityResult.mobile)) return NetType.mobile;
    if (results.contains(ConnectivityResult.ethernet)) return NetType.ethernet;
    return NetType.other;
  }

  Future<bool> get isOnline async => (await type) != NetType.none;

  Stream<bool> get onOnlineChanged =>
      _connectivity.onConnectivityChanged.map((results) {
        return !results.contains(ConnectivityResult.none);
      }).distinct();

  Stream<NetType> get onTypeChanged =>
      _connectivity.onConnectivityChanged.map((results) {
        if (results.contains(ConnectivityResult.none)) return NetType.none;
        if (results.contains(ConnectivityResult.wifi)) return NetType.wifi;
        if (results.contains(ConnectivityResult.mobile)) return NetType.mobile;
        if (results.contains(ConnectivityResult.ethernet)) return NetType.ethernet;
        return NetType.other;
      }).distinct();
}
