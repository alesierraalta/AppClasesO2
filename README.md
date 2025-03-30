# GymManager

Sistema de gestión integral para gimnasios, con funcionalidades de audio y notificaciones.

## Características Principales

- Registro de asistencia de usuarios
- Gestión de membresías y pagos
- Notificaciones automáticas
- Procesamiento de audio para anuncios
- Sincronización entre múltiples equipos
- Soporte multiplataforma (Windows y Mac)

## Requisitos

- Python 3.8+
- Base de datos SQLite
- Dependencias adicionales (ver `requirements.txt`)

## Instalación

### Windows

```
scripts\windows\instalar_gymmanager.bat
```

### Mac

```
./scripts/mac/setup_mac.sh
```

## Estructura del Proyecto

Consulte [ESTRUCTURA.md](ESTRUCTURA.md) para una explicación detallada de la organización del código.

## Uso

Ejecute desde la raíz del proyecto:

```
python main.py
```

O utilice los scripts específicos de cada plataforma en `scripts/windows` o `scripts/mac`.

## Sincronización entre Equipos

Este sistema cuenta con funcionalidad para sincronizar datos entre múltiples computadoras. 
Para más información, consulte [README_SYNC.md](docs/README_SYNC.md).

## Desarrollo

Para modificar el código:

1. Clone el repositorio
2. Instale las dependencias: `pip install -r requirements.txt`
3. Ejecute la aplicación en modo desarrollo: `python main.py --debug`

## Soporte

Para problemas conocidos o asistencia, revise la documentación en el directorio `docs/` o
contacte al administrador del sistema. 