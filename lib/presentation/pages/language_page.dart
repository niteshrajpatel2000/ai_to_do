import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language_bloc/language_bloc.dart';
import '../bloc/language_bloc/language_event.dart';
import '../bloc/language_bloc/language_selection_bloc.dart';
import 'login_page.dart';

class LanguageModel {
  final String name;
  final String nativeName;
  final String code;
  final IconData icon;

  const LanguageModel({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.icon,
  });
}

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  final _searchController = TextEditingController();

  final List<LanguageModel> _languages = const [
    LanguageModel(name: 'English', nativeName: 'English (US)', code: 'en', icon: Icons.language),
    LanguageModel(name: 'Hindi', nativeName: 'हिन्दी', code: 'hi', icon: Icons.translate),
  ];

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
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _confirmSelection(String selectedCode) {
    context.read<LanguageBloc>().add(ChangeLanguage(Locale(selectedCode)));
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LangSelectionBloc(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF0D1117),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.arrow_back_ios_new, color: Colors.white.withOpacity(0.8), size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Text('Change Language',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Builder(
                      builder: (context) {
                        return Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                context.read<LangSelectionBloc>().add(LangSearchChanged(query: value)),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search language...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('POPULAR LANGUAGES',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.4), letterSpacing: 1.5)),
                  ),

                  const SizedBox(height: 12),

                  // Language List - BlocBuilder
                  Expanded(
                    child: BlocBuilder<LangSelectionBloc, LangSelectionState>(
                      builder: (context, state) {
                        final filtered = state.searchQuery.isEmpty
                            ? _languages
                            : _languages.where((lang) {
                                return lang.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
                                    lang.nativeName.toLowerCase().contains(state.searchQuery.toLowerCase());
                              }).toList();

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final lang = filtered[index];
                            final isSelected = state.selectedCode == lang.code;

                            return GestureDetector(
                              onTap: () => context.read<LangSelectionBloc>().add(LangSelectionChanged(code: lang.code)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF1A2332) : const Color(0xFF161B22),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF4A90FF).withOpacity(0.4)
                                        : Colors.white.withOpacity(0.06),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D1117),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(lang.icon, color: const Color(0xFF4A90FF), size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(lang.name,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                                          const SizedBox(height: 2),
                                          Text(lang.nativeName,
                                              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 22, height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF4A90FF) : Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 12, height: 12,
                                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4A90FF)),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Confirm Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocBuilder<LangSelectionBloc, LangSelectionState>(
                      buildWhen: (prev, curr) => prev.selectedCode != curr.selectedCode,
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => _confirmSelection(state.selectedCode),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B5BFE),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: const Text('Confirm Selection',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
