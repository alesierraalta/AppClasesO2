@echo off
title Instalador Local de GymManager
color 0A
echo ====================================================================
echo               INSTALADOR LOCAL DE GYMMANAGER
echo ====================================================================
echo.
echo Este script instalará GymManager desde los archivos del repositorio local.
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

:: Crear directorios de instalación
echo Creando directorios de instalacion...
mkdir "C:\GymManager" 2>nul
if %errorLevel% neq 0 (
    echo ¡ERROR! No se pudo crear el directorio C:\GymManager
    echo Asegúrese de tener permisos de escritura en C:\
    goto ERROR
)
mkdir "C:\GymManager\Logs" 2>nul
mkdir "C:\GymManager\Backups" 2>nul
mkdir "C:\GymManager\Temp" 2>nul
echo Directorios creados correctamente.
echo.

echo Presione cualquier tecla para continuar con la instalación...
pause
cls

:: Verificar si Python está instalado
echo Verificando instalacion de Python...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo Python no está instalado en su sistema.
    echo.
    echo Necesita instalar Python 3.8 o superior:
    echo 1. Descargue Python desde www.python.org/downloads/
    echo 2. Al instalar, marque la opción "Add Python to PATH"
    echo 3. Después de instalar Python, ejecute este script nuevamente
    echo.
    echo Presione cualquier tecla para salir...
    pause
    exit /b 1
) else (
    echo Python ya está instalado en el sistema.
)
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Copiar archivos desde el repositorio local
echo Copiando archivos al directorio de instalación...

:: Determinar ruta del script actual
set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%..\..\"

:: Verificar que estamos en el repositorio
if not exist "%REPO_ROOT%\main.py" (
    echo.
    echo ¡ERROR! No se encontró el archivo main.py en el repositorio.
    echo Asegúrese de ejecutar este script desde el directorio correcto:
    echo scripts\windows\instalar_local.bat
    echo.
    goto ERROR
)

:: Copiar todos los archivos del repositorio excepto .git
echo Copiando archivos desde: %REPO_ROOT%
echo A: C:\GymManager
xcopy /E /I /Y "%REPO_ROOT%\*" "C:\GymManager\" /EXCLUDE:%REPO_ROOT%\.git\*
if %errorLevel% neq 0 (
    echo ¡ERROR! No se pudieron copiar los archivos.
    goto ERROR
)
echo Archivos copiados correctamente.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Instalar dependencias de Python
echo Instalando dependencias de Python...
cd C:\GymManager
if not exist "C:\GymManager\requirements.txt" (
    echo ¡ERROR! No se encontró el archivo requirements.txt
    goto ERROR
)

python -m pip install --upgrade pip
if %errorLevel% neq 0 (
    echo ¡ERROR! No se pudo actualizar pip.
    goto ERROR
)

pip install -r requirements.txt
if %errorLevel% neq 0 (
    echo.
    echo ¡ERROR! No se pudieron instalar las dependencias.
    echo - Verifique su conexión a Internet
    echo - Asegúrese de que Python se instaló correctamente
    goto ERROR
)
echo Dependencias instaladas correctamente.
echo.

echo Presione cualquier tecla para continuar con la configuración...
pause
cls

:: Configuración específica del equipo
echo ====================================================================
echo               CONFIGURACION DE ESTE EQUIPO
echo ====================================================================
echo.
echo Necesitamos configurar este equipo para el sistema GymManager.
echo.

:: Preguntar número de PC
set /p PC_NUM="¿Qué número de PC es esta? (1, 2 o 3): "
echo.

:: Validar entrada
if "%PC_NUM%"=="" set PC_NUM=1
if not "%PC_NUM%"=="1" if not "%PC_NUM%"=="2" if not "%PC_NUM%"=="3" (
    echo Número no válido. Se usará 1 por defecto.
    set PC_NUM=1
)

:: Asegurarse de que el directorio existe
if not exist "C:\GymManager\app\core" (
    mkdir "C:\GymManager\app\core" 2>nul
)

:: Configurar archivos
echo { "pc_number": %PC_NUM%, "is_server": %PC_NUM% == 1, "sync_enabled": true } > "C:\GymManager\app\core\pc_config.json"

:: Configurar sincronización si no es la PC principal
if not "%PC_NUM%"=="1" (
    echo.
    echo Esta PC debe sincronizarse con la PC principal (PC1).
    echo.
    set /p SERVER_IP="Introduce la dirección IP de la PC principal: "
    echo.
    
    if "%SERVER_IP%"=="" (
        echo IP no válida. Se usará 192.168.1.100 por defecto.
        set SERVER_IP=192.168.1.100
    )
    
    echo { "server_ip": "%SERVER_IP%", "server_port": 5000 } > "C:\GymManager\app\core\network_config.json"
    echo Configuración de red guardada.
) else (
    echo Esta PC es la principal. No se requiere configuración adicional.
)
echo.

