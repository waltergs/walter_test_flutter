# walter_test_flutter

# La prueba consiste en un CRUD básico de Usuarios + Direcciones almacenando los datos localmente con Hive para la prueba

Proyecto de prueba creado en Flutter:
- 3 pantallas: Lista usuarios, Form crear usuario (con direcciones), Detalle usuario (administrar direcciones).
- Almacenamiento local con **Hive** (sin configuración externa).
- State management: **flutter_riverpod** (simple inyección de repositorio).
- UI: **Material 3** + Google Fonts.
- Tests: **flutter_test** (widget) y **integration_test** (E2E). (La Prueba solicitaba el uso de Jest pero es más para apps basadas en React/ReactNative) flutter ya viene con sus propios test 


## Requisitos
- Flutter SDK (stable).
- Android SDK / Emulador (o dispositivo).
- VS Code (recomendado) o Android Studio.

## Pasos para ejecutar la prueba usando VS Code / Terminal, para evitar usar Android Studio por la demora en la carga del mismo, igualmente tengo experiencia tanto en visual code como Android Studio
1. `flutter pub get`
2. Abrir emulador o conectar dispositivo.
3. `flutter run`  (o usar F5 en VS Code)

No es necesario ejecutar build_runner — los adapters de Hive están hechos manualmente.

## Tests
- Unit & Widget:
  ```bash
  flutter test

## Integration Test
- Unit & Widget:
  ```bash
  flutter test integration_test