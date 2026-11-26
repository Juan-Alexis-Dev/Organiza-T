import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {// Pantalla de ajustes, permite cambiar el modo oscuro, nombre del usuario y radio de check-in
  static const routeName = '/ajustes';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nombreCtrl;
  late double _radio; // estado local mientras se mueve el slider

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _nombreCtrl = TextEditingController(text: settings.nombre);
    _radio = settings.radio.toDouble();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _guardarNombre() { // Guarda el nombre del usuario usando SettingsProvider y muestra un SnackBar de confirmación
    context.read<SettingsProvider>().cambiarNombre(_nombreCtrl.text.trim());
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nombre guardado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Modo oscuro'),
            value: settings.modoOscuro,
            onChanged: settings.cambiarModoOscuro,
          ),
          const Divider(), // Separador visual entre secciones
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _guardarNombre(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _guardarNombre,
              icon: const Icon(Icons.save),
              label: const Text('Guardar nombre'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text('Radio del check-in'),
            subtitle: Text('${_radio.round()} m'),
          ),
          Slider(
            value: _radio,
            min: 50,
            max: 500,
            divisions: 9,
            label: '${_radio.round()} m',
            onChanged: (v) => setState(() => _radio = v),
            onChangeEnd: (v) => settings.cambiarRadio(v.round()),
          ),
        ],
      ),
    );
  }
}