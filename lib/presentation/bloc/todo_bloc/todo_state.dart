import 'package:equatable/equatable.dart';
import '../../../data/models/todo_model.dart';

enum TodoStatus { initial, loading, loaded, error }

class TodoState extends Equatable {
  final TodoStatus status;
  final List<TodoModel> todos;
  final String? errorMessage;

  const TodoState({
    this.status = TodoStatus.initial,
    this.todos = const [],
    this.errorMessage,
  });

  TodoState copyWith({
    TodoStatus? status,
    List<TodoModel>? todos,
    String? errorMessage,
  }) {
    return TodoState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      errorMessage: errorMessage,
    );
  }

  List<TodoModel> get incompleteTodos =>
      todos.where((t) => !t.isCompleted).toList();

  List<TodoModel> get completedTodos =>
      todos.where((t) => t.isCompleted).toList();

  @override
  List<Object?> get props => [status, todos, errorMessage];
}
