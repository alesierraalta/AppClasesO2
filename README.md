# GymManager

Sistema de gestión para gimnasios con múltiples funciones y soporte para redes locales.

## Instalación Local (recomendado)

Para instalar GymManager desde los archivos locales del repositorio, siga estos pasos:

1. Descargue o clone este repositorio en su ordenador
2. Ejecute como administrador el archivo: `scripts/windows/instalar_local.bat`
3. Siga las instrucciones en pantalla para completar la instalación

El instalador local no descarga nada desde Internet, utiliza los archivos que ya ha descargado.

## Actualización Local (recomendado)

Para actualizar GymManager desde los archivos locales del repositorio:

1. Descargue o clone la versión más reciente del repositorio
2. Ejecute como administrador el archivo: `scripts/windows/actualizar_local.bat` 
3. Siga las instrucciones en pantalla para completar la actualización

El actualizador local no descarga nada desde Internet, utiliza los archivos que ya ha descargado.

## Instalación desde GitHub (alternativa)

Si prefiere que el instalador descargue automáticamente el código desde GitHub:

1. Descargue únicamente el archivo: `scripts/windows/instalar_desde_github.bat`
2. Ejecute como administrador dicho archivo
3. Siga las instrucciones en pantalla

## Actualización desde GitHub (alternativa)

Si prefiere que el actualizador descargue automáticamente el código desde GitHub:

1. Descargue únicamente el archivo: `scripts/windows/actualizar_desde_github.bat`
2. Ejecute como administrador dicho archivo
3. Siga las instrucciones en pantalla

## Requisitos

- Windows 7/8/10/11
- Permisos de administrador para la instalación
- Python 3.8 o superior (se instala automáticamente)
- Conexión a Internet (solo para actualizar dependencias)

## Funcionalidades

- Gestión de miembros y clases
- Control de pagos y asistencias
- Sincronización entre múltiples ordenadores
- Copias de seguridad automáticas
- Informes y estadísticas

## Soporte

Para soporte técnico, contacte con el desarrollador.

## Características Principales

- Registro de asistencia de usuarios
- Gestión de membresías y pagos
- Notificaciones automáticas
- Procesamiento de audio para anuncios
- Sincronización entre múltiples equipos
- Soporte multiplataforma (Windows y Mac)

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