import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class HeaderThemeMenu extends StatelessWidget {
  const HeaderThemeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppThemeMode>(
      onSelected: (v) => Provider.of<ThemeService>(context, listen: false).setTheme(v),
      icon: const Icon(Icons.color_lens),
      itemBuilder: (_) => const [
        PopupMenuItem(value: AppThemeMode.system, child: Text('🖥 Thème système')),
        PopupMenuItem(value: AppThemeMode.light,  child: Text('🌞 Thème clair')),
        PopupMenuItem(value: AppThemeMode.dark,   child: Text('🌜 Thème sombre')),
      ],
    );
  }
}
