@echo off
echo ================================================
echo      INSTALADOR AUTOMATICO DE GYMMANAGER
echo ================================================
echo.
echo Este instalador configurara GymManager en esta computadora
echo y sincronizara con las otras computadoras del gimnasio.
echo.
echo El proceso incluye:
echo  1. Preparar el entorno (Python y dependencias)
echo  2. Configurar la red entre computadoras
echo  3. Compilar la aplicacion
echo  4. Crear acceso directo en el escritorio
echo.
echo Presione cualquier tecla para continuar...
pause > nul

REM Verificar que Python esté instalado
echo.
echo Verificando instalacion de Python...
python --version 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python no esta instalado en este sistema.
    echo Por favor, instale Python 3.8 o superior desde:
    echo https://www.python.org/downloads/
    echo.
    echo Despues de instalar Python, ejecute este instalador nuevamente.
    echo.
    pause
    exit /b 1
)

echo Python encontrado correctamente.

REM Crear entorno virtual
echo.
echo Configurando entorno de desarrollo...
if not exist venv (
    echo Creando entorno virtual...
    python -m venv venv
) else (
    echo Entorno virtual ya existe, usando el existente.
)

REM Activar entorno virtual
call venv\Scripts\activate

REM Instalar dependencias
echo.
echo Instalando dependencias...
pip install -r requirements.txt

REM Crear directorios necesarios
echo.
echo Creando directorios de la aplicacion...
if not exist static mkdir static
if not exist templates mkdir templates
if not exist uploads mkdir uploads
if not exist backups mkdir backups

REM Configurar la red
echo.
echo ================================================
echo            CONFIGURACION DE RED
echo ================================================
echo.
echo A continuacion se configurara la conexion entre computadoras.
echo Seleccione si esta es la computadora principal (gerente) o
echo una de las computadoras de recepcion.
echo.

REM Ejecutar el script de configuración de red
call setup_network.bat

REM Crear acceso directo en el escritorio
echo.
echo Creando acceso directo en el escritorio...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\GymManager.lnk'); $Shortcut.TargetPath = '%cd%\dist\GymManager.exe'; $Shortcut.WorkingDirectory = '%cd%\dist'; $Shortcut.IconLocation = '%cd%\dist\GymManager.exe,0'; $Shortcut.Description = 'Sistema de Gestion de Gimnasio'; $Shortcut.Save()"

REM Preguntar si desea iniciar la aplicación
echo.
echo ================================================
echo            INSTALACION COMPLETADA
echo ================================================
echo.
echo GymManager ha sido instalado correctamente.
echo.
echo ¿Desea iniciar la aplicacion ahora? (S/N)
set /p START_NOW="Ingrese S para iniciar o N para salir: "

if /i "%START_NOW%"=="S" (
    echo.
    echo Iniciando GymManager...
    start "" "dist\GymManager.exe"
) else (
    echo.
    echo Para iniciar la aplicacion mas tarde, haga doble clic en
    echo el acceso directo "GymManager" en el escritorio o ejecute
    echo dist\GymManager.exe directamente.
)

echo.
echo ================================================
echo          INSTRUCCIONES IMPORTANTES
echo ================================================
echo.
echo 1. Asegurese de que todas las computadoras esten encendidas y
echo    conectadas a la misma red local para la sincronizacion.
echo.
echo 2. La computadora principal (Gerencia) debe estar encendida
echo    para garantizar que todas las computadoras se sincronicen
echo    correctamente.
echo.
echo 3. Si cambia la IP de alguna computadora, debe ejecutar
echo    nuevamente setup_network.bat en todas las computadoras.
echo.
echo Gracias por instalar GymManager.
echo.

pause 