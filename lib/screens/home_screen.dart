import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import 'habits_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nombre = context.watch<SettingsProvider>().nombre;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OrganizaApp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 56,
                  height: 56,
                  errorBuilder: (_, __, ___) => const Icon(Icons.task_alt, size: 56),
                ),
                const SizedBox(width: 12),
                Text(
                  nombre.isEmpty ? 'Hola' : 'Hola, $nombre',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, HabitsScreen.routeName),
              icon: const Icon(Icons.local_fire_department),
              label: const Text('Hábitos'),
            ),
            // Botón de Tareas: día 2
          ],
        ),
      ),
    );
  }
}