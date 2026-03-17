import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test_project/data/models/todo_model.dart';

void main() {
  group('TodoModel', () {
    test('should create a TodoModel with required fields', () {
      final todo = TodoModel(title: 'Test Todo');

      expect(todo.title, 'Test Todo');
      expect(todo.description, '');
      expect(todo.priority, 'medium');
      expect(todo.isCompleted, false);
      expect(todo.dueDate, isNull);
      expect(todo.id, isNull);
    });

    test('should create a TodoModel with all fields', () {
      final dueDate = DateTime(2026, 4, 1);
      final todo = TodoModel(
        id: '123',
        title: 'Full Todo',
        description: 'A test description',
        priority: 'high',
        isCompleted: true,
        dueDate: dueDate,
      );

      expect(todo.id, '123');
      expect(todo.title, 'Full Todo');
      expect(todo.description, 'A test description');
      expect(todo.priority, 'high');
      expect(todo.isCompleted, true);
      expect(todo.dueDate, dueDate);
    });

    test('should convert to map correctly', () {
      final todo = TodoModel(
        title: 'Map Test',
        description: 'Testing toMap',
        priority: 'low',
      );

      final map = todo.toMap();

      expect(map['title'], 'Map Test');
      expect(map['description'], 'Testing toMap');
      expect(map['priority'], 'low');
      expect(map['isCompleted'], false);
    });

    test('copyWith should create a new instance with updated fields', () {
      final todo = TodoModel(title: 'Original');
      final updated = todo.copyWith(title: 'Updated', priority: 'high');

      expect(updated.title, 'Updated');
      expect(updated.priority, 'high');
      expect(updated.description, '');
    });
  });
}