:: Crear base de datos si no existe
echo Configurando base de datos...
if not exist "C:\GymManager\database\gimnasio.db" (
    if not exist "C:\GymManager\database" (
        mkdir "C:\GymManager\database" 2>nul
    )
    
    cd C:\GymManager
    if exist "C:\GymManager\database\create_tables.py" (
        python database\create_tables.py
        
        if %errorLevel% neq 0 (
            echo ¡ERROR! No se pudo crear la base de datos.
            echo Se creará la próxima vez que inicie la aplicación.
        ) else (
            echo Base de datos creada correctamente.
        )
    ) else (
        echo No se encontró el script de creación de base de datos.
        echo Se creará la próxima vez que inicie la aplicación.
    )
) else (
    echo Base de datos ya existe.
)
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Crear accesos directos
echo Creando accesos directos...

:: Verificar si existe el archivo run.bat
if not exist "C:\GymManager\scripts\windows\run.bat" (
    echo @echo off > "C:\GymManager\scripts\windows\run.bat"
    echo cd C:\GymManager >> "C:\GymManager\scripts\windows\run.bat"
    echo python main.py >> "C:\GymManager\scripts\windows\run.bat"
    echo pause >> "C:\GymManager\scripts\windows\run.bat"
)

:: Verificar si existe el archivo administrar.bat
if not exist "C:\GymManager\scripts\windows\administrar.bat" (
    echo @echo off > "C:\GymManager\scripts\windows\administrar.bat"
    echo echo ===== PANEL DE ADMINISTRACION ===== >> "C:\GymManager\scripts\windows\administrar.bat"
    echo echo. >> "C:\GymManager\scripts\windows\administrar.bat"
    echo echo 1. Iniciar GymManager >> "C:\GymManager\scripts\windows\administrar.bat"
    echo echo 2. Actualizar GymManager >> "C:\GymManager\scripts\windows\administrar.bat"
    echo echo 3. Verificar base de datos >> "C:\GymManager\scripts\windows\administrar.bat"
    echo echo 4. Salir >> "C:\GymManager\scripts\windows\administrar.bat"
    echo echo. >> "C:\GymManager\scripts\windows\administrar.bat"
    echo set /p opcion="Seleccione una opcion: " >> "C:\GymManager\scripts\windows\administrar.bat"
    echo. >> "C:\GymManager\scripts\windows\administrar.bat"
    echo if "%%opcion%%"=="1" (cd C:\GymManager ^& python main.py) >> "C:\GymManager\scripts\windows\administrar.bat"
    echo if "%%opcion%%"=="2" (echo Actualizando... ^& C:\GymManager\scripts\windows\actualizar_local.bat) >> "C:\GymManager\scripts\windows\administrar.bat"
    echo if "%%opcion%%"=="3" (cd C:\GymManager ^& python database\view_tables.py ^& pause) >> "C:\GymManager\scripts\windows\administrar.bat"
    echo if "%%opcion%%"=="4" exit >> "C:\GymManager\scripts\windows\administrar.bat"
    echo. >> "C:\GymManager\scripts\windows\administrar.bat"
)

:: Crear los accesos directos
>nul 2>nul powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\GymManager.lnk'); $Shortcut.TargetPath = 'C:\GymManager\scripts\windows\run.bat'; $Shortcut.WorkingDirectory = 'C:\GymManager'; $Shortcut.Save()"
>nul 2>nul powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\GymManager.lnk'); $Shortcut.TargetPath = 'C:\GymManager\scripts\windows\run.bat'; $Shortcut.WorkingDirectory = 'C:\GymManager'; $Shortcut.Save()"
>nul 2>nul powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Administrar GymManager.lnk'); $Shortcut.TargetPath = 'C:\GymManager\scripts\windows\administrar.bat'; $Shortcut.WorkingDirectory = 'C:\GymManager'; $Shortcut.Save()"

:: Configurar inicio automático si se desea
echo.
set /p AUTO_START="¿Desea que GymManager se inicie automáticamente al encender la computadora? (S/N): "
if /i "%AUTO_START%"=="S" (
    >nul 2>nul powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\GymManager.lnk'); $Shortcut.TargetPath = 'C:\GymManager\scripts\windows\run.bat'; $Shortcut.WorkingDirectory = 'C:\GymManager'; $Shortcut.Save()"
    echo GymManager se iniciará automáticamente con Windows.
) else (
    echo GymManager no se iniciará automáticamente.
)

:: Finalización
cls
echo ====================================================================
echo            INSTALACION COMPLETADA EXITOSAMENTE
echo ====================================================================
echo.
echo GymManager ha sido instalado en C:\GymManager
echo.
echo Puede iniciar la aplicación usando el acceso directo en el escritorio.
echo.
echo Si necesita administrar la aplicación, use el acceso 
echo "Administrar GymManager" en el escritorio.
echo.
echo Presione cualquier tecla para finalizar...
pause
exit /b 0

:ERROR
echo.
echo ====================================================================
echo                       ERROR DE INSTALACION
echo ====================================================================
echo.
echo Ha ocurrido un error durante la instalación.
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