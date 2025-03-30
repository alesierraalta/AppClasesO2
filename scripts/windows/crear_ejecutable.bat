@echo off
title Creando Ejecutable de GymManager
color 0A
setlocal enabledelayedexpansion

echo ====================================================================
echo           CREANDO EJECUTABLE DE GYMMANAGER
echo ====================================================================
echo.
echo Este script creará un ejecutable standalone de GymManager
echo que puedes distribuir a las computadoras del gimnasio.
echo.
echo Presiona cualquier tecla para continuar...
pause
cls

:: Determinar ruta del script actual y establecer la instalación portable
set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%..\..\"
set "INSTALL_DIR=%REPO_ROOT%"

:: Eliminar comillas si las hay y asegurar que las rutas terminan con \
set "INSTALL_DIR=!INSTALL_DIR:"=!"
if not "!INSTALL_DIR:~-1!"=="\" set "INSTALL_DIR=!INSTALL_DIR!\"

echo Cambiando al directorio de instalación: !INSTALL_DIR!
cd /d "!INSTALL_DIR!"
if %errorLevel% neq 0 (
    echo ERROR: No se pudo cambiar al directorio !INSTALL_DIR!
    echo Directorio actual: %cd%
    goto ERROR
)

echo Verificando instalación de Python...
where python >nul 2>nul
if %errorLevel% neq 0 (
    echo ERROR: Python no está instalado o no está en el PATH.
    echo Por favor, instale Python antes de continuar.
    goto ERROR
)

:: Instalar PyInstaller si no está instalado
echo Verificando PyInstaller...
python -c "import PyInstaller" 2>nul
if %errorLevel% neq 0 (
    echo Instalando PyInstaller...
    pip install pyinstaller
    if %errorLevel% neq 0 (
        echo ERROR: No se pudo instalar PyInstaller.
        goto ERROR
    )
)

:: Instalar dependencias del proyecto
echo Instalando dependencias del proyecto...
pip install -r requirements.txt
if %errorLevel% neq 0 (
    echo ERROR: No se pudieron instalar las dependencias.
    goto ERROR
)

echo.
echo Creando ejecutable... (esto puede tomar varios minutos)
echo.

:: Crear el ejecutable
pyinstaller --noconfirm --onefile --windowed ^
    --add-data "app;app" ^
    --add-data "static;static" ^
    --add-data "templates;templates" ^
    --hidden-import=sqlite3 ^
    --name GymManager ^
    --icon=static/img/icon.ico ^
    main.py

if %errorLevel% neq 0 (
    echo ERROR: Falló la creación del ejecutable.
    goto ERROR
)

echo.
echo Creando estructura de datos para el ejecutable...

:: Crear directorios para datos locales
mkdir "dist\data\database" 2>nul
mkdir "dist\data\backups" 2>nul
mkdir "dist\data\logs" 2>nul
mkdir "dist\data\uploads" 2>nul
mkdir "dist\data\config" 2>nul

:: Crear archivo de configuración
(
echo {
echo   "install_mode": "executable",
echo   "data_path": "./data/",
echo   "database_path": "./data/database/gimnasio.db"
echo }
) > "dist\data\config\app_config.json"

:: Crear script de configuración de PC
(
echo @echo off
echo setlocal
echo echo Configuración de PC para GymManager
echo echo.
echo echo Este script configurará esta instalación de GymManager.
echo echo.
echo set /p PC_NUM="¿Qué número de PC es esta? (1, 2 o 3): "
echo if "%%PC_NUM%%"=="" set PC_NUM=1
echo if not "%%PC_NUM%%"=="1" if not "%%PC_NUM%%"=="2" if not "%%PC_NUM%%"=="3" (
echo     echo Número no válido. Se usará 1 por defecto.
echo     set PC_NUM=1
echo ^)
echo.
echo echo { "pc_number": %%PC_NUM%%, "is_server": %%PC_NUM%% == 1, "sync_enabled": true } ^> "data\config\pc_config.json"
echo.
echo if not "%%PC_NUM%%"=="1" (
echo     echo Esta PC debe sincronizarse con la PC principal (PC1).
echo     set /p SERVER_IP="Introduce la dirección IP de la PC principal: "
echo     if "%%SERVER_IP%%"=="" (
echo         echo IP no válida. Se usará 192.168.1.100 por defecto.
echo         set SERVER_IP=192.168.1.100
echo     ^)
echo     echo { "server_ip": "%%SERVER_IP%%", "server_port": 5000 } ^> "data\config\network_config.json"
echo     echo Configuración de red guardada.
echo ^) else (
echo     echo Esta PC es la principal. No se requiere configuración adicional.
echo ^)
echo echo.
echo echo Configuración completada. Presione cualquier tecla para salir...
echo pause
) > "dist\ConfigurarPC.bat"

