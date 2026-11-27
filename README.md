# OrganizaApp

Aplicación de organización personal desarrollada en **Flutter** (Android, Windows y Linux). Combina una lista de pendientes con un seguimiento de hábitos: racha de días consecutivos, evidencia fotográfica, check-in por GPS y consulta del clima mediante APIs públicas.

## Tabla de contenido

1. [Características](#características)
2. [Tecnologías y paquetes](#tecnologías-y-paquetes)
3. [Estructura del proyecto](#estructura-del-proyecto)
4. [Contenido de cada parte](#contenido-de-cada-parte)
5. [Acuerdos compartidos](#acuerdos-compartidos)
6. [División del trabajo y ramas](#división-del-trabajo-y-ramas)
7. [Flujo de trabajo con Git](#flujo-de-trabajo-con-git)
8. [Instalación y ejecución](#instalación-y-ejecución)
9. [Permisos y compatibilidad por plataforma](#permisos-y-compatibilidad-por-plataforma)
10. [Almacenamiento de datos](#almacenamiento-de-datos)
11. [APIs externas](#apis-externas)
12. [Pruebas](#pruebas)
13. [Equipo](#equipo)

---

## Características

- **Tareas:** crear (con validación), completar y eliminar pendientes, con animación al completarlas.
- **Hábitos:** crear hábitos con ícono, marcarlos como completados cada día y ver la **racha** actual.
- **Evidencia fotográfica:** adjuntar fotos a cada hábito (cámara en Android, selector de archivos en Windows y Linux) y verlas en una galería.
- **Check-in por ubicación:** para hábitos al aire libre, se valida la distancia al lugar registrado según un radio configurable.
- **Clima:** tarjeta con el clima del día según las coordenadas del usuario.
- **Dirección legible:** conversión de coordenadas a dirección con Nominatim.
- **Ajustes:** modo claro/oscuro, nombre del usuario y radio del check-in.
- **Pantalla de inicio:** saludo, clima, pendientes de hoy y resumen de rachas.

## Tecnologías y paquetes

- Flutter / Dart
- Gestión de estado: `provider`
- Persistencia de preferencias: `shared_preferences`
- Archivos locales: `path_provider`
- Peticiones HTTP: `http`
- Fotos: `image_picker`
- GPS: `geolocator`

## Estructura del proyecto

```
Organiza-T/
├─ assets/
│  └─ images/
└─ lib/
   ├─ main.dart                  # MultiProvider, rutas nombradas y tema
   ├─ models/
   │  ├─ task.dart
   │  └─ habit.dart
   ├─ providers/
   │  ├─ settings_provider.dart
   │  ├─ task_provider.dart
   │  ├─ habit_provider.dart
   │  ├─ location_provider.dart
   │  └─ weather_provider.dart
   ├─ screens/
   │  ├─ home_screen.dart
   │  ├─ tasks_screen.dart
   │  ├─ task_form_screen.dart
   │  ├─ habits_screen.dart
   │  ├─ habit_form_screen.dart
   │  ├─ habit_detail_screen.dart
   │  └─ settings_screen.dart
   └─ widgets/
      ├─ task_tile.dart
      ├─ habit_card.dart
      ├─ streak_badge.dart
      ├─ photo_grid.dart
      ├─ location_panel.dart
      └─ weather_card.dart
```

Cada *provider* se encarga de su propia lógica y de su propio archivo de datos, de modo que los módulos quedan separados y cada integrante puede trabajar sin modificar el código de los demás.

## Contenido de cada parte

### Models

| Archivo | Contenido |
|---|---|
| `task.dart` | Clase `Task` (id, título, descripción, completada) con `toJson` y `fromJson`. |
| `habit.dart` | Clase `Habit` (id, nombre, ícono, al aire libre, latitud, longitud, dirección, fechas completadas y fotos) con `toJson` y `fromJson`. |

### Providers

| Archivo | Contenido |
|---|---|
| `settings_provider.dart` | Lee y guarda con `SharedPreferences` el modo claro/oscuro, el nombre del usuario y el radio del check-in. |
| `task_provider.dart` | Agregar, completar y eliminar tareas; leer y guardar `tareas.json`. |
| `habit_provider.dart` | Agregar, eliminar y completar hábitos; cálculo de racha; obtener y copiar fotos; leer y guardar `habitos.json`. |
| `location_provider.dart` | Permisos de ubicación, posición actual, posición en tiempo real, cálculo de distancia y consulta a Nominatim. |
| `weather_provider.dart` | Consulta a Open-Meteo con las coordenadas del usuario. |

### Screens

| Archivo | Contenido |
|---|---|
| `home_screen.dart` | Pantalla principal: saludo, clima, pendientes de hoy y resumen de rachas. Usa `Text`, `Container`, `Row`, `Column`, `Image` e `Icon`. |
| `tasks_screen.dart` | Lista de tareas con `ListView` y opción de marcarlas como completadas. |
| `task_form_screen.dart` | Formulario con validación para crear tareas. |
| `habits_screen.dart` | Lista de hábitos con su racha actual. |
| `habit_form_screen.dart` | Formulario con validación para crear hábitos y botón para usar la ubicación actual. |
| `habit_detail_screen.dart` | Recibe el id del hábito por argumento. Muestra la portada con `Stack`, el check-in por ubicación, el botón *Completar* y la galería de fotos. |
| `settings_screen.dart` | Cambio de tema y nombre del usuario. |

### Widgets

| Archivo | Contenido |
|---|---|
| `task_tile.dart` | Fila de una tarea con checkbox y animación al completarla. |
| `habit_card.dart` | Tarjeta de hábito con `Stack`: última foto de fondo y la racha encima. |
| `streak_badge.dart` | Indicador de racha con `AnimatedSwitcher`. |
| `photo_grid.dart` | `GridView` con las fotos de evidencia. |
| `location_panel.dart` | Ubicación en tiempo real y distancia al lugar del hábito. |
| `weather_card.dart` | Tarjeta con el clima del día. |

### Assets

Logo de la aplicación e imágenes para cuando no hay tareas o hábitos registrados (`assets/images/`).

## Acuerdos compartidos

Antes de dividir el trabajo, el equipo acordó el modelo `Habit` y las rutas nombradas, ya que son los elementos que comparten todos los módulos.

### Modelo `Habit`

```dart
String id, nombre;
int icono;                         // codePoint del Icon
bool alAireLibre;
double? lat, lng;
String? direccion;                 // la llena Nominatim
List<String> fechasCompletadas;    // formato "2026-11-19"
List<String> fotos;                // rutas de archivo
```

### Rutas nombradas

| Ruta | Pantalla | Notas |
|---|---|---|
| `/` | `HomeScreen` | |
| `/tareas` | `TasksScreen` | |
| `/tarea-form` | `TaskFormScreen` | |
| `/habitos` | `HabitsScreen` | |
| `/habito-form` | `HabitFormScreen` | |
| `/habito-detalle` | `HabitDetailScreen` | Recibe el **id** del hábito como argumento. |
| `/ajustes` | `SettingsScreen` | |

### Cálculo de la racha

La racha se obtiene a partir de `fechasCompletadas`: se ordenan las fechas y se cuentan los días consecutivos hacia atrás desde hoy (o desde ayer, si hoy aún no se completa el hábito). Un día sin registro rompe la racha.

## División del trabajo y ramas

El trabajo se divide por **funciones**: cada integrante es responsable de un módulo completo (modelo, lógica y pantallas).

| Rama | Responsable | Módulo | Archivos principales |
|---|---|---|---|
| `main` | Todos (vía Pull Request) | Versión estable | — |
| `tareas` | Persona 1 | Base de la app y tareas | `main.dart`, `settings_provider`, `settings_screen`, `task*`, `home_screen` |
| `habitos` | Persona 2 | Hábitos y racha | `habit.dart`, `habit_provider`, `habits_screen`, `habit_form_screen`, `habit_card`, `streak_badge` |
| `camara` | Persona 3 | Fotos y detalle del hábito | `obtenerFoto()`, `habit_detail_screen`, `photo_grid` |
| `ubicacion` | Persona 4 | GPS, Nominatim y Open-Meteo | `location_provider`, `weather_provider`, `location_panel`, `weather_card` |

### Persona 1: Base de la app y tareas
Estructura que conecta la aplicación y módulo de pendientes: `MultiProvider`, rutas nombradas y tema; preferencias con `SharedPreferences`; módulo de tareas completo; y pantalla de inicio integrando los widgets de los demás módulos. Entrega primero el proyecto con las pantallas vacías y las rutas funcionando para que el resto trabaje sobre esa base.

### Persona 2: Hábitos y racha
Modelo y lógica de hábitos (crear, eliminar, completar, racha y `habitos.json`), pantallas de lista y formulario con validación, y widgets con animaciones. Es el módulo con más lógica.

### Persona 3: Cámara y detalle del hábito
Método `obtenerFoto()` en `habit_provider.dart` (cámara en Android, archivos del PC en Windows y Linux, con copia a la carpeta de la app, en coordinación con la Persona 2), pantalla de detalle con `Stack`, botón *Completar* y galería `GridView`. Integra el `location_panel` de la Persona 4.

### Persona 4: Ubicación y APIs
Todo lo que usa GPS o internet: permisos, posición actual y en tiempo real, cálculo de distancia, conversión de coordenadas a dirección (Nominatim) y clima (Open-Meteo). Incluye el botón "Usar mi ubicación" del formulario de hábitos, en coordinación con la Persona 2. Puede probar sus widgets en una pantalla de prueba antes de integrarlos.

## Flujo de trabajo con Git

1. **Día 1:** la Persona 1 crea el proyecto, las rutas y las pantallas vacías; la Persona 2 escribe los modelos. Todo el equipo revisa los acuerdos iniciales.
2. **Desarrollo en paralelo:** cada integrante trabaja en su propia rama (`tareas`, `habitos`, `camara`, `ubicacion`).
3. **Integración:** la Persona 3 agrega el `location_panel` al detalle del hábito; la Persona 1 agrega el `weather_card` y el resumen de hábitos a la pantalla de inicio.
4. **Pruebas:** cámara y GPS en Android; funcionamiento general en Windows y Linux.
5. **Documentación y presentación:** cada integrante documenta y presenta su módulo; la Persona 1 integra la documentación final.

Los cambios llegan a `main` únicamente mediante **Pull Request**.

## Instalación y ejecución

Requisitos: Flutter SDK instalado y configurado (`flutter doctor` sin errores para la plataforma elegida).

```bash
git clone <URL-del-repositorio>
cd Organiza-T
flutter pub get
flutter run -d linux       # o: windows / el id de tu dispositivo Android
```

Para listar los dispositivos disponibles:

```bash
flutter devices
```

## Permisos y compatibilidad por plataforma

| Función                  | Android     | Windows              | Linux                |
| ------------------------ | ----------- | -------------------- | -------------------- |
| Tareas, hábitos, ajustes | ✅           | ✅                    | ✅                    |
| Fotos                    | Cámara      | Selector de archivos | Selector de archivos |
| GPS / check-in           | ✅ (probado) | Limitado             | Limitado             |
| Clima y Nominatim        | ✅           | ✅                    | ✅                    |

Permisos de Android (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

## Almacenamiento de datos

| Dato | Medio |
|---|---|
| Tema, nombre de usuario, radio del check-in | `SharedPreferences` |
| Tareas | Android/Windows/Linux: `tareas.json` (vía `path_provider`); web: `SharedPreferences` |
| Hábitos | `habitos.json` (misma carpeta) |
| Fotos de evidencia | Copiadas a la carpeta de la app; `habitos.json` guarda solo las rutas |

## APIs externas

- **Nominatim (OpenStreetMap):** geocodificación inversa para obtener la dirección a partir de latitud y longitud. Requiere enviar un encabezado `User-Agent` identificando la app y respetar su límite de uso (máximo 1 petición por segundo).
- **Open-Meteo:** pronóstico del clima por coordenadas. No requiere clave de API.

## Pruebas

- Cámara y GPS: dispositivo Android real.
- Funcionamiento general (tareas, hábitos, racha, ajustes, navegación): Windows y Linux.

## Equipo

| Persona   | Nombre                 | Módulo                                           |
| --------- | ---------------------- | ------------------------------------------------ |
| Persona 1 | _(Juan Alexis)_        | Base, rutas, tema, preferencias, tareas e inicio |
| Persona 2 | _(Mauricio Navarrete)_ | Hábitos, racha y animaciones                     |
| Persona 3 | _(Luisa Xiomara)_      | Cámara, fotos y detalle del hábito               |
| Persona 4 | _(Ivan Pintot)_        | GPS, Nominatim y Open-Meteo                      |
