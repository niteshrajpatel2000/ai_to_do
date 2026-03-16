import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeChangeTab>(_onChangeTab);
    on<HomeToggleFocusMode>(_onToggleFocusMode);
  }

  void _onChangeTab(
    HomeChangeTab event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }

  void _onToggleFocusMode(
    HomeToggleFocusMode event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(focusMode: event.enabled));
  }
}
