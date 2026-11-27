import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget { // Widget que muestra un ícono de racha con el número de días consecutivos completados. Cambia de color según la racha y si se completó hoy.
  final int streak;
  final bool doneToday;
  final double size;

  const StreakBadge({
    super.key,
    required this.streak,
    required this.doneToday,
    this.size = 56,
  });

  Color get _color {
    if (!doneToday && streak == 0) return Colors.grey;
    if (streak >= 30) return Colors.deepPurple;
    if (streak >= 7) return Colors.deepOrange;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) { // Construye el widget de racha, mostrando un círculo con un ícono de fuego y el número de días consecutivos completados. Cambia de tamaño y color si se completó hoy.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      width: doneToday ? size + 6 : size,
      height: doneToday ? size + 6 : size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color,
        boxShadow: doneToday
            ? [BoxShadow(color: _color.withValues(alpha: 0.5), blurRadius: 12)]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: size * 0.4,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$streak',
              key: ValueKey(streak),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.28,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
