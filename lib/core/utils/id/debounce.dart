import 'dart:async';

class Debounce {
  Debounce(this.duration);
  final Duration duration;
  Timer? _t;

  void run(void Function() action) {
    _t?.cancel();
    _t = Timer(duration, action);
  }

  void dispose() => _t?.cancel();
}
