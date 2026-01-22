import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_storage.read());

  final ThemeStorage _storage;

  Future<void> setSystem() async {
    emit(ThemeMode.system);
    await _storage.write(state);
  }

  Future<void> setLight() async {
    emit(ThemeMode.light);
    await _storage.write(state);
  }

  Future<void> setDark() async {
    emit(ThemeMode.dark);
    await _storage.write(state);
  }

  Future<void> toggle() async {
    final next = (state == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    await _storage.write(state);
  }
}
