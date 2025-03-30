@echo off
title Solucionador de Dependencias GymManager
color 0A
setlocal enabledelayedexpansion

echo ====================================================================
echo          SOLUCIONADOR DE DEPENDENCIAS PARA GYMMANAGER
echo ====================================================================
echo.
echo Este script arreglará problemas comunes de dependencias en GymManager.
echo Específicamente, solucionará el error:
echo "cannot import name 'url_decode' from 'werkzeug.urls'"
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

:: Verificar instalación de GymManager
if not exist "C:\GymManager" (
    echo ERROR: No se encuentra la carpeta de instalación de GymManager.
    echo Ejecute primero el instalador de GymManager.
    pause
    exit /b 1
)

echo Instalando versiones compatibles de dependencias...
cd /d C:\GymManager

:: Reinstalar Werkzeug con versión compatible
echo Reinstalando Werkzeug con una versión compatible...
python -m pip install --upgrade pip
python -m pip uninstall -y werkzeug flask flask-login flask-sqlalchemy flask-wtf
python -m pip install werkzeug==2.3.7
python -m pip install flask==2.3.3 flask-login==0.6.2 flask-sqlalchemy==3.1.1 flask-wtf==1.2.1
python -m pip install python-dotenv==1.0.0 requests

echo.
echo Dependencias reinstaladas correctamente.
echo.
echo Verificando si se solucionó el problema...
python -c "from werkzeug.urls import url_decode; print('OK: url_decode importado correctamente')" 2>nul
if %errorlevel% neq 0 (
    echo.
    echo ADVERTENCIA: Todavía hay problemas con werkzeug.
    echo Intentando solución alternativa...
    echo.
    
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
    echo Verificando nuevamente la solución...
    python -c "from werkzeug.urls import url_decode; print('OK: url_decode ahora importado correctamente')" 2>nul
    if %errorlevel% neq 0 (
        echo.
        echo ERROR: No se pudo resolver el problema automáticamente.
        echo.
        echo Recomendaciones:
        echo 1. Intente con una versión anterior de Python (3.9 o 3.8)
        echo 2. O instale manualmente las versiones compatibles con:
        echo    pip install werkzeug==2.0.3 flask==2.0.3 flask-login==0.5.0 flask-sqlalchemy==2.5.1 flask-wtf==1.0.1
        echo.
    ) else (
        echo.
        echo ¡El problema ha sido resuelto correctamente!
    )
) else (
    echo.
    echo ¡El problema ha sido resuelto correctamente!
)

echo.
echo ====================================================================
echo           REPARACIÓN COMPLETADA
echo ====================================================================
echo.
echo Ahora puede intentar iniciar GymManager nuevamente.
echo Si continúa teniendo problemas, considere:
echo 1. Usar el instalador simple que es compatible con más versiones
echo 2. Reinstalar GymManager completamente
echo.
pause 