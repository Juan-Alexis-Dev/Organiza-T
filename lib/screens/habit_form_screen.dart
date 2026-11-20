import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/use_location_button.dart';

class HabitFormScreen extends StatefulWidget {
  static const routeName = '/habito-form';
  const HabitFormScreen({super.key});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _place = TextEditingController();
  int _nameLength = 0;
  bool _hasPlace = false;
  bool _saving = false;
  double? _lat;
  double? _lng;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _place.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await context.read<HabitProvider>().agregar(
      Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _name.text.trim(),
        descripcion: _description.text.trim(),
        icono: Icons.local_fire_department.codePoint,
        alAireLibre: _hasPlace,
        lat: _hasPlace ? _lat : null,
        lng: _hasPlace ? _lng : null,
        direccionDestino: _hasPlace ? _place.text.trim() : null,
      ),
    );
    if (!mounted) return;
    Navigator.pop(context, 'Hábito creado');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo hábito')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                maxLength: 40,
                onChanged: (v) => setState(() => _nameLength = v.length),
                decoration: InputDecoration(
                  labelText: 'Nombre del hábito',
                  prefixIcon: const Icon(Icons.local_fire_department),
                  border: const OutlineInputBorder(),
                  counterText: '$_nameLength/40',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  if (v.trim().length < 3) {
                    return 'Escribe al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Describe tu hábito';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Ligar a un lugar'),
                subtitle: const Text('Para validar con GPS después'),
                value: _hasPlace,
                onChanged: (v) => setState(() => _hasPlace = v),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                child: _hasPlace
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Botón de la Persona 4: GPS + dirección con Nominatim
                            UseLocationButton(
                              onLocationObtained: (lat, lng, direccion) {
                                setState(() {
                                  _lat = lat;
                                  _lng = lng;
                                  _place.text = direccion;
                                });
                              },
                            ),
                            if (_lat != null && _lng != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Coordenadas: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _place,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Lugar (ej. Gimnasio)',
                                prefixIcon: Icon(Icons.place),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (!_hasPlace) return null;
                                if (_lat == null || _lng == null) {
                                  return 'Pulsa "Usar mi ubicación" para fijar el lugar';
                                }
                                if (v == null || v.trim().isEmpty) {
                                  return 'Escribe el nombre del lugar';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: const Text('Guardar hábito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