:: Crear script para crear la base de datos por primera vez
copy "database\create_tables.py" "dist\data\database\" /Y >nul
(
echo @echo off
echo echo Creando base de datos inicial...
echo cd /d "%%~dp0"
echo cd ..
echo GymManager.exe --setup-db
echo if %%errorLevel%% neq 0 (
echo     echo Error al crear la base de datos.
echo ^) else (
echo     echo Base de datos creada correctamente.
echo ^)
echo pause
) > "dist\data\database\CrearBaseDatos.bat"

:: Copiar README con instrucciones
(
echo # GymManager - Sistema de Gestión para Gimnasios
echo.
echo ## Instalación
echo.
echo 1. Copie esta carpeta completa a la computadora donde desea instalar GymManager
echo 2. Ejecute "ConfigurarPC.bat" para configurar el número de PC y la sincronización
echo 3. Para la PC principal (PC1), ejecute "data\database\CrearBaseDatos.bat" para crear la base de datos inicial
echo 4. Ejecute "GymManager.exe" para iniciar la aplicación
echo.
echo ## Sincronización
echo.
echo - La PC1 debe ser la primera en configurarse y será el servidor principal
echo - Las PCs 2 y 3 se conectarán automáticamente a la PC1 usando la IP configurada
echo - Todas las PCs deben estar en la misma red local
echo - Para que la sincronización funcione, la PC1 debe estar encendida y con GymManager ejecutándose
echo.
echo ## Notas importantes
echo.
echo - Si mueve la carpeta, deberá volver a ejecutar "ConfigurarPC.bat"
echo - No elimine la carpeta "data" ya que contiene la base de datos y archivos importantes
echo - Se realizan copias de seguridad automáticas en "data\backups" cada día
) > "dist\README.md"

:: Crear un archivo ZIP con todo el paquete
echo.
echo Creando paquete de distribución...
if exist "GymManager_Setup.zip" del "GymManager_Setup.zip"
cd dist
powershell -Command "& {Compress-Archive -Path * -DestinationPath ..\GymManager_Setup.zip -Force}"
cd ..

echo.
echo ====================================================================
echo            ¡EJECUTABLE CREADO EXITOSAMENTE!
echo ====================================================================
echo.
echo El ejecutable se encuentra en:
echo !INSTALL_DIR!dist\GymManager.exe
echo.
echo También se ha creado un paquete completo de distribución en:
echo !INSTALL_DIR!GymManager_Setup.zip
echo.
echo Para distribuir la aplicación:
echo 1. Copie el archivo GymManager_Setup.zip a cada computadora
echo 2. Extraiga el contenido en una carpeta
echo 3. Ejecute ConfigurarPC.bat en cada computadora (PC1 primero)
echo 4. En la PC1, ejecute data\database\CrearBaseDatos.bat
echo 5. Ejecute GymManager.exe para iniciar la aplicación
echo.
echo Presione cualquier tecla para finalizar...
pause
exit /b 0

:ERROR
echo.
echo ====================================================================
echo            ERROR AL CREAR EJECUTABLE
echo ====================================================================
echo.
echo Ha ocurrido un error durante la creación del ejecutable.
echo.
echo Verifique los siguientes puntos:
echo 1. Python está instalado y en el PATH
echo 2. Tiene conexión a Internet para instalar dependencias
echo 3. Tiene permisos de escritura en la carpeta actual
echo.
echo Presione cualquier tecla para salir...
pause
exit /b 1 