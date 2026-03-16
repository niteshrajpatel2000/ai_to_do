import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class LangSelectionEvent extends Equatable {
  const LangSelectionEvent();
  @override
  List<Object?> get props => [];
}

class LangSelectionChanged extends LangSelectionEvent {
  final String code;
  const LangSelectionChanged({required this.code});
  @override
  List<Object?> get props => [code];
}

class LangSearchChanged extends LangSelectionEvent {
  final String query;
  const LangSearchChanged({required this.query});
  @override
  List<Object?> get props => [query];
}

// State
class LangSelectionState extends Equatable {
  final String selectedCode;
  final String searchQuery;

  const LangSelectionState({
    this.selectedCode = 'en',
    this.searchQuery = '',
  });

  LangSelectionState copyWith({String? selectedCode, String? searchQuery}) {
    return LangSelectionState(
      selectedCode: selectedCode ?? this.selectedCode,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [selectedCode, searchQuery];
}

// Bloc
class LangSelectionBloc extends Bloc<LangSelectionEvent, LangSelectionState> {
  LangSelectionBloc() : super(const LangSelectionState()) {
    on<LangSelectionChanged>((event, emit) {
      emit(state.copyWith(selectedCode: event.code));
    });
    on<LangSearchChanged>((event, emit) {
      emit(state.copyWith(searchQuery: event.query));
    });
  }
}
