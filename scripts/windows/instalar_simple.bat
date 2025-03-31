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

:: Instalar versiones específicas para evitar el error url_decode
echo Instalando versiones compatibles de dependencias...
python -m pip install werkzeug==2.3.7
python -m pip install Flask==2.3.3 Flask-SQLAlchemy==3.1.1 Flask-WTF==1.2.1 python-dotenv==1.0.0 flask_login==0.6.2 requests

:: Verificar si se solucionó el problema de url_decode
echo Verificando dependencias...
python -c "from werkzeug.urls import url_decode; print('OK: url_decode importado correctamente')" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ADVERTENCIA: Añadiendo solución para el error url_decode...
    
    :: Crear script Python para solucionar el problema
    echo import sys > fix_werkzeug.py
    echo import os >> fix_werkzeug.py
    echo import site >> fix_werkzeug.py
    echo. >> fix_werkzeug.py
    echo # Encontrar la ubicación de werkzeug >> fix_werkzeug.py
    echo werkzeug_path = None >> fix_werkzeug.py
    echo for path in sys.path: >> fix_werkzeug.py
    echo     potential_path = os.path.join(path, 'werkzeug') >> fix_werkzeug.py
    echo     if os.path.exists(potential_path): >> fix_werkzeug.py
    echo         werkzeug_path = potential_path >> fix_werkzeug.py
    echo         break >> fix_werkzeug.py
    echo. >> fix_werkzeug.py
    echo if werkzeug_path: >> fix_werkzeug.py
    echo     print(f"Werkzeug encontrado en: {werkzeug_path}") >> fix_werkzeug.py
    echo     # Verificar si existe urls.py >> fix_werkzeug.py
    echo     urls_path = os.path.join(werkzeug_path, 'urls.py') >> fix_werkzeug.py
    echo     if os.path.exists(urls_path): >> fix_werkzeug.py
    echo         print(f"Comprobando {urls_path}") >> fix_werkzeug.py
    echo         with open(urls_path, 'r') as f: >> fix_werkzeug.py
    echo             content = f.read() >> fix_werkzeug.py
    echo         # Verificar si url_decode no está definido >> fix_werkzeug.py
    echo         if 'def url_decode' not in content: >> fix_werkzeug.py
    echo             print("Añadiendo función url_decode a werkzeug.urls") >> fix_werkzeug.py
    echo             # Añadir la función url_decode >> fix_werkzeug.py
    echo             with open(urls_path, 'a') as f: >> fix_werkzeug.py
    echo                 f.write("\n\n") >> fix_werkzeug.py
    echo                 f.write("def url_decode(s, charset='utf-8', include_empty=True, errors='replace', separator='&', cls=None):\n") >> fix_werkzeug.py
    echo                 f.write("    \"\"\"Parse a query string and return it as a dictionary.\"\"\"\n") >> fix_werkzeug.py
    echo                 f.write("    if isinstance(s, str):\n") >> fix_werkzeug.py
    echo                 f.write("        s = s.encode(charset)\n") >> fix_werkzeug.py
    echo                 f.write("    return dict(_url_decode_impl(s.split(separator.encode('ascii')), charset, include_empty, errors))\n") >> fix_werkzeug.py
    echo                 f.write("\n") >> fix_werkzeug.py
    echo                 f.write("def _url_decode_impl(pair_iter, charset, include_empty, errors):\n") >> fix_werkzeug.py
    echo                 f.write("    for pair in pair_iter:\n") >> fix_werkzeug.py
    echo                 f.write("        if not pair:\n") >> fix_werkzeug.py
    echo                 f.write("            continue\n") >> fix_werkzeug.py
    echo                 f.write("        equal = pair.find(b'=')\n") >> fix_werkzeug.py
    echo                 f.write("        if equal >= 0:\n") >> fix_werkzeug.py
    echo                 f.write("            key = pair[:equal].replace(b'+', b' ')\n") >> fix_werkzeug.py
    echo                 f.write("            value = pair[equal + 1:].replace(b'+', b' ')\n") >> fix_werkzeug.py
    echo                 f.write("        else:\n") >> fix_werkzeug.py
    echo                 f.write("            key = pair.replace(b'+', b' ')\n") >> fix_werkzeug.py
    echo                 f.write("            value = b''\n") >> fix_werkzeug.py
    echo                 f.write("        key = url_unquote_plus(key, charset, errors)\n") >> fix_werkzeug.py
    echo                 f.write("        if include_empty or value:\n") >> fix_werkzeug.py
    echo                 f.write("            value = url_unquote_plus(value, charset, errors)\n") >> fix_werkzeug.py
    echo                 f.write("            yield key, value\n") >> fix_werkzeug.py
    echo     else: >> fix_werkzeug.py
    echo         print(f"Error: No se encontró el archivo urls.py en {werkzeug_path}") >> fix_werkzeug.py
    echo else: >> fix_werkzeug.py
    echo     print("Error: No se pudo encontrar la carpeta de werkzeug") >> fix_werkzeug.py

    python fix_werkzeug.py
    del fix_werkzeug.py
    
    echo.
    echo Verificando solución...
    python -c "from werkzeug.urls import url_decode; print('OK: Solución aplicada correctamente')" >nul 2>&1
    if %errorlevel% neq 0 (
        echo ADVERTENCIA: No se pudo solucionar automáticamente.
        echo La aplicación podría requerir ajustes adicionales la primera vez que se ejecute.
    ) else (
        echo OK: Problema de url_decode solucionado correctamente.
    )
)

:: Configurar HTTPS
echo Configurando HTTPS...
if not exist "C:\GymManager\certificates" mkdir "C:\GymManager\certificates"
if not exist "C:\GymManager\certificates\server.crt" (
    echo Generando certificados SSL...
    python -c "from OpenSSL import crypto; k = crypto.PKey(); k.generate_key(crypto.TYPE_RSA, 2048); cert = crypto.X509(); cert.get_subject().C = 'ES'; cert.get_subject().ST = 'Madrid'; cert.get_subject().L = 'Madrid'; cert.get_subject().O = 'GymManager'; cert.get_subject().OU = 'GymManager'; cert.get_subject().CN = 'localhost'; cert.set_serial_number(1000); cert.gmtime_adj_notBefore(0); cert.gmtime_adj_notAfter(365*24*60*60); cert.set_issuer(cert.get_subject()); cert.set_pubkey(k); cert.sign(k, 'sha256'); open('C:\\GymManager\\certificates\\server.crt', 'wb').write(crypto.dump_certificate(crypto.FILETYPE_PEM, cert)); open('C:\\GymManager\\certificates\\server.key', 'wb').write(crypto.dump_privatekey(crypto.FILETYPE_PEM, k))"
)

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