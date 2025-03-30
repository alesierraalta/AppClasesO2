@echo off
echo ======================================
echo  GymManager - Compilacion de la App
echo ======================================
echo.

echo Iniciando entorno virtual...
if not exist venv (
    echo Creando entorno virtual...
    python -m venv venv
)

call venv\Scripts\activate

echo Instalando dependencias...
pip install -r requirements.txt

echo Creando directorios necesarios...
if not exist static (
    mkdir static
)
if not exist backups (
    mkdir backups
)
if not exist uploads (
    mkdir uploads
)

echo Limpiando compilaciones anteriores...
if exist dist (
    rmdir /s /q dist
)
if exist build (
    rmdir /s /q build
)

echo Verificando archivo de configuración...
if not exist sync_config.json (
    echo Creando archivo de configuración por defecto...
    echo {> sync_config.json
    echo     "sync_interval": 300,>> sync_config.json
    echo     "is_primary_server": false,>> sync_config.json
    echo     "sync_servers": [>> sync_config.json
    echo         "http://192.168.1.100:5000/sync",>> sync_config.json
    echo         "http://192.168.1.101:5000/sync",>> sync_config.json
    echo         "http://192.168.1.102:5000/sync">> sync_config.json
    echo     ],>> sync_config.json
    echo     "server_name": "Recepción",>> sync_config.json
    echo     "backup_folder": "backups">> sync_config.json
    echo }>> sync_config.json
)

echo Compilando la aplicación con PyInstaller...
pyinstaller --clean gym_app.spec

echo.
echo ======================================
echo      Compilación completada!
echo ======================================
echo.
echo El ejecutable se encuentra en: dist\GymManager.exe
echo.
echo IMPORTANTE: 
echo 1. Configura el archivo sync_config.json con las IPs correctas
echo 2. Establece is_primary_server como true en la computadora principal
echo 3. Para más información, lee el archivo README_SYNC.md
echo.
echo Para ejecutar la aplicación, haz doble clic en dist\GymManager.exe
echo.

pause 