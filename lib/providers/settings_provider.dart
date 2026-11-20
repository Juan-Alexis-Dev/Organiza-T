import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias simples guardadas con SharedPreferences.
class SettingsProvider extends ChangeNotifier {
  static const _kModoOscuro = 'modoOscuro';
  static const _kNombre = 'nombre';
  static const _kRadio = 'radioCheckIn';

  bool _modoOscuro = false;
  String _nombre = '';
  int _radio = 100; // metros, lo usará la Persona 4 para el check-in

  bool get modoOscuro => _modoOscuro;
  String get nombre => _nombre;
  int get radio => _radio;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _modoOscuro = prefs.getBool(_kModoOscuro) ?? false;
    _nombre = prefs.getString(_kNombre) ?? '';
    _radio = prefs.getInt(_kRadio) ?? 100;
    notifyListeners();
  }

  Future<void> cambiarModoOscuro(bool valor) async {
    _modoOscuro = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kModoOscuro, valor);
  }

  Future<void> cambiarNombre(String valor) async {
    _nombre = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNombre, valor);
  }

  Future<void> cambiarRadio(int valor) async {
    _radio = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRadio, valor);
  }
}