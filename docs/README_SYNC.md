# GymManager - Aplicación de Escritorio Sincronizada

Esta es una aplicación de escritorio para gestión de un gimnasio que permite la sincronización de datos entre múltiples computadoras.

## Características principales

- Interfaz de usuario intuitiva basada en web pero ejecutada como aplicación de escritorio
- Sincronización automática de la base de datos entre las computadoras
- Respaldo automático antes de cada sincronización
- Configuración sencilla mediante archivo JSON

## Instalación

1. Asegúrate de que todas las computadoras estén en la misma red local
2. Descarga el instalador de la aplicación
3. Ejecuta el instalador en cada computadora
4. Después de la instalación, configura el archivo `sync_config.json` en cada computadora

## Configuración de sincronización

La sincronización se configura a través del archivo `sync_config.json`, que se encuentra en la carpeta principal de la aplicación:

```json
{
    "sync_interval": 300,
    "is_primary_server": false,
    "sync_servers": [
        "http://192.168.1.100:5000/sync",
        "http://192.168.1.101:5000/sync",
        "http://192.168.1.102:5000/sync"
    ],
    "server_name": "Recepción 1",
    "backup_folder": "backups"
}
```

### Parámetros de configuración:

- `sync_interval`: Intervalo de sincronización en segundos (por defecto: 300 = 5 minutos)
- `is_primary_server`: Define si esta computadora es el servidor principal (solo debe haber uno)
- `sync_servers`: Lista de direcciones IP de todas las computadoras con el formato `http://IP:5000/sync`
- `server_name`: Nombre de identificación para esta computadora
- `backup_folder`: Carpeta donde se guardarán los respaldos de la base de datos

## Configuración paso a paso

1. Determina qué computadora será el servidor principal (generalmente la de la gerencia)
2. Obtén las direcciones IP de cada computadora (puedes usar el comando `ipconfig` en Windows)
3. Configura el archivo `sync_config.json` en cada computadora:
   - En el servidor principal, establece `"is_primary_server": true`
   - En las demás computadoras, establece `"is_primary_server": false`
   - En todas las computadoras, actualiza la lista `sync_servers` con las IPs correctas
   - Asigna un nombre único a cada computadora en `server_name`

## Ejecutar la aplicación

1. Inicia la aplicación haciendo doble clic en el icono de GymManager en el escritorio
2. La aplicación se iniciará y mostrará la interfaz web en una ventana de escritorio
3. La sincronización se realizará automáticamente según el intervalo configurado

## Solución de problemas

### Errores de sincronización

- Verifica que todas las computadoras estén encendidas y conectadas a la misma red
- Comprueba que las direcciones IP en `sync_config.json` sean correctas
- Verifica que no haya firewalls bloqueando la comunicación

### Fallos en la base de datos

- Los respaldos automáticos se guardan en la carpeta `backups`
- Si necesitas restaurar una copia de seguridad, simplemente copia el archivo de respaldo y renómbralo a `gimnasio.db`

## Soporte

Para obtener ayuda adicional, contacta al soporte técnico. 