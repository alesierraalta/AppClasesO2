@echo off
title Actualizador Portable de GymManager
color 0A
echo ====================================================================
echo            ACTUALIZADOR PORTABLE DE GYMMANAGER
echo ====================================================================
echo.
echo Este script actualizará GymManager en modo portable
echo preservando todos sus datos existentes.
echo.
echo Presiona cualquier tecla para continuar...
pause
cls

:: Determinar ruta del script actual
set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%..\..\"
set "INSTALL_DIR=%REPO_ROOT%"
cd "%REPO_ROOT%"

echo Actualizando GymManager en modo portable en:
echo %INSTALL_DIR%
echo.

:: Verificar que estamos en el repositorio
if not exist "%REPO_ROOT%\main.py" (
    echo.
    echo ¡ERROR! No se encontró el archivo main.py en el repositorio.
    echo Asegúrese de ejecutar este script desde la carpeta correcta:
    echo scripts\windows\actualizar_portable.bat
    echo.
    goto ERROR
)

:: Verificar la existencia de directorios de datos
echo Verificando la estructura del repositorio...
if not exist "%INSTALL_DIR%\app\core" (
    echo.
    echo ¡ERROR! No se encontró la estructura de archivos necesaria.
    echo Asegúrese de que GymManager se ha instalado correctamente.
    echo Ejecute primero instalar_portable.bat si aún no lo ha hecho.
    echo.
    goto ERROR
)
echo Estructura verificada correctamente.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Crear directorio temporal
echo Creando directorio temporal...
mkdir "%INSTALL_DIR%\temp" 2>nul
echo Directorio temporal creado.
echo.

:: Hacer copia de seguridad de datos importantes
echo Haciendo copia de seguridad de sus datos...
mkdir "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%" 2>nul
if exist "%INSTALL_DIR%\database\gimnasio.db" (
    copy "%INSTALL_DIR%\database\gimnasio.db" "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\gimnasio.db" /Y
)
if exist "%INSTALL_DIR%\app\core\pc_config.json" (
    copy "%INSTALL_DIR%\app\core\pc_config.json" "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\pc_config.json" /Y
)
if exist "%INSTALL_DIR%\app\core\network_config.json" (
    copy "%INSTALL_DIR%\app\core\network_config.json" "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\network_config.json" /Y
)
if exist "%INSTALL_DIR%\app\core\sync_config.json" (
    copy "%INSTALL_DIR%\app\core\sync_config.json" "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\sync_config.json" /Y
)
if exist "%INSTALL_DIR%\app\core\.env" (
    copy "%INSTALL_DIR%\app\core\.env" "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\.env" /Y
)
if exist "%INSTALL_DIR%\app\core\install_config.json" (
    copy "%INSTALL_DIR%\app\core\install_config.json" "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\install_config.json" /Y
)
echo Copia de seguridad creada en %INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\
echo.

echo Presione cualquier tecla para continuar con la actualización...
pause
cls

:: Determinar el origen de la actualización
echo Verificando origen de la actualización...
set "UPDATE_SOURCE=%~dp0..\..\..\nueva_version"
if exist "%UPDATE_SOURCE%\main.py" (
    echo Se utilizará el directorio de nueva versión encontrado en:
    echo %UPDATE_SOURCE%
) else (
    echo No se encontró un directorio de nueva versión externo.
    echo Se usará la misma ubicación actual para la actualización in-situ.
    set "UPDATE_SOURCE=%REPO_ROOT%"
)
echo.

:: Crear lista de exclusión temporal
echo Preparando lista de archivos a preservar...
echo database\gimnasio.db > "%INSTALL_DIR%\temp\exclude_list.txt"
echo app\core\pc_config.json >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo app\core\network_config.json >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo app\core\sync_config.json >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo app\core\install_config.json >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo app\core\.env >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo app\uploads\* >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo logs\* >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo backups\* >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo temp\* >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo GymManager.bat >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo Administrar.bat >> "%INSTALL_DIR%\temp\exclude_list.txt"
echo Lista de exclusión preparada.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Actualizar archivos (excepto datos y configuración)
echo Actualizando archivos del sistema...
if "%UPDATE_SOURCE%" NEQ "%REPO_ROOT%" (
    echo Copiando desde: %UPDATE_SOURCE%
    echo A: %INSTALL_DIR%
    xcopy /E /I /Y "%UPDATE_SOURCE%\*" "%INSTALL_DIR%\" /exclude:"%INSTALL_DIR%\temp\exclude_list.txt"
    if %errorLevel% neq 0 (
        echo ¡ERROR! No se pudieron copiar los archivos.
        goto ERROR
    )
) else (
    echo Realizando actualización in-situ...
    echo No se encontró directorio externo con nueva versión.
    echo Omitiendo paso de actualización de archivos.
)
echo Archivos del sistema actualizados correctamente.
echo.

:: Restaurar configuraciones (por si acaso se sobrescribieron)
echo Restaurando su configuración...
if exist "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\pc_config.json" (
    copy "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\pc_config.json" "%INSTALL_DIR%\app\core\pc_config.json" /Y
)
if exist "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\network_config.json" (
    copy "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\network_config.json" "%INSTALL_DIR%\app\core\network_config.json" /Y
)
if exist "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\sync_config.json" (
    copy "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\sync_config.json" "%INSTALL_DIR%\app\core\sync_config.json" /Y
)
if exist "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\.env" (
    copy "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\.env" "%INSTALL_DIR%\app\core\.env" /Y
)
if exist "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\install_config.json" (
    copy "%INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\install_config.json" "%INSTALL_DIR%\app\core\install_config.json" /Y
)
echo Configuración restaurada correctamente.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Ejecutar script de actualización de base de datos
echo Actualizando estructura de base de datos...
cd "%INSTALL_DIR%"
if exist "%INSTALL_DIR%\database\update_db.py" (
    python "database\update_db.py"
    
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
if exist "%INSTALL_DIR%\requirements.txt" (
    pip install -r "%INSTALL_DIR%\requirements.txt" --upgrade
    
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

:: Verificar y recrear accesos directos portables
echo Verificando accesos directos portables...
if not exist "%INSTALL_DIR%\GymManager.bat" (
    echo @echo off > "%INSTALL_DIR%\GymManager.bat"
    echo cd "%INSTALL_DIR%" >> "%INSTALL_DIR%\GymManager.bat"
    echo python main.py >> "%INSTALL_DIR%\GymManager.bat"
    echo pause >> "%INSTALL_DIR%\GymManager.bat"
    echo Acceso directo principal creado.
)

if not exist "%INSTALL_DIR%\Administrar.bat" (
    echo @echo off > "%INSTALL_DIR%\Administrar.bat"
    echo call "%INSTALL_DIR%\scripts\windows\administrar_portable.bat" >> "%INSTALL_DIR%\Administrar.bat"
    echo Acceso directo de administración creado.
)
echo Accesos directos verificados.
echo.

:: Limpiar archivos temporales
echo Limpiando archivos temporales...
rd /s /q "%INSTALL_DIR%\temp" 2>nul
echo Archivos temporales eliminados.
echo.

echo Presione cualquier tecla para finalizar...
pause
cls

:: Finalización
echo ====================================================================
echo        ACTUALIZACION PORTABLE COMPLETADA EXITOSAMENTE
echo ====================================================================
echo.
echo GymManager ha sido actualizado en modo portable en:
echo %INSTALL_DIR%
echo.
echo Todos sus datos y configuraciones han sido preservados.
echo Se ha creado una copia de seguridad en:
echo %INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\
echo.
echo Para iniciar GymManager, use el archivo:
echo - GymManager.bat (en la carpeta principal)
echo.
echo Presione cualquier tecla para finalizar...
pause
exit /b 0

:ERROR
echo.
echo ====================================================================
echo              ERROR EN LA ACTUALIZACION PORTABLE
echo ====================================================================
echo.
echo Ha ocurrido un error durante la actualización portable.
echo.
echo Sus datos originales están a salvo en la carpeta de respaldo:
echo %INSTALL_DIR%\backups\%date:~-4,4%%date:~-7,2%%date:~-10,2%\
echo.
echo Intente los siguientes pasos:
echo 1. Verifique que Python está instalado correctamente
echo 2. Compruebe que está ejecutando el script desde el directorio correcto
echo 3. Asegúrese de tener permisos de escritura en la carpeta actual
echo 4. Si el problema persiste, contacte al soporte técnico
echo.
echo Presione cualquier tecla para salir...
pause
exit /b 1 