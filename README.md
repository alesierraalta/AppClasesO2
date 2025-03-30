# GymManager

Sistema de gestión integral para gimnasios, con funcionalidades de audio y notificaciones.

## Características Principales

- Registro de asistencia de usuarios
- Gestión de membresías y pagos
- Notificaciones automáticas
- Procesamiento de audio para anuncios
- Sincronización entre múltiples equipos
- Soporte multiplataforma (Windows y Mac)

## Instalación

### Instalación Rápida en Windows

Para instalar directamente desde GitHub:

1. **[➡️ DESCARGAR INSTALADOR](https://raw.githubusercontent.com/alesierraalta/AppClasesO2/main/scripts/windows/instalar_desde_github.bat)** - *Haga clic derecho y seleccione "Guardar enlace como..."*
2. Ejecutar `instalar_desde_github.bat` como administrador
3. Seguir las instrucciones en pantalla

Este instalador configurará automáticamente:
- Python (si no está instalado)
- Todas las dependencias necesarias
- La configuración de red para sincronización
- Accesos directos en el escritorio

### Actualizaciones

Para actualizar a la versión más reciente:

1. **[➡️ DESCARGAR ACTUALIZADOR](https://raw.githubusercontent.com/alesierraalta/AppClasesO2/main/scripts/windows/actualizar_desde_github.bat)** - *Haga clic derecho y seleccione "Guardar enlace como..."*
2. Ejecutar `actualizar_desde_github.bat` como administrador
3. Seguir las instrucciones en pantalla

El proceso de actualización preserva todos los datos existentes y configuraciones personalizadas.

## Estructura del Proyecto

Consulte [ESTRUCTURA.md](ESTRUCTURA.md) para una explicación detallada de la organización del código.

## Desarrollo en Mac

Para desarrollar GymManager en un entorno Mac:

1. Clonar el repositorio:
   ```
   git clone https://github.com/alesierraalta/AppClasesO2.git GymManager
   cd GymManager
   ```

2. Configurar entorno virtual:
   ```
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. Ejecutar en modo desarrollo:
   ```
   python main.py --debug
   ```

Para más detalles sobre el flujo de desarrollo, consulte [DESARROLLO_MAC.md](docs/DESARROLLO_MAC.md).

## Uso

Ejecute desde la raíz del proyecto:

```
python main.py
```

O utilice los accesos directos creados en el escritorio:
- `GymManager` - Inicia la aplicación
- `Administrar GymManager` - Herramientas de administración

## Sincronización entre Equipos

Este sistema cuenta con funcionalidad para sincronizar datos entre múltiples computadoras. 
Para más información, consulte [README_SYNC.md](docs/README_SYNC.md).

## Soporte

Para problemas conocidos o asistencia, revise la documentación en el directorio `docs/` o
contacte al administrador del sistema. 