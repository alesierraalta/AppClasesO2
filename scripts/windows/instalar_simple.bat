@echo off
title Instalador Simple GymManager
color 0A
setlocal enabledelayedexpansion

echo ====================================================================
echo           INSTALADOR SIMPLE DE GYMMANAGER
echo ====================================================================
echo.
echo Este script instalara GymManager automaticamente.
echo Requisito: Python ya debe estar instalado en el sistema.
echo.
echo Este instalador funciona con cualquier version de Python 3.x
echo.
pause

:: Verificar Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python no esta instalado o no esta en el PATH.
    echo Instale Python desde python.org asegurandose de marcar "Add Python to PATH".
    pause
    exit /b 1
)

:: Crear directorio de instalación
echo Preparando directorio de instalacion...
if not exist "C:\GymManager" mkdir "C:\GymManager"

:: Descargar el repositorio
echo Descargando GymManager...
powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip' -OutFile 'C:\GymManager\repo.zip'}"

:: Extraer archivos
echo Extrayendo archivos...
powershell -Command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('C:\GymManager\repo.zip', 'C:\GymManager\temp')}"

:: Mover archivos
echo Copiando archivos...
xcopy /E /Y "C:\GymManager\temp\AppClasesO2-main\*" "C:\GymManager\"

:: Limpiar archivos temporales
echo Limpiando archivos temporales...
rd /S /Q "C:\GymManager\temp"
del "C:\GymManager\repo.zip"

:: Instalar dependencias esenciales
echo Instalando dependencias esenciales...
cd /d C:\GymManager
python -m pip install --upgrade pip
python -m pip install Flask==2.3.3 Flask-SQLAlchemy==3.1.1 Flask-WTF==1.2.1 python-dotenv==1.0.0 flask_login==0.6.2 requests

:: Configurar base de datos
echo Configurando base de datos...
python main.py --setup-db

:: Crear acceso directo
echo Creando acceso directo...
echo @echo off > C:\GymManager\GymManager.bat
echo cd /d C:\GymManager >> C:\GymManager\GymManager.bat
echo python main.py >> C:\GymManager\GymManager.bat
echo pause >> C:\GymManager\GymManager.bat

:: Copiar acceso directo al escritorio
copy "C:\GymManager\GymManager.bat" "%USERPROFILE%\Desktop\"

echo.
echo ====================================================================
echo           INSTALACION COMPLETADA
echo ====================================================================
echo.
echo GymManager ha sido instalado correctamente en C:\GymManager
echo Se ha creado un acceso directo en el escritorio.
echo.
echo Para iniciar la aplicacion:
echo 1. Haz doble clic en el acceso directo "GymManager" en el Escritorio, o
echo 2. Ejecuta C:\GymManager\GymManager.bat
echo.
pause 