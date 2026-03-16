import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int currentIndex;
  final bool focusMode;

  const HomeState({
    this.currentIndex = 0,
    this.focusMode = false,
  });

  HomeState copyWith({
    int? currentIndex,
    bool? focusMode,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      focusMode: focusMode ?? this.focusMode,
    );
  }

  @override
  List<Object?> get props => [currentIndex, focusMode];
}
