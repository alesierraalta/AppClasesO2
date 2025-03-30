@echo off
title Instalador Directo GymManager desde GitHub
color 0A
echo ====================================================================
echo          INSTALADOR DIRECTO DE GYMMANAGER DESDE GITHUB
echo ====================================================================
echo.
echo Este script descargara e instalara GymManager directamente desde GitHub.
echo No se requiere ninguna instalacion previa ni USB.
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

:: Crear directorios de instalación
echo Creando directorios de instalacion...
mkdir "C:\GymManager" 2>nul
mkdir "C:\GymManager\Logs" 2>nul
mkdir "C:\GymManager\Backups" 2>nul
mkdir "C:\GymManager\Temp" 2>nul
echo Directorios creados correctamente.
echo.

:: Verificar si Python está instalado
echo Verificando instalacion de Python...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo Python no esta instalado. Instalando Python...
    
    :: Descargar Python
    echo Descargando Python 3.8.10...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe' -OutFile 'C:\GymManager\Temp\python-installer.exe'}"
    
    if %errorLevel% neq 0 (
        echo Error al descargar Python. Compruebe su conexion a Internet.
        goto ERROR
    )
    
    :: Instalar Python silenciosamente, añadirlo al PATH
    echo Instalando Python 3.8.10...
    C:\GymManager\Temp\python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_launcher=1
    
    if %errorLevel% neq 0 (
        echo Error al instalar Python.
        goto ERROR
    )
    
    :: Refrescar PATH
    echo Actualizando variables de entorno...
    call RefreshEnv.cmd || (
        echo @echo off > C:\GymManager\Temp\refresh.bat
        echo setlocal >> C:\GymManager\Temp\refresh.bat
        echo for /f "tokens=* usebackq" %%%%x in (`set`) do set "%%%%x" >> C:\GymManager\Temp\refresh.bat
        echo endlocal >> C:\GymManager\Temp\refresh.bat
        call C:\GymManager\Temp\refresh.bat
    )
    
    echo Python instalado correctamente.
) else (
    echo Python ya esta instalado.
)
echo.

:: Descargar el repositorio de GymManager directamente desde GitHub
echo Descargando GymManager desde GitHub...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip' -OutFile 'C:\GymManager\Temp\GymManager.zip'}"

if %errorLevel% neq 0 (
    echo Error al descargar GymManager. Compruebe su conexion a Internet.
    goto ERROR
)

:: Extraer el repositorio
echo Extrayendo archivos...
powershell -Command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('C:\GymManager\Temp\GymManager.zip', 'C:\GymManager\Temp')}"

:: Mover archivos a la ubicación correcta
echo Copiando archivos...
xcopy /E /I /Y "C:\GymManager\Temp\AppClasesO2-main\*" "C:\GymManager\"
echo Archivos copiados correctamente.
echo.

:: Instalar dependencias de Python
echo Instalando dependencias de Python...
cd C:\GymManager
python -m pip install --upgrade pip
pip install -r requirements.txt

if %errorLevel% neq 0 (
    echo Error al instalar dependencias de Python.
    goto ERROR
)
echo Dependencias instaladas correctamente.
echo.

:: Configuración específica del equipo
cls
echo ====================================================================
echo               CONFIGURACION DE ESTE EQUIPO
echo ====================================================================
echo.
echo Necesitamos configurar este equipo para el sistema GymManager.
echo.

:: Preguntar número de PC
set /p PC_NUM="¿Que numero de PC es esta? (1, 2 o 3): "

:: Configurar archivos
echo { "pc_number": %PC_NUM%, "is_server": %PC_NUM% == 1, "sync_enabled": true } > "C:\GymManager\app\core\pc_config.json"

:: Configurar sincronización si no es la PC principal
if not "%PC_NUM%"=="1" (
    echo.
    echo Esta PC debe sincronizarse con la PC principal (PC1).
    echo.
    set /p SERVER_IP="Introduce la direccion IP de la PC principal: "
    echo { "server_ip": "%SERVER_IP%", "server_port": 5000 } > "C:\GymManager\app\core\network_config.json"
    echo Configuracion de red guardada.
) else (
    echo Esta PC es la principal. No se requiere configuracion adicional.
)
echo.

:: Crear base de datos si no existe
echo Configurando base de datos...
if not exist "C:\GymManager\database\gimnasio.db" (
    cd C:\GymManager
    python database\create_tables.py

    if %errorLevel% neq 0 (
        echo Error al crear la base de datos.
        goto ERROR
    )
    echo Base de datos creada correctamente.
) else (
    echo Base de datos ya existe.
)
echo.

:: Crear accesos directos
echo Creando accesos directos...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\GymManager.lnk'); $Shortcut.TargetPath = 'C:\GymManager\scripts\windows\run.bat'; $Shortcut.WorkingDirectory = 'C:\GymManager'; $Shortcut.Save()"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\GymManager.lnk'); $Shortcut.TargetPath = 'C:\GymManager\scripts\windows\run.bat'; $Shortcut.WorkingDirectory = 'C:\GymManager'; $Shortcut.Save()"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Administrar GymManager.lnk'); $Shortcut.TargetPath = 'C:\GymManager\scripts\windows\administrar.bat'; $Shortcut.WorkingDirectory = 'C:\GymManager'; $Shortcut.Save()"

:: Configurar inicio automático si se desea
echo.
set /p AUTO_START="¿Desea que GymManager se inicie automaticamente al encender la computadora? (S/N): "
if /i "%AUTO_START%"=="S" (
    powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\GymManager.lnk'); $Shortcut.TargetPath = 'C:\GymManager\scripts\windows\run.bat'; $Shortcut.WorkingDirectory = 'C:\GymManager'; $Shortcut.Save()"
    echo GymManager se iniciara automaticamente con Windows.
) else (
    echo GymManager no se iniciara automaticamente.
)

:: Limpiar temporales
echo.
echo Limpiando archivos temporales...
rd /s /q "C:\GymManager\Temp" 2>nul
echo Archivos temporales eliminados.

:: Finalización
cls
echo ====================================================================
echo            INSTALACION COMPLETADA EXITOSAMENTE
echo ====================================================================
echo.
echo GymManager ha sido instalado en C:\GymManager
echo.
echo Puede iniciar la aplicacion usando el acceso directo en el escritorio.
echo.
echo Si necesita administrar la aplicacion, use el acceso 
echo "Administrar GymManager" en el escritorio.
echo.
echo Presione cualquier tecla para finalizar...
pause > nul
exit /b 0

:ERROR
echo.
echo ====================================================================
echo                       ERROR DE INSTALACION
echo ====================================================================
echo.
echo Ha ocurrido un error durante la instalacion.
echo.
echo Intente los siguientes pasos:
echo 1. Asegurese de tener conexion a Internet
echo 2. Ejecute el instalador como administrador
echo 3. Desactive temporalmente el antivirus
echo 4. Si el problema persiste, contacte al soporte tecnico
echo.
echo Presione cualquier tecla para salir...
pause > nul
exit /b 1 