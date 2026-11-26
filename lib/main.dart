import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/habit_provider.dart';
import 'providers/location_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/habit_detail_screen.dart';
import 'screens/habit_form_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/task_form_screen.dart';
import 'screens/tasks_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ // Proveedores de estado para toda la aplicación, cargando los datos iniciales de cada uno
        ChangeNotifierProvider(create: (_) => SettingsProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => HabitProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const OrganizaApp(),
    ),
  );
}

class OrganizaApp extends StatelessWidget {
  const OrganizaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final modoOscuro = context.watch<SettingsProvider>().modoOscuro; // Lee el modo oscuro del SettingsProvider para aplicar el tema correspondiente a la aplicación

    return MaterialApp(
      title: 'OrganizaApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: modoOscuro ? ThemeMode.dark : ThemeMode.light,
      routes: { // Rutas de navegación de la aplicación, cada pantalla tiene su propia ruta y se puede acceder a ella desde cualquier parte de la app
        HomeScreen.routeName: (_) => const HomeScreen(),
        TasksScreen.routeName: (_) => const TasksScreen(),
        TaskFormScreen.routeName: (_) => const TaskFormScreen(),
        HabitsScreen.routeName: (_) => const HabitsScreen(),
        HabitFormScreen.routeName: (_) => const HabitFormScreen(),
        HabitDetailScreen.routeName: (_) => const HabitDetailScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}
