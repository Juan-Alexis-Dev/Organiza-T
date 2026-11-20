import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'screens/habit_detail_screen.dart';
import 'screens/habit_form_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/task_form_screen.dart';
import 'screens/tasks_screen.dart';
*/

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Persona 1: ChangeNotifierProvider(create: (_) => SettingsProvider()..cargar()),
        // Persona 1: ChangeNotifierProvider(create: (_) => TaskProvider()..cargar()),
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

    );
  }
}
