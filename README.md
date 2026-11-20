# OrganizaApp

Aplicación de organización personal en Flutter (Android, Windows y Linux):
lista de pendientes y hábitos con racha, evidencia fotográfica, check-in por GPS
y consumo de APIs (Nominatim y Open-Meteo).

## Estructura

```
lib/
├─ main.dart     # MultiProvider, rutas nombradas, tema
├─ models/       # Task, Habit
├─ providers/    # settings, task, habit, location, weather
├─ screens/      # pantallas
└─ widgets/      # componentes reutilizables
assets/images/
```

## Ramas

| Rama | Responsable | Módulo |
|---|---|---|
| `main` | Todos (vía Pull Request) | Versión estable |
| `tareas` | Persona 1 | Base, tareas, ajustes, inicio |
| `habitos` | Persona 2 | Hábitos y racha |
| `camara` | Persona 3 | Fotos y detalle del hábito |
| `ubicacion` | Persona 4 | GPS, Nominatim, Open-Meteo |

## Ejecutar

```bash
flutter pub get
flutter run -d linux     # o windows / el id de tu Android
```
