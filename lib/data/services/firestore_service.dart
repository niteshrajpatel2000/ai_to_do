import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  // Collection reference for user's todos
  CollectionReference<Map<String, dynamic>> get _todosRef =>
      _db.collection('users').doc(_userId).collection('todos');

  // Add a new todo
  Future<String> addTodo(TodoModel todo) async {
    final doc = await _todosRef.add(todo.toMap());
    return doc.id;
  }

  // Update a todo
  Future<void> updateTodo(String id, Map<String, dynamic> data) async {
    await _todosRef.doc(id).update(data);
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    await _todosRef.doc(id).delete();
  }

  // Get all todos as stream
  Stream<List<TodoModel>> getTodos() {
    return _todosRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get todos by status
  Stream<List<TodoModel>> getTodosByStatus(bool isCompleted) {
    return _todosRef
        .where('isCompleted', isEqualTo: isCompleted)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Toggle todo completion
  Future<void> toggleTodo(String id, bool isCompleted) async {
    await _todosRef.doc(id).update({'isCompleted': isCompleted});
  }

  // Save user profile data
  Future<void> saveUserProfile(String name, String email) async {
    await _db.collection('users').doc(_userId).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
