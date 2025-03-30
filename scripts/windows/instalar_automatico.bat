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
echo Versiones recomendadas de Python: 3.8, 3.9 o 3.10
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

:: Comprobar versión de Python
for /f "tokens=2" %%V in ('python --version 2^>^&1') do set PYTHON_VERSION=%%V
echo Versión de Python detectada: %PYTHON_VERSION%

:: Advertencia para versiones nuevas de Python
echo %PYTHON_VERSION% | findstr /B /C:"3.1" >nul && (
    echo.
    echo ADVERTENCIA: Estás usando Python %PYTHON_VERSION%, que podría tener problemas
    echo de compatibilidad con algunas dependencias.
    echo.
    echo Recomendamos usar Python 3.8 o 3.10 para mejor compatibilidad.
    echo.
    echo ¿Deseas continuar de todas formas? (S/N)
    set /p CONTINUE=
    if /i not "!CONTINUE!"=="S" (
        echo Instalación cancelada por el usuario.
        pause
        exit /b 0
    )
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
echo # Modificar requirements.txt para mayor compatibilidad si es necesario >> install_temp.py
echo python_version = sys.version_info >> install_temp.py
echo if python_version.major == 3 and python_version.minor >= 11: >> install_temp.py
echo     print("Detectada versión de Python 3.11+, ajustando requisitos para mayor compatibilidad...") >> install_temp.py
echo     req_file = os.path.join(install_dir, "requirements.txt") >> install_temp.py
echo     with open(req_file, 'r') as f: >> install_temp.py
echo         requirements = f.read() >> install_temp.py
echo     # Ajustar versiones específicas problemáticas >> install_temp.py
echo     requirements = requirements.replace("pyinstaller==6.1.0", "pyinstaller>=6.12.0") >> install_temp.py
echo     with open(req_file, 'w') as f: >> install_temp.py
echo         f.write(requirements) >> install_temp.py
echo. >> install_temp.py
echo # Instalar dependencias >> install_temp.py
echo print("Instalando dependencias...") >> install_temp.py
echo try: >> install_temp.py
echo     subprocess.run([sys.executable, "-m", "pip", "install", "--upgrade", "pip"], check=True) >> install_temp.py
echo     subprocess.run([sys.executable, "-m", "pip", "install", "-r", os.path.join(install_dir, "requirements.txt")], check=True) >> install_temp.py
echo except subprocess.CalledProcessError as e: >> install_temp.py
echo     print("\\nError al instalar dependencias. Intentando instalar paquetes esenciales por separado...") >> install_temp.py
echo     try: >> install_temp.py
echo         essential_packages = ["Flask==2.3.3", "Flask-SQLAlchemy==3.1.1", "Flask-WTF==1.2.1", >> install_temp.py
echo                             "python-dotenv==1.0.0", "flask_login==0.6.2", "requests"] >> install_temp.py
echo         for package in essential_packages: >> install_temp.py
echo             print(f"Instalando {package}...") >> install_temp.py
echo             subprocess.run([sys.executable, "-m", "pip", "install", package], check=True) >> install_temp.py
echo         print("\\nPaquetes esenciales instalados correctamente.") >> install_temp.py
echo     except Exception as ex: >> install_temp.py
echo         print(f"\\nError al instalar paquetes esenciales: {ex}") >> install_temp.py
echo         print("\\nSe recomienda instalar Python 3.8 o 3.10 para mejor compatibilidad.") >> install_temp.py
echo         input("\\nPresiona Enter para continuar...") >> install_temp.py
echo. >> install_temp.py
echo # Configurar base de datos >> install_temp.py
echo print("Configurando base de datos...") >> install_temp.py
echo os.chdir(install_dir) >> install_temp.py
echo try: >> install_temp.py
echo     subprocess.run([sys.executable, "main.py", "--setup-db"], check=True) >> install_temp.py
echo except subprocess.CalledProcessError as e: >> install_temp.py
echo     print(f"\\nAdvertencia: No se pudo configurar la base de datos: {e}") >> install_temp.py
echo     print("\\nSe recomienda ejecutar 'python main.py --setup-db' manualmente después de resolver los problemas de dependencias.") >> install_temp.py
echo. >> install_temp.py
echo # Crear acceso directo >> install_temp.py
echo print("Creando acceso directo...") >> install_temp.py
echo batch_path = os.path.join(install_dir, "GymManager.bat") >> install_temp.py
echo with open(batch_path, 'w') as f: >> install_temp.py
echo     f.write('@echo off\n') >> install_temp.py
echo     f.write(f'cd /d {install_dir}\n') >> install_temp.py
echo     f.write('python main.py\n') >> install_temp.py
echo     f.write('pause\n') >> install_temp.py
echo. >> install_temp.py
echo desktop = os.path.join(os.path.expanduser("~"), "Desktop") >> install_temp.py
echo shortcut_created = False >> install_temp.py
echo try: >> install_temp.py
echo     # Método 1: Usar pywin32 si está disponible >> install_temp.py
echo     try: >> install_temp.py
echo         import win32com.client >> install_temp.py
echo         shell = win32com.client.Dispatch("WScript.Shell") >> install_temp.py
echo         shortcut = shell.CreateShortCut(os.path.join(desktop, "GymManager.lnk")) >> install_temp.py
echo         shortcut.Targetpath = batch_path >> install_temp.py
echo         shortcut.WorkingDirectory = install_dir >> install_temp.py
echo         shortcut.save() >> install_temp.py
echo         shortcut_created = True >> install_temp.py
echo     except ImportError: >> install_temp.py
echo         print("Módulo win32com no disponible. Intentando método alternativo...") >> install_temp.py
echo. >> install_temp.py
echo     # Método 2: Copiar el .bat al escritorio >> install_temp.py
echo     if not shortcut_created: >> install_temp.py
echo         shutil.copy2(batch_path, os.path.join(desktop, "GymManager.bat")) >> install_temp.py
echo         print("Acceso directo (batch) creado en el escritorio.") >> install_temp.py
echo except Exception as e: >> install_temp.py
echo     print(f"No se pudo crear acceso directo: {e}") >> install_temp.py
echo     print(f"Puedes ejecutar manualmente: {batch_path}") >> install_temp.py
echo. >> install_temp.py
echo # Limpieza >> install_temp.py
echo print("Limpiando archivos temporales...") >> install_temp.py
echo try: >> install_temp.py
echo     os.remove(temp_zip) >> install_temp.py
echo     shutil.rmtree(temp_dir) >> install_temp.py
echo except: >> install_temp.py
echo     pass  # Ignorar errores en la limpieza >> install_temp.py
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
echo NOTA: Si experimentas problemas, recomendamos usar Python 3.8 o 3.10
echo para mayor compatibilidad.
echo.
pause 