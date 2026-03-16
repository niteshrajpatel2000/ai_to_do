import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/models/todo_model.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final FirestoreService _firestoreService;
  StreamSubscription<List<TodoModel>>? _todosSubscription;

  TodoBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(const TodoState()) {
    on<TodoLoadAll>(_onLoadAll);
    on<TodoAdd>(_onAdd);
    on<TodoToggle>(_onToggle);
    on<TodoDelete>(_onDelete);
    on<TodosUpdated>(_onTodosUpdated);
  }

  Future<void> _onLoadAll(
    TodoLoadAll event,
    Emitter<TodoState> emit,
  ) async {
    emit(state.copyWith(status: TodoStatus.loading));
    await _todosSubscription?.cancel();
    _todosSubscription = _firestoreService.getTodos().listen(
      (todos) => add(TodosUpdated(todos: todos)),
      onError: (error) => add(TodosUpdated(todos: const [])),
    );
  }

  void _onTodosUpdated(
    TodosUpdated event,
    Emitter<TodoState> emit,
  ) {
    emit(state.copyWith(
      status: TodoStatus.loaded,
      todos: event.todos,
    ));
  }

  Future<void> _onAdd(
    TodoAdd event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _firestoreService.addTodo(event.todo);
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        errorMessage: 'Failed to add task',
      ));
    }
  }

  Future<void> _onToggle(
    TodoToggle event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _firestoreService.toggleTodo(event.id, event.isCompleted);
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        errorMessage: 'Failed to update task',
      ));
    }
  }

  Future<void> _onDelete(
    TodoDelete event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _firestoreService.deleteTodo(event.id);
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.error,
        errorMessage: 'Failed to delete task',
      ));
    }
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    return super.close();
  }
}
