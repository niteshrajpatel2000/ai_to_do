import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeChangeTab extends HomeEvent {
  final int index;

  const HomeChangeTab({required this.index});

  @override
  List<Object?> get props => [index];
}

class HomeToggleFocusMode extends HomeEvent {
  final bool enabled;

  const HomeToggleFocusMode({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}
