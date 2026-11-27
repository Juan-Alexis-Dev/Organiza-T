import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:organiza_t/models/habit.dart';
import 'package:organiza_t/providers/habit_provider.dart';

// Crea la ruta de una foto "tomada" en la fecha que le pasemos,
// igual que lo hace obtenerFoto()
String fotoDe(DateTime fecha) =>
    '/fotos/h1_${fecha.millisecondsSinceEpoch}.jpg';

void main() {
  late HabitProvider prov;

  setUp(() {
    // Preparamos un "celular falso" para que guardar no falle
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    prov = HabitProvider();
  });

  group('tieneFotoHoy', () {
    test('sin fotos devuelve false', () {
      final h = Habit(id: 'h1', nombre: 'Leer', icono: 0);
      expect(prov.tieneFotoHoy(h), false);
    });

    test('con foto de hoy devuelve true', () {
      final h = Habit(id: 'h1', nombre: 'Leer', icono: 0,
          fotos: [fotoDe(DateTime.now())]);
      expect(prov.tieneFotoHoy(h), true);
    });

    test('con foto de ayer devuelve false', () {
      final ayer = DateTime.now().subtract(const Duration(days: 1));
      final h = Habit(id: 'h1', nombre: 'Leer', icono: 0,
          fotos: [fotoDe(ayer)]);
      expect(prov.tieneFotoHoy(h), false);
    });

    test('una ruta rara no rompe nada', () {
      final h = Habit(id: 'h1', nombre: 'Leer', icono: 0,
          fotos: ['/fotos/foto_sin_numero.jpg', 'xyz']);
      expect(prov.tieneFotoHoy(h), false);
    });
  });

  group('motivoBloqueo', () {
    test('sin foto avisa que falta la foto', () {
      final h = Habit(id: 'h1', nombre: 'Leer', icono: 0);
      expect(prov.motivoBloqueo(h, dentroDeRango: true), isNotNull);
    });

    test('interiores con foto de hoy: puede completar', () {
      final h = Habit(id: 'h1', nombre: 'Leer', icono: 0,
          fotos: [fotoDe(DateTime.now())]);
      expect(prov.motivoBloqueo(h, dentroDeRango: false), isNull);
    });

    test('aire libre, con foto pero lejos: bloqueado', () {
      final h = Habit(id: 'h1', nombre: 'Correr', icono: 0,
          alAireLibre: true, lat: 20.5, lng: -100.4,
          fotos: [fotoDe(DateTime.now())]);
      expect(prov.motivoBloqueo(h, dentroDeRango: false), isNotNull);
    });

    test('aire libre, con foto y dentro del lugar: puede completar', () {
      final h = Habit(id: 'h1', nombre: 'Correr', icono: 0,
          alAireLibre: true, lat: 20.5, lng: -100.4,
          fotos: [fotoDe(DateTime.now())]);
      expect(prov.motivoBloqueo(h, dentroDeRango: true), isNull);
    });

    test('aire libre pero sin coordenadas: no pide ubicación', () {
      final h = Habit(id: 'h1', nombre: 'Correr', icono: 0,
          alAireLibre: true, fotos: [fotoDe(DateTime.now())]);
      expect(prov.motivoBloqueo(h, dentroDeRango: false), isNull);
    });
  });

  group('completar', () {
    test('sin foto no completa y no guarda la fecha', () async {
      final h = Habit(id: 'h1', nombre: 'Leer', icono: 0);
      await prov.agregar(h);

      final mensaje = await prov.completar('h1');

      expect(mensaje, isNotNull);
      expect(h.doneToday, false);
    });

    test('con foto de hoy completa y devuelve null', () async {
      final h = Habit(id: 'h1', nombre: 'Leer', icono: 0,
          fotos: [fotoDe(DateTime.now())]);
      await prov.agregar(h);

      final mensaje = await prov.completar('h1');

      expect(mensaje, isNull);
      expect(h.doneToday, true);
    });

    test('completar dos veces el mismo día no duplica la fecha', () async {
      final h = Habit(id: 'h1', nombre: 'Leer', icono: 0,
          fotos: [fotoDe(DateTime.now())]);
      await prov.agregar(h);

      await prov.completar('h1');
      final segundoIntento = await prov.completar('h1');

      expect(segundoIntento, isNotNull);
      expect(h.fechasCompletadas.length, 1);
    });

    test('aire libre sin estar en el lugar no completa', () async {
      final h = Habit(id: 'h1', nombre: 'Correr', icono: 0,
          alAireLibre: true, lat: 20.5, lng: -100.4,
          fotos: [fotoDe(DateTime.now())]);
      await prov.agregar(h);

      expect(await prov.completar('h1', dentroDeRango: false), isNotNull);
      expect(await prov.completar('h1', dentroDeRango: true), isNull);
    });
  });
}