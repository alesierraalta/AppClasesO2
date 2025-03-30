@echo off
title Actualizador de GymManager
color 0A
echo ====================================================================
echo                ACTUALIZADOR DE GYMMANAGER
echo ====================================================================
echo.
echo Este script actualizara GymManager a la version mas reciente.
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

:: Detección del modo de actualización (online u offline)
set OFFLINE_MODE=0
if exist "%~dp0GymManager.zip" (
    set OFFLINE_MODE=1
    echo.
    echo Modo OFFLINE: Se usara el archivo local para actualizar.
    copy "%~dp0GymManager.zip" "C:\GymManager\Temp\GymManager.zip" /Y
) else (
    echo.
    echo Modo ONLINE: Descargando la ultima version...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip' -OutFile 'C:\GymManager\Temp\GymManager.zip'}"
    
    if %errorLevel% neq 0 (
        echo Error al descargar la ultima version. Compruebe su conexion a Internet.
        goto ERROR
    )
    echo Descarga completada.
)

:: Extraer los archivos
echo.
echo Extrayendo archivos...
powershell -Command "& {Expand-Archive -Path 'C:\GymManager\Temp\GymManager.zip' -DestinationPath 'C:\GymManager\Temp\' -Force}"

if %OFFLINE_MODE%==1 (
    :: Manejar el ZIP local directamente
    xcopy /E /I /Y "C:\GymManager\Temp\*" "C:\GymManager\Temp\Extract\" /exclude:database\*.db
) else (
    :: Manejar el ZIP de GitHub que contiene una carpeta con el nombre del repositorio
    xcopy /E /I /Y "C:\GymManager\Temp\AppClasesO2-main\*" "C:\GymManager\Temp\Extract\" /exclude:database\*.db
)

:: Guardar información de configuración actual
set PC_NUMBER=1
if exist "C:\GymManager\app\core\pc_config.json" (
    for /f "tokens=2 delims=:," %%a in ('type "C:\GymManager\app\core\pc_config.json" ^| findstr "pc_number"') do (
        set PC_NUMBER=%%a
        set PC_NUMBER=!PC_NUMBER: =!
    )
)

:: Actualizar archivos (excepto datos y configuración)
echo.
echo Actualizando archivos del sistema...
xcopy /E /I /Y "C:\GymManager\Temp\Extract\*" "C:\GymManager\" /exclude:C:\GymManager\Temp\exclude_list.txt

:: Restaurar configuraciones
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