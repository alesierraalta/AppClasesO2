# Estructura del Proyecto GymManager

Este documento describe la organización del código fuente para el proyecto GymManager.

## Directorios Principales

### `/app` - Aplicación Principal
- **`/core`**: Núcleo de la aplicación
  - `app.py`: Aplicación Flask principal
  - `sync_config.json`: Configuración de sincronización entre computadoras
  - `.env`: Variables de entorno
- **`/routes`**: Rutas de la aplicación
  - `api_routes.py`: Endpoints de la API
  - `app_routes.py`: Rutas principales de la aplicación
  - `audio_routes.py`: Rutas relacionadas con audio
  - `espectrograma_routes.py`: Rutas de espectrogramas
- **`/models`**: Modelos de datos
  - `models.py`: Definiciones de modelos SQLAlchemy
- **`/utils`**: Utilidades y funciones auxiliares
  - `audio_functions.py`: Funciones de procesamiento de audio
  - `audio_utils.py`: Utilidades para audio
  - `notifications.py`: Sistema de notificaciones
  - `verify_notifications.py`: Verificación de notificaciones
  - `register_audio.py`: Registro de audio
  - `add_waveform_route.py`: Generación de formas de onda
- **`/static`**: Archivos estáticos (CSS, JS, imágenes)
- **`/templates`**: Plantillas HTML de la aplicación
- **`/uploads`**: Archivos subidos por los usuarios

### `/scripts` - Scripts de Automatización
- **`/windows`**: Scripts para Windows
  - `administrar.bat`: Panel de control para Windows
  - `build_app.bat`: Compilación de la aplicación
  - `instalar_gymmanager.bat`: Instalador para Windows
  - `setup_network.bat`: Configuración de red en Windows
  - `verificar_red.bat`: Verificación de conectividad en Windows
  - `run.bat`: Ejecución de la aplicación
  - Otros scripts de prueba y utilidades
- **`/mac`**: Scripts para MacOS
  - `administrar_mac.sh`: Panel de control para Mac
  - `setup_mac.sh`: Configuración para Mac
  - `verificar_red_mac.sh`: Verificación de conectividad en Mac
- **`/common`**: Scripts comunes a todas las plataformas
  - `app_launcher.py`: Punto de entrada para la aplicación
  - `gym_app.spec`: Especificación para PyInstaller

### `/database` - Herramientas de Base de Datos
- `create_tables.py`: Creación de tablas
- `view_tables.py`: Visualización de tablas
- `update_db.py`: Actualización de la base de datos
- `reset_db.py`: Reinicio de la base de datos
- `gimnasio.db`: Archivo SQLite de la base de datos

### `/docs` - Documentación
- `README.md`: Documentación general
- `README_SYNC.md`: Documentación de sincronización
- `README_MAC.md`: Documentación para Mac
- `README_INSTALACION.md`: Guía de instalación

### `/logs` - Archivos de Registro
- `notifications.log`: Registro de notificaciones
- `crash_log.txt`: Registro de errores
- `import_debug.log`: Registro de depuración de importaciones
- `import_errors.log`: Registro de errores de importación

### `/tests` - Pruebas Automatizadas
- **`/unit`**: Pruebas unitarias
- **`/integration`**: Pruebas de integración

## Archivos en la Raíz

- `main.py`: Punto de entrada principal
- `adapt_imports.py`: Script para adaptar importaciones a la nueva estructura
- `reorganize.ps1`: Script PowerShell para reorganizar el proyecto
- `reorganize.txt`: Mapeo de archivos para la reorganización

## Uso de la Aplicación

Para ejecutar la aplicación desde la raíz del proyecto:

```bash
# Desarrollo
python main.py

# Producción en Windows
scripts\windows\run.bat

# Producción en Mac
./scripts/mac/run_gymmanager.sh
```

## Notas sobre la Estructura

Esta estructura sigue el patrón de organización por funcionalidad, agrupando el código según su propósito:

1. El código de la aplicación está en `/app`
2. Las herramientas de desarrollo están en `/scripts`
3. Los datos y herramientas de base de datos están en `/database`
4. Las pruebas están en `/tests`

Esta organización facilita:
- La navegación del código
- La mantenibilidad a largo plazo
- La colaboración entre desarrolladores
- El desarrollo multiplataforma (Windows/Mac) 