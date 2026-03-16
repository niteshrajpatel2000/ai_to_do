import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localization.dart';
import '../../data/models/todo_model.dart';
import '../../data/services/auth_service.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/auth_bloc/auth_event.dart';
import '../bloc/auth_bloc/auth_state.dart';
import '../bloc/home_bloc/home_bloc.dart';
import '../bloc/home_bloc/home_event.dart';
import '../bloc/home_bloc/home_state.dart';
import '../bloc/todo_bloc/todo_bloc.dart';
import '../bloc/todo_bloc/todo_event.dart';
import '../bloc/todo_bloc/todo_state.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();

    // Load todos via BLoC
    context.read<TodoBloc>().add(TodoLoadAll());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.split(' ').first;
    }
    return 'User';
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalization.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          _navigateToLogin();
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF0D1117),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: IndexedStack(
                    index: homeState.currentIndex,
                    children: [
                      _buildTodayTab(t, homeState),
                      _buildTasksTab(t),
                      _buildSettingsTab(t),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNav(t, homeState.currentIndex),
          );
        },
      ),
    );
  }

  // ============ TODAY TAB ============
  Widget _buildTodayTab(AppLocalization t, HomeState homeState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Top bar
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90FF), Color(0xFF6C63FF)],
                  ),
                  border: Border.all(
                    color: const Color(0xFF4A90FF).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getUserName()[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI To-Do',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Greeting
          Text('${_getGreeting()},',
              style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.5))),
          Text('Hello, ${_getUserName()}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(t.translate('ready_to_tackle'),
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.4))),

          const SizedBox(height: 28),

          // Focus Mode Card - uses HomeBloc
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.translate('focus_mode'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(t.translate('focus_mode_desc'),
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                    ],
                  ),
                ),
                Switch(
                  value: homeState.focusMode,
                  onChanged: (val) => context.read<HomeBloc>().add(HomeToggleFocusMode(enabled: val)),
                  activeColor: const Color(0xFF4A90FF),
                  activeTrackColor: const Color(0xFF4A90FF).withOpacity(0.3),
                  inactiveThumbColor: Colors.white.withOpacity(0.5),
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Top Priorities
          Text(t.translate('top_priorities'),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.4), letterSpacing: 1.5)),
          const SizedBox(height: 14),

          // Task list from TodoBloc
          BlocBuilder<TodoBloc, TodoState>(
            builder: (context, todoState) {
              if (todoState.status == TodoStatus.loading || todoState.status == TodoStatus.initial) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: Color(0xFF4A90FF), strokeWidth: 2),
                  ),
                );
              }

              final todos = todoState.incompleteTodos;

              if (todos.isEmpty) {
                return _buildEmptyState(t);
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todos.length > 5 ? 5 : todos.length,
                itemBuilder: (context, index) {
                  return _buildTaskCard(todos[index], index == 0);
                },
              );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TodoModel todo, bool isFeatured) {
    final priorityColor = todo.priority == 'high'
        ? const Color(0xFF4A90FF)
        : todo.priority == 'medium'
            ? const Color(0xFFFFA726)
            : const Color(0xFF66BB6A);

    final priorityLabel = todo.priority == 'high'
        ? 'HIGH IMPACT'
        : todo.priority == 'medium'
            ? 'MEDIUM'
            : 'LOW';

    if (isFeatured) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: priorityColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(priorityLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: priorityColor, letterSpacing: 1)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.read<TodoBloc>().add(TodoToggle(id: todo.id!, isCompleted: true)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Start', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(todo.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
            if (todo.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(todo.description,
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<TodoBloc>().add(TodoToggle(id: todo.id!, isCompleted: true)),
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: priorityColor.withOpacity(0.5), width: 2),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(todo.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(todo.description,
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.35)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalization t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            Icon(Icons.task_alt_rounded, size: 60, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 16),
            Text(t.translate('no_tasks'), style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.4))),
            const SizedBox(height: 8),
            Text(t.translate('add_first_task'), style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.25))),
          ],
        ),
      ),
    );
  }

  // ============ TASKS TAB ============
  Widget _buildTasksTab(AppLocalization t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Text(t.translate('my_tasks'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              GestureDetector(
                onTap: _showAddTaskDialog,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF3B5BFE), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: BlocBuilder<TodoBloc, TodoState>(
            builder: (context, todoState) {
              if (todoState.status == TodoStatus.loading || todoState.status == TodoStatus.initial) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4A90FF), strokeWidth: 2));
              }

              final todos = todoState.todos;

              if (todos.isEmpty) {
                return _buildEmptyState(t);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Dismissible(
                    key: Key(todo.id!),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => context.read<TodoBloc>().add(TodoDelete(id: todo.id!)),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    child: _buildTaskListItem(todo),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskListItem(TodoModel todo) {
    final priorityColor = todo.priority == 'high'
        ? const Color(0xFF4A90FF)
        : todo.priority == 'medium'
            ? const Color(0xFFFFA726)
            : const Color(0xFF66BB6A);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<TodoBloc>().add(TodoToggle(id: todo.id!, isCompleted: !todo.isCompleted)),
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: todo.isCompleted ? priorityColor : Colors.transparent,
                border: Border.all(color: priorityColor.withOpacity(0.5), width: 2),
              ),
              child: todo.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(todo.title,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: todo.isCompleted ? Colors.white.withOpacity(0.3) : Colors.white,
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    )),
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(todo.description,
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(todo.priority.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: priorityColor, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  // ============ SETTINGS TAB ============
  Widget _buildSettingsTab(AppLocalization t) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.translate('settings'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 28),

          // Profile card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF4A90FF), Color(0xFF6C63FF)]),
                  ),
                  child: Center(
                    child: Text(_getUserName()[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'User',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildSettingsTile(icon: Icons.language, title: t.translate('language'), onTap: () {}),
          _buildSettingsTile(icon: Icons.dark_mode_outlined, title: t.translate('theme'), onTap: () {}),
          _buildSettingsTile(icon: Icons.notifications_none_rounded, title: t.translate('notifications'), onTap: () {}),
          _buildSettingsTile(icon: Icons.info_outline_rounded, title: t.translate('about'), onTap: () {}),

          const SizedBox(height: 20),

          // Logout - uses AuthBloc
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: t.translate('logout'),
            isDestructive: true,
            onTap: () => context.read<AuthBloc>().add(AuthSignOut()),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.red.shade400 : Colors.white.withOpacity(0.6), size: 22),
            const SizedBox(width: 14),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDestructive ? Colors.red.shade400 : Colors.white)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.2), size: 20),
          ],
        ),
      ),
    );
  }

  // ============ ADD TASK DIALOG ============
  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedPriority = 'medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  _buildDialogField(titleController, 'Task title'),
                  const SizedBox(height: 12),
                  _buildDialogField(descController, 'Description (optional)'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildPriorityChip('high', 'High', selectedPriority, const Color(0xFF4A90FF), (val) {
                        setModalState(() => selectedPriority = val);
                      }),
                      const SizedBox(width: 8),
                      _buildPriorityChip('medium', 'Medium', selectedPriority, const Color(0xFFFFA726), (val) {
                        setModalState(() => selectedPriority = val);
                      }),
                      const SizedBox(width: 8),
                      _buildPriorityChip('low', 'Low', selectedPriority, const Color(0xFF66BB6A), (val) {
                        setModalState(() => selectedPriority = val);
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        final todo = TodoModel(
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          priority: selectedPriority,
                        );
                        context.read<TodoBloc>().add(TodoAdd(todo: todo));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B5BFE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String value, String label, String selected, Color color, Function(String) onTap) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color.withOpacity(0.4) : Colors.white.withOpacity(0.08)),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? color : Colors.white.withOpacity(0.5))),
      ),
    );
  }

  // ============ BOTTOM NAV ============
  Widget _buildBottomNav(AppLocalization t, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.today_rounded, t.translate('today'), 0, currentIndex),
              _buildNavItem(Icons.checklist_rounded, t.translate('tasks'), 1, currentIndex),
              _buildNavItem(Icons.settings_outlined, t.translate('settings'), 2, currentIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int currentIndex) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => context.read<HomeBloc>().add(HomeChangeTab(index: index)),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF4A90FF) : Colors.white.withOpacity(0.35), size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF4A90FF) : Colors.white.withOpacity(0.35),
                )),
          ],
        ),
      ),
    );
  }
}
