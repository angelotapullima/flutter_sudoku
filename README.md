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

### 📦 Compilación y Despliegue (Release)

Este proyecto utiliza **Flavors** para separar los entornos de Desarrollo y Producción. Es fundamental usar el archivo de entorno (`.json`) correspondiente para que la app apunte al backend y al proyecto de Firebase correcto.

#### 🛠️ Entorno de Desarrollo (Dev - Pruebas Cerradas)
Ideal para subir a Google Play Console en el canal de pruebas internas o cerradas:

```bash
flutter build appbundle --flavor dev --release --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define-from-file=env/dev.json
```

#### 🚀 Entorno de Producción (Prod - Play Store)
Comando oficial para el lanzamiento al público general:

```bash
flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define-from-file=env/prod.json
```

#### 📱 Generación de APK rápido
Si solo necesitas un archivo instalable para pruebas manuales rápidas:

```bash
# APK de Desarrollo
flutter build apk --flavor dev --release --dart-define-from-file=env/dev.json

# APK de Producción
flutter build apk --flavor prod --release --dart-define-from-file=env/prod.json
```
*Los archivos se encontrarán en: `build/app/outputs/flutter-apk/`*

#### 🌐 Web
Para desplegar la versión web en tu servidor:

```bash
# Web de Desarrollo (sudokudev.anked.dev)
flutter build web --release --dart-define-from-file=env/dev.json

# Web de Producción (sudoku.anked.dev)
flutter build web --release --dart-define-from-file=env/prod.json
```
*El resultado se encuentra en: `build/web/`*

---

## 🔔 Configuración de Notificaciones Push (FCM & Web Push)

Este proyecto cuenta con soporte integrado para **Firebase Cloud Messaging (FCM)** en **Android** y **Web**.

### 🌐 Certificado de Web Push (Clave VAPID)

Para que las notificaciones push funcionen en la versión Web en sus respectivos entornos, debes configurar la clave pública **VAPID**:

1. Ve a la **Consola de Firebase** -> **Configuración del proyecto** ⚙️.
2. Abre la pestaña **Cloud Messaging**.
3. Desplázate hasta la sección **Configuración web** (Web configuration).
4. En **Certificados push web**, haz clic en **Generar par de claves**.
5. Copia la clave pública generada y configúrala en el archivo de entorno respectivo:
   - **Desarrollo**: Colócala en el campo `"VAPID_KEY"` dentro de [env/dev.json](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/env/dev.json).
   - **Producción**: Colócala en el campo `"VAPID_KEY"` dentro [env/prod.json](file:///C:/Users/angel/Desktop/flutter/sudoku/flutter_sudoku/env/prod.json).

*(En el archivo `env/local.json`, puedes dejar el campo `"VAPID_KEY": ""` vacío; esto desactivará automáticamente y de forma segura las notificaciones web en local sin arrojar excepciones en tu entorno de depuración).*

---

## 🆔 Información del Proyecto

- **Nombre:** Sudoku Arena
- **Package ID (Android):** `com.anked.dev.sudoku_arena`
- **Flavors:** `dev`, `prod`

---
Desarrollado con ❤️ para los amantes de los acertijos.
