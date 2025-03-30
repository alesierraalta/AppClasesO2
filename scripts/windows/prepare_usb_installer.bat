@echo off
title Preparador de USB Instalador - GymManager
color 0A
echo ====================================================================
echo         CREADOR DE USB DE INSTALACION PARA GYMMANAGER
echo ====================================================================
echo.
echo Este script preparara un USB para instalar GymManager en cualquier PC.
echo.
echo Conecte un USB con al menos 500 MB de espacio libre y continue.
echo.
set /p DRIVE_LETTER="Ingrese la letra de unidad del USB (ej. E): "

if not exist %DRIVE_LETTER%:\ (
    echo.
    echo Error: La unidad %DRIVE_LETTER%: no existe.
    echo Por favor, inserte un USB y ejecute este script nuevamente.
    echo.
    pause
    exit /b 1
)

echo.
echo Preparando el USB en la unidad %DRIVE_LETTER%:...
echo.

:: Crear estructura de directorios
echo Creando directorios...
mkdir "%DRIVE_LETTER%:\GymManager_Installer" 2>nul
mkdir "%DRIVE_LETTER%:\GymManager_Installer\Python" 2>nul
mkdir "%DRIVE_LETTER%:\GymManager_Installer\AppFiles" 2>nul
echo Directorios creados.

:: Descargar Python para instalación offline
echo.
echo Descargando Python (esto puede tardar unos minutos)...
powershell -Command "& {Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe' -OutFile '%DRIVE_LETTER%:\GymManager_Installer\Python\python-3.8.10-amd64.exe'}"

if %errorLevel% neq 0 (
    echo Error al descargar Python. Compruebe su conexion a Internet.
    goto ERROR
)
echo Python descargado correctamente.

:: Copiar el instalador principal
echo.
echo Copiando script de instalacion...
copy "instalacion_completa.bat" "%DRIVE_LETTER%:\GymManager_Installer\instalar_GymManager.bat" /Y

:: Crear script de lanzamiento automático para el USB
echo.
echo Creando autorun.inf...
echo [autorun] > "%DRIVE_LETTER%:\autorun.inf"
echo open=GymManager_Installer\instalar_GymManager.bat >> "%DRIVE_LETTER%:\autorun.inf"
echo label=Instalador GymManager >> "%DRIVE_LETTER%:\autorun.inf"
echo icon=GymManager_Installer\AppFiles\icon.ico >> "%DRIVE_LETTER%:\autorun.inf"

:: Crear archivo README.txt con instrucciones
echo.
echo Creando archivo de instrucciones...

echo ====================================================================== > "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo                 INSTALADOR DE GYMMANAGER                               >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo ====================================================================== >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo. >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo Instrucciones para instalar GymManager: >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo. >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo 1. Haga doble clic en el archivo "instalar_GymManager.bat" >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo 2. Siga las instrucciones en pantalla >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo 3. Al finalizar, encontrará los accesos directos en el escritorio >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo. >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo Notas importantes: >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo - Se requieren permisos de administrador para la instalacion >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo - La PC1 debe instalarse primero, luego las demas PCs >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo - Para las PC2 y PC3, necesitara conocer la IP de la PC1 >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo - La instalacion tardara aproximadamente 5-10 minutos >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo. >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"
echo Para soporte tecnico, contacte al administrador del sistema. >> "%DRIVE_LETTER%:\GymManager_Installer\LEEME.txt"

:: Modificar el instalador principal para usar archivos locales
echo.
echo Adaptando instalador para modo offline...

:: Leer el archivo original
type "instalacion_completa.bat" > "%DRIVE_LETTER%:\GymManager_Installer\temp.bat"

:: Modificar para usar el Python local en lugar de descargarlo
powershell -Command "(Get-Content '%DRIVE_LETTER%:\GymManager_Installer\temp.bat') -replace 'powershell -Command \"& {Invoke-WebRequest -Uri ''https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe'' -OutFile ''C:\\GymManager\\Temp\\python-installer.exe''}\"', 'copy \"%~dp0Python\python-3.8.10-amd64.exe\" \"C:\GymManager\Temp\python-installer.exe\"' | Set-Content '%DRIVE_LETTER%:\GymManager_Installer\instalar_GymManager.bat'"

:: Eliminar archivo temporal
del "%DRIVE_LETTER%:\GymManager_Installer\temp.bat" /f /q

:: Obtener copia local del repositorio
echo.
echo Preparando copia local del repositorio...
cd ..\..\..\
powershell -Command "Compress-Archive -Path * -DestinationPath '%DRIVE_LETTER%:\GymManager_Installer\AppFiles\GymManager.zip' -Force"

:: Modificar el instalador para usar el ZIP local
powershell -Command "(Get-Content '%DRIVE_LETTER%:\GymManager_Installer\instalar_GymManager.bat') -replace 'powershell -Command \"& {Invoke-WebRequest -Uri ''https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip'' -OutFile ''C:\\GymManager\\Temp\\GymManager.zip''}\"', 'copy \"%~dp0AppFiles\GymManager.zip\" \"C:\GymManager\Temp\GymManager.zip\"' | Set-Content '%DRIVE_LETTER%:\GymManager_Installer\temp.bat'"
move /Y "%DRIVE_LETTER%:\GymManager_Installer\temp.bat" "%DRIVE_LETTER%:\GymManager_Installer\instalar_GymManager.bat" > nul

:: Crear acceso directo principal
echo.
echo Creando acceso directo...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DRIVE_LETTER%:\Instalar GymManager.lnk'); $Shortcut.TargetPath = '%DRIVE_LETTER%:\GymManager_Installer\instalar_GymManager.bat'; $Shortcut.WorkingDirectory = '%DRIVE_LETTER%:\GymManager_Installer'; $Shortcut.IconLocation = '%DRIVE_LETTER%:\GymManager_Installer\AppFiles\icon.ico,0'; $Shortcut.Save()"

:: Finalización
echo.
echo ====================================================================
echo                 USB DE INSTALACION CREADO
echo ====================================================================
echo.
echo El USB de instalacion ha sido creado exitosamente en la unidad %DRIVE_LETTER%:.
echo.
echo Para instalar GymManager en cualquier computadora:
echo 1. Inserte este USB
echo 2. Abra el USB y haga doble clic en "Instalar GymManager"
echo 3. Siga las instrucciones en pantalla
echo.
echo Presione cualquier tecla para finalizar...
pause > nul
exit /b 0

:ERROR
echo.
echo ====================================================================
echo                   ERROR EN LA PREPARACION
echo ====================================================================
echo.
echo Ha ocurrido un error al preparar el USB de instalacion.
echo Por favor, intente nuevamente con otro USB o revise su conexion.
echo.
pause
exit /b 1 