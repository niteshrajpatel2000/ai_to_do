import 'package:equatable/equatable.dart';
import '../../../data/models/todo_model.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class TodoLoadAll extends TodoEvent {}

class TodoLoadByStatus extends TodoEvent {
  final bool isCompleted;

  const TodoLoadByStatus({required this.isCompleted});

  @override
  List<Object?> get props => [isCompleted];
}

class TodoAdd extends TodoEvent {
  final TodoModel todo;

  const TodoAdd({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class TodoToggle extends TodoEvent {
  final String id;
  final bool isCompleted;

  const TodoToggle({required this.id, required this.isCompleted});

  @override
  List<Object?> get props => [id, isCompleted];
}

class TodoDelete extends TodoEvent {
  final String id;

  const TodoDelete({required this.id});

  @override
  List<Object?> get props => [id];
}

class TodosUpdated extends TodoEvent {
  final List<TodoModel> todos;

  const TodosUpdated({required this.todos});

  @override
  List<Object?> get props => [todos];
}
