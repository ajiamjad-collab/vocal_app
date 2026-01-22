import 'package:flutter_bloc/flutter_bloc.dart';

class HomeMenuCubit extends Cubit<int> {
  HomeMenuCubit() : super(0);

  void setIndex(int index) => emit(index);
}
