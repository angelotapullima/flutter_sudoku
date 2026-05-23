# Sudoku Master 🧩

Una experiencia premium de Sudoku desarrollada con Flutter, diseñada para ofrecer una jugabilidad fluida, estética moderna y personalización avanzada.

## 🚀 Guía de Compilación

Para compilar y ejecutar este proyecto correctamente, sigue los pasos a continuación dependiendo de tu plataforma.

### 📋 Requisitos Previos

Asegúrate de tener instalado:
- Flutter SDK (v3.6.1 o superior recomendado)
- Android Studio / Xcode (para emuladores y herramientas de build)
- Java 17 (para Android)

### 🛠️ Preparación del Proyecto

Antes de compilar por primera vez o después de cambios en los assets:

```bash
# Limpiar caché y archivos temporales
flutter clean

# Obtener dependencias
flutter pub get

# Generar iconos de la aplicación
dart run flutter_launcher_icons

# Generar Splash Screen nativo
dart run flutter_native_splash:create
```

### 📱 Ejecución en Desarrollo

Para correr la app en un emulador o dispositivo físico conectado:

```bash
flutter run
```

### 📦 Compilación para Producción (Release)

#### Android
Genera un APK o un App Bundle (para Google Play):

```bash
# Generar APK
flutter build apk --release

# Generar App Bundle (AAB)
flutter build appbundle --release
```
*El resultado se encontrará en: `build/app/outputs/flutter-apk/app-release.apk`*

#### iOS
Requiere macOS y Xcode:

```bash
# Preparar la compilación de iOS
flutter build ios --release
```
*Luego abre `ios/Runner.xcworkspace` en Xcode para archivar y subir a la App Store.*

---

## 🆔 Información del Proyecto

- **Nombre:** Sudoku Master
- **Package ID (Android/iOS):** `com.anked.sudoku_master`
- **Tema Principal:** Azul Océano (#0F62FE)

---
Desarrollado con ❤️ para los amantes de los acertijos.
