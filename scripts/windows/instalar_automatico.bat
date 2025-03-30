@echo off
title Instalador GymManager
color 0A
setlocal enabledelayedexpansion

echo ====================================================================
echo           INSTALADOR AUTOMATIZADO DE GYMMANAGER
echo ====================================================================
echo.
echo Este script instalara GymManager automaticamente.
echo Requisito: Python ya debe estar instalado en el sistema.
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

:: Instalar requisitos
echo Instalando modulo de descarga...
pip install requests >nul 2>&1

:: Crear y ejecutar script Python de instalación
echo Descargando e instalando GymManager...
echo import os, sys, requests, zipfile, tempfile, shutil, subprocess > install_temp.py
echo. >> install_temp.py
echo # Crear carpeta de destino >> install_temp.py
echo install_dir = "C:\\GymManager" >> install_temp.py
echo if not os.path.exists(install_dir): >> install_temp.py
echo     os.makedirs(install_dir) >> install_temp.py
echo. >> install_temp.py
echo # Descargar repositorio >> install_temp.py
echo zip_url = "https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip" >> install_temp.py
echo temp_zip = os.path.join(tempfile.gettempdir(), "gymmanager.zip") >> install_temp.py
echo print("Descargando GymManager...") >> install_temp.py
echo response = requests.get(zip_url, stream=True) >> install_temp.py
echo with open(temp_zip, 'wb') as f: >> install_temp.py
echo     for chunk in response.iter_content(chunk_size=8192): >> install_temp.py
echo         f.write(chunk) >> install_temp.py
echo. >> install_temp.py
echo # Extraer archivo >> install_temp.py
echo print("Extrayendo archivos...") >> install_temp.py
echo with zipfile.ZipFile(temp_zip, 'r') as zip_ref: >> install_temp.py
echo     zip_ref.extractall(tempfile.gettempdir()) >> install_temp.py
echo. >> install_temp.py
echo # Mover archivos a directorio final >> install_temp.py
echo temp_dir = os.path.join(tempfile.gettempdir(), "AppClasesO2-main") >> install_temp.py
echo for item in os.listdir(temp_dir): >> install_temp.py
echo     s = os.path.join(temp_dir, item) >> install_temp.py
echo     d = os.path.join(install_dir, item) >> install_temp.py
echo     if os.path.isdir(s): >> install_temp.py
echo         if os.path.exists(d): >> install_temp.py
echo             shutil.rmtree(d) >> install_temp.py
echo         shutil.copytree(s, d) >> install_temp.py
echo     else: >> install_temp.py
echo         shutil.copy2(s, d) >> install_temp.py
echo. >> install_temp.py
echo # Instalar dependencias >> install_temp.py
echo print("Instalando dependencias...") >> install_temp.py
echo subprocess.run([sys.executable, "-m", "pip", "install", "-r", os.path.join(install_dir, "requirements.txt")], check=True) >> install_temp.py
echo. >> install_temp.py
echo # Configurar base de datos >> install_temp.py
echo print("Configurando base de datos...") >> install_temp.py
echo os.chdir(install_dir) >> install_temp.py
echo subprocess.run([sys.executable, "main.py", "--setup-db"], check=True) >> install_temp.py
echo. >> install_temp.py
echo # Crear acceso directo >> install_temp.py
echo print("Creando acceso directo...") >> install_temp.py
echo batch_path = os.path.join(install_dir, "GymManager.bat") >> install_temp.py
echo with open(batch_path, 'w') as f: >> install_temp.py
echo     f.write('@echo off\n') >> install_temp.py
echo     f.write(f'cd /d {install_dir}\n') >> install_temp.py
echo     f.write('python main.py\n') >> install_temp.py
echo. >> install_temp.py
echo desktop = os.path.join(os.path.expanduser("~"), "Desktop") >> install_temp.py
echo try: >> install_temp.py
echo     import win32com.client >> install_temp.py
echo     shell = win32com.client.Dispatch("WScript.Shell") >> install_temp.py
echo     shortcut = shell.CreateShortCut(os.path.join(desktop, "GymManager.lnk")) >> install_temp.py
echo     shortcut.Targetpath = batch_path >> install_temp.py
echo     shortcut.WorkingDirectory = install_dir >> install_temp.py
echo     shortcut.save() >> install_temp.py
echo except: >> install_temp.py
echo     print("No se pudo crear acceso directo, instalando módulo adicional...") >> install_temp.py
echo     subprocess.run([sys.executable, "-m", "pip", "install", "pywin32"], check=True) >> install_temp.py
echo     import win32com.client >> install_temp.py
echo     shell = win32com.client.Dispatch("WScript.Shell") >> install_temp.py
echo     shortcut = shell.CreateShortCut(os.path.join(desktop, "GymManager.lnk")) >> install_temp.py
echo     shortcut.Targetpath = batch_path >> install_temp.py
echo     shortcut.WorkingDirectory = install_dir >> install_temp.py
echo     shortcut.save() >> install_temp.py
echo. >> install_temp.py
echo # Limpieza >> install_temp.py
echo print("Limpiando archivos temporales...") >> install_temp.py
echo os.remove(temp_zip) >> install_temp.py
echo shutil.rmtree(temp_dir) >> install_temp.py
echo print("Instalación completada con éxito!") >> install_temp.py

:: Ejecutar script de instalación
python install_temp.py
del install_temp.py

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