import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
// import 'providers/task_provider.dart';
import 'screens/habit_detail_screen.dart';
import 'screens/habit_form_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/home_screen.dart';

/*
import 'screens/settings_screen.dart';
import 'screens/task_form_screen.dart';
import 'screens/tasks_screen.dart';
*/

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..cargar()),
        // ChangeNotifierProvider(create: (_) => TaskProvider()..cargar()),
        // Persona 2: ChangeNotifierProvider(create: (_) => HabitProvider()..cargar()),
        // Persona 4: ChangeNotifierProvider(create: (_) => LocationProvider()),
        // Persona 4: ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const OrganizaApp(),
    ),
  );
}

class OrganizaApp extends StatelessWidget {
  const OrganizaApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        // TasksScreen.routeName: (_) => const TasksScreen(),
        // TaskFormScreen.routeName: (_) => const TaskFormScreen(),
        HabitsScreen.routeName: (_) => const HabitsScreen(),
        HabitFormScreen.routeName: (_) => const HabitFormScreen(),
        HabitDetailScreen.routeName: (_) => const HabitDetailScreen(),
        // SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}
