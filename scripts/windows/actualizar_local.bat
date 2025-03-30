@echo off
title Actualizador Local de GymManager
color 0A
echo ====================================================================
echo           ACTUALIZADOR LOCAL DE GYMMANAGER
echo ====================================================================
echo.
echo Este script actualizará GymManager usando los archivos del repositorio local.
echo Se conservarán todos los datos existentes.
echo No se descargará nada desde Internet.
echo.
echo Presiona cualquier tecla para continuar...
pause
cls

:: Verificar si se está ejecutando como administrador
echo Verificando permisos de administrador...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ¡ERROR! Este script requiere permisos de administrador.
    echo Por favor, cierre esta ventana y ejecute el archivo como administrador:
    echo - Click derecho en el archivo
    echo - Seleccione "Ejecutar como administrador"
    echo.
    echo Presione cualquier tecla para salir...
    pause
    exit /b 1
)
echo OK - Ejecutando con permisos de administrador.
echo.

:: Verificar que GymManager esté instalado
echo Verificando instalación de GymManager...
if not exist "C:\GymManager" (
    echo.
    echo ¡ERROR! GymManager no parece estar instalado en esta computadora.
    echo Ejecute primero el instalador completo.
    echo.
    echo Presione cualquier tecla para salir...
    pause
    exit /b 1
)
echo OK - GymManager encontrado en C:\GymManager
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Crear directorio temporal
echo Creando directorio temporal...
mkdir "C:\GymManager\Temp" 2>nul
cd "C:\GymManager"
echo Directorio temporal creado.
echo.

:: Hacer copia de seguridad de datos importantes
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
echo.

echo Presione cualquier tecla para continuar con la actualización...
pause
cls

:: Determinar ruta del script actual
set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%..\..\"

:: Verificar que estamos en el repositorio
if not exist "%REPO_ROOT%\main.py" (
    echo.
    echo ¡ERROR! No se encontró el archivo main.py en el repositorio.
    echo Asegúrese de ejecutar este script desde el directorio correcto:
    echo scripts\windows\actualizar_local.bat
    echo.
    goto ERROR
)

:: Crear lista de exclusión temporal
echo Preparando lista de archivos a preservar...
if not exist "C:\GymManager\Temp\exclude_list.txt" (
    echo database\gimnasio.db > "C:\GymManager\Temp\exclude_list.txt"
    echo app\core\pc_config.json >> "C:\GymManager\Temp\exclude_list.txt"
    echo app\core\network_config.json >> "C:\GymManager\Temp\exclude_list.txt"
    echo app\core\sync_config.json >> "C:\GymManager\Temp\exclude_list.txt"
    echo app\core\.env >> "C:\GymManager\Temp\exclude_list.txt"
    echo app\uploads\* >> "C:\GymManager\Temp\exclude_list.txt"
    echo logs\* >> "C:\GymManager\Temp\exclude_list.txt"
    echo Backups\* >> "C:\GymManager\Temp\exclude_list.txt"
    echo Temp\* >> "C:\GymManager\Temp\exclude_list.txt"
)
echo Lista de exclusión preparada.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Actualizar archivos (excepto datos y configuración)
echo Actualizando archivos del sistema...
echo Copiando desde: %REPO_ROOT%
echo A: C:\GymManager
>nul 2>nul xcopy /E /I /Y "%REPO_ROOT%\*" "C:\GymManager\" /exclude:C:\GymManager\Temp\exclude_list.txt
if %errorLevel% neq 0 (
    echo ¡ERROR! No se pudieron copiar los archivos.
    goto ERROR
)
echo Archivos del sistema actualizados correctamente.
echo.

:: Restaurar configuraciones (por si acaso se sobrescribieron)
echo Restaurando su configuración...
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
echo Configuración restaurada correctamente.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Ejecutar script de actualización de base de datos
echo Actualizando estructura de base de datos...
if exist "C:\GymManager\database\update_db.py" (
    python "C:\GymManager\database\update_db.py"
    
    if %errorLevel% neq 0 (
        echo.
        echo Advertencia: No se pudo actualizar la estructura de la base de datos.
        echo El sistema podría no funcionar correctamente.
        echo Recibirá ayuda la próxima vez que inicie la aplicación.
    ) else (
        echo Base de datos actualizada exitosamente.
    )
) else (
    echo.
    echo Advertencia: No se encontró el script de actualización de base de datos.
    echo Este paso se omitirá y no debería afectar la funcionalidad.
)
echo.

:: Actualizar dependencias si hay cambios
echo Verificando dependencias...
if exist "C:\GymManager\requirements.txt" (
    pip install -r "C:\GymManager\requirements.txt" --upgrade
    
    if %errorLevel% neq 0 (
        echo.
        echo Advertencia: No se pudieron actualizar algunas dependencias.
        echo El sistema podría no funcionar correctamente.
        echo Intente ejecutar manualmente: pip install -r requirements.txt
    ) else (
        echo Dependencias actualizadas exitosamente.
    )
) else (
    echo.
    echo Advertencia: No se encontró el archivo de requisitos.
    echo Este paso se omitirá y no debería afectar la funcionalidad.
)
echo.

:: Limpiar archivos temporales
echo Limpiando archivos temporales...
rd /s /q "C:\GymManager\Temp" 2>nul
echo Archivos temporales eliminados.
echo.

echo Presione cualquier tecla para finalizar...
pause
cls

:: Finalización
echo ====================================================================
echo           ACTUALIZACION COMPLETADA EXITOSAMENTE
echo ====================================================================
echo.
echo GymManager ha sido actualizado a la versión más reciente.
echo.
echo Todos sus datos y configuraciones han sido preservados.
echo Se ha creado una copia de seguridad en:
echo C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\
echo.
echo Para iniciar GymManager, use el acceso directo del escritorio.
echo.
echo Presione cualquier tecla para finalizar...
pause
exit /b 0

:ERROR
echo.
echo ====================================================================
echo                   ERROR EN LA ACTUALIZACION
echo ====================================================================
echo.
echo Ha ocurrido un error durante la actualización.
echo.
echo Sus datos originales están a salvo en la carpeta de respaldo:
echo C:\GymManager\Backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\
echo.
echo Intente los siguientes pasos:
echo 1. Asegúrese de ejecutar el script como administrador
echo 2. Verifique que Python está instalado correctamente
echo 3. Compruebe que está ejecutando el script desde el directorio correcto
echo 4. Si el problema persiste, contacte al soporte técnico
echo.
echo Presione cualquier tecla para salir...
pause
exit /b 1 