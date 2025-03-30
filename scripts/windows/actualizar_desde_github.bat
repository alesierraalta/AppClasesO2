@echo off
title Actualizador de GymManager desde GitHub
color 0A
echo ====================================================================
echo           ACTUALIZADOR DE GYMMANAGER DESDE GITHUB
echo ====================================================================
echo.
echo Este script actualizara GymManager a la version mas reciente desde GitHub.
echo Se conservaran todos los datos existentes.
echo.
echo Presiona cualquier tecla para continuar...
pause > nul
cls

:: Verificar si se está ejecutando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script requiere permisos de administrador.
    echo Por favor, ejecute este archivo como administrador.
    echo Click derecho + "Ejecutar como administrador"
    echo.
    pause
    exit /b 1
)

:: Verificar que GymManager esté instalado
if not exist "C:\GymManager" (
    echo.
    echo Error: GymManager no parece estar instalado en esta computadora.
    echo Ejecute primero el instalador completo.
    echo.
    pause
    exit /b 1
)

:: Crear directorio temporal
echo Creando directorio temporal...
mkdir "C:\GymManager\Temp" 2>nul
cd "C:\GymManager"

:: Hacer copia de seguridad de datos importantes
echo.
echo Haciendo copia de seguridad de sus datos...
mkdir "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%" 2>nul
if exist "C:\GymManager\database\gimnasio.db" (
    copy "C:\GymManager\database\gimnasio.db" "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\gimnasio.db" /Y
)
if exist "C:\GymManager\app\core\pc_config.json" (
    copy "C:\GymManager\app\core\pc_config.json" "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\pc_config.json" /Y
)
if exist "C:\GymManager\app\core\network_config.json" (
    copy "C:\GymManager\app\core\network_config.json" "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\network_config.json" /Y
)
if exist "C:\GymManager\app\core\sync_config.json" (
    copy "C:\GymManager\app\core\sync_config.json" "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\sync_config.json" /Y
)
if exist "C:\GymManager\app\core\.env" (
    copy "C:\GymManager\app\core\.env" "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\.env" /Y
)
echo Copia de seguridad creada en C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\

:: Descargar la versión más reciente desde GitHub
echo.
echo Descargando la ultima version desde GitHub...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip' -OutFile 'C:\GymManager\Temp\GymManager.zip'}"

if %errorLevel% neq 0 (
    echo Error al descargar la ultima version. Compruebe su conexion a Internet.
    goto ERROR
)
echo Descarga completada.

:: Extraer los archivos
echo.
echo Extrayendo archivos...
powershell -Command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('C:\GymManager\Temp\GymManager.zip', 'C:\GymManager\Temp', $true)}"

:: Crear lista de exclusión temporal si no existe
if not exist "C:\GymManager\Temp\exclude_list.txt" (
    echo database\gimnasio.db > "C:\GymManager\Temp\exclude_list.txt"
    echo app\core\pc_config.json >> "C:\GymManager\Temp\exclude_list.txt"
    echo app\core\network_config.json >> "C:\GymManager\Temp\exclude_list.txt"
    echo app\core\sync_config.json >> "C:\GymManager\Temp\exclude_list.txt"
    echo app\core\.env >> "C:\GymManager\Temp\exclude_list.txt"
    echo app\uploads\* >> "C:\GymManager\Temp\exclude_list.txt"
    echo logs\* >> "C:\GymManager\Temp\exclude_list.txt"
    echo Backups\* >> "C:\GymManager\Temp\exclude_list.txt"
)

:: Actualizar archivos (excepto datos y configuración)
echo.
echo Actualizando archivos del sistema...
xcopy /E /I /Y "C:\GymManager\Temp\AppClasesO2-main\*" "C:\GymManager\" /exclude:C:\GymManager\Temp\exclude_list.txt

:: Restaurar configuraciones (por si acaso se sobrescribieron)
echo.
echo Restaurando su configuracion...
if exist "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\pc_config.json" (
    copy "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\pc_config.json" "C:\GymManager\app\core\pc_config.json" /Y
)
if exist "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\network_config.json" (
    copy "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\network_config.json" "C:\GymManager\app\core\network_config.json" /Y
)
if exist "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\sync_config.json" (
    copy "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\sync_config.json" "C:\GymManager\app\core\sync_config.json" /Y
)
if exist "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\.env" (
    copy "C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\.env" "C:\GymManager\app\core\.env" /Y
)

:: Ejecutar script de actualización de base de datos
echo.
echo Actualizando estructura de base de datos...
if exist "C:\GymManager\database\update_db.py" (
    python "C:\GymManager\database\update_db.py"
    
    if %errorLevel% neq 0 (
        echo Advertencia: No se pudo actualizar la estructura de la base de datos.
        echo El sistema podria no funcionar correctamente.
    ) else (
        echo Base de datos actualizada exitosamente.
    )
) else (
    echo Advertencia: No se encontró el script de actualización de base de datos.
)

:: Actualizar dependencias si hay cambios
echo.
echo Verificando dependencias...
if exist "C:\GymManager\requirements.txt" (
    pip install -r "C:\GymManager\requirements.txt" --upgrade
    
    if %errorLevel% neq 0 (
        echo Advertencia: No se pudieron actualizar algunas dependencias.
        echo El sistema podria no funcionar correctamente.
    ) else (
        echo Dependencias actualizadas exitosamente.
    )
) else (
    echo Advertencia: No se encontró el archivo de requisitos.
)

:: Limpiar archivos temporales
echo.
echo Limpiando archivos temporales...
rd /s /q "C:\GymManager\Temp" 2>nul
echo Archivos temporales eliminados.

:: Finalización
cls
echo ====================================================================
echo           ACTUALIZACION COMPLETADA EXITOSAMENTE
echo ====================================================================
echo.
echo GymManager ha sido actualizado a la version mas reciente.
echo.
echo Todos sus datos y configuraciones han sido preservados.
echo Se ha creado una copia de seguridad en:
echo C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\
echo.
echo Presione cualquier tecla para finalizar...
pause > nul
exit /b 0

:ERROR
echo.
echo ====================================================================
echo                   ERROR EN LA ACTUALIZACION
echo ====================================================================
echo.
echo Ha ocurrido un error durante la actualizacion.
echo.
echo Sus datos originales estan a salvo en la carpeta de respaldo:
echo C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\
echo.
echo Intente los siguientes pasos:
echo 1. Asegurese de tener conexion a Internet
echo 2. Ejecute el actualizador como administrador
echo 3. Si el problema persiste, contacte al soporte tecnico
echo.
echo Presione cualquier tecla para salir...
pause > nul
exit /b 1 