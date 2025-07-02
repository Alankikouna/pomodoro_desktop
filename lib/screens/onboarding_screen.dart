import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.timer,
      title: "Bienvenue sur Pomodoro Desktop",
      description: "Gérez vos sessions de travail et vos pauses efficacement.",
    ),
    _OnboardingPage(
      icon: Icons.tune,
      title: "Personnalisez vos durées",
      description: "Adaptez le temps de focus et de pause selon vos besoins.",
    ),
    _OnboardingPage(
      icon: Icons.block,
      title: "Restez concentré",
      description: "Bloquez les applications distrayantes pendant vos sessions.",
    ),
  ];

  void _next() async {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      // Marque l'onboarding comme vu dans la base
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client
            .from('pomodoro_settings')
            .upsert({'user_id': userId, 'has_seen_onboarding': true});
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? Colors.indigo : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_page == _pages.length - 1 ? "Commencer" : "Suivant"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.indigo),
            const SizedBox(height: 32),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(description, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}