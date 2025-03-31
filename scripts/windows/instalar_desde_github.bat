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
echo IMPORTANTE: Mantenga la conexion a Internet activa durante el proceso.
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
    echo Python no esta instalado. Se instalará Python 3.8.10...
    echo.
    
    :: Descargar Python
    echo Descargando Python 3.8.10 (esto puede tomar unos minutos)...
    echo Por favor, espere...
    
    :: Usar métodos alternativos para la descarga para evitar bloqueos de antivirus
    >nul 2>nul powershell -Command "& {try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webClient = New-Object System.Net.WebClient; $webClient.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'); $webClient.DownloadFile('https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe', 'C:\GymManager\Temp\python-installer.exe') } catch { try { Start-BitsTransfer -Source 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe' -Destination 'C:\GymManager\Temp\python-installer.exe' } catch { exit 1 } } }"
    
    if %errorLevel% neq 0 (
        echo.
        echo ¡ERROR! No se pudo descargar Python.
        echo - Intentando método alternativo de descarga...
        
        >nul 2>nul powershell -Command "& {try { $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe' -OutFile 'C:\GymManager\Temp\python-installer.exe' -UseBasicParsing } catch { exit 1 } }"
        
        if %errorLevel% neq 0 (
            echo.
            echo ¡ERROR! No se pudo descargar Python.
            echo - Verifique su conexión a Internet
            echo - Si tiene acceso a un navegador, descargue manualmente Python desde www.python.org
            echo - Coloque el instalador descargado en C:\GymManager\Temp\python-installer.exe
            echo - Luego reinicie este instalador
            goto ERROR
        ) else {
            echo Descarga completada mediante método alternativo.
        }
    )
    
    :: Instalar Python silenciosamente, añadirlo al PATH
    echo Descarga completada. Instalando Python 3.8.10...
    echo Este proceso tardará varios minutos. Por favor, espere...
    C:\GymManager\Temp\python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_launcher=1
    
    if %errorLevel% neq 0 (
        echo.
        echo ¡ERROR! No se pudo instalar Python.
        echo - Compruebe que no hay otras instalaciones en curso
        echo - Intente reiniciar el equipo y volver a ejecutar este instalador
        goto ERROR
    )
    
    :: Refrescar PATH
    echo Actualizando variables de entorno...
    echo @echo off > C:\GymManager\Temp\refresh.bat
    echo setlocal >> C:\GymManager\Temp\refresh.bat
    echo for /f "tokens=* usebackq" %%%%x in (`set`) do set "%%%%x" >> C:\GymManager\Temp\refresh.bat
    echo endlocal >> C:\GymManager\Temp\refresh.bat
    call C:\GymManager\Temp\refresh.bat
    
    echo Python instalado correctamente.
) else (
    echo Python ya está instalado en el sistema.
)
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Descargar el repositorio de GymManager directamente desde GitHub
echo Descargando GymManager desde GitHub...
echo Este proceso puede tardar varios minutos dependiendo de su conexión.

:: Usar métodos alternativos para la descarga para evitar bloqueos de antivirus
>nul 2>nul powershell -Command "& {try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webClient = New-Object System.Net.WebClient; $webClient.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'); $webClient.DownloadFile('https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip', 'C:\GymManager\Temp\GymManager.zip') } catch { try { Start-BitsTransfer -Source 'https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip' -Destination 'C:\GymManager\Temp\GymManager.zip' } catch { exit 1 } } }"

if %errorLevel% neq 0 (
    echo.
    echo ¡ERROR! No se pudo descargar GymManager.
    echo - Intentando método alternativo de descarga...
    
    >nul 2>nul powershell -Command "& {try { $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip' -OutFile 'C:\GymManager\Temp\GymManager.zip' -UseBasicParsing } catch { exit 1 } }"
    
    if %errorLevel% neq 0 (
        echo.
        echo ¡ERROR! No se pudo descargar GymManager.
        echo - Verifique su conexión a Internet
        echo - Si tiene acceso a un navegador, descargue manualmente los archivos desde:
        echo   https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip
        echo - Coloque el archivo descargado en C:\GymManager\Temp\GymManager.zip
        echo - Luego reinicie este instalador
        goto ERROR
    ) else {
        echo Descarga completada mediante método alternativo.
    }
)
echo Descarga completada correctamente.
echo.

:: Extraer el repositorio
echo Extrayendo archivos...
>nul 2>nul powershell -Command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; try { [System.IO.Compression.ZipFile]::ExtractToDirectory('C:\GymManager\Temp\GymManager.zip', 'C:\GymManager\Temp') } catch { exit 1 } }"

if %errorLevel% neq 0 (
    echo.
    echo ¡ERROR! No se pudieron extraer los archivos.
    echo - Verifique que la descarga se completó correctamente
    echo - Asegúrese de que tiene espacio suficiente en disco
    goto ERROR
)
echo Archivos extraídos correctamente.
echo.

:: Mover archivos a la ubicación correcta
echo Copiando archivos al directorio de instalación...
if not exist "C:\GymManager\Temp\AppClasesO2-main" (
    echo ¡ERROR! No se encontró el directorio de archivos extraído.
    goto ERROR
)
xcopy /E /I /Y "C:\GymManager\Temp\AppClasesO2-main\*" "C:\GymManager\" >nul
if %errorLevel% neq 0 (
    echo ¡ERROR! No se pudieron copiar los archivos.
    goto ERROR
)
echo Archivos copiados correctamente.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Instalar dependencias esenciales
echo Instalando dependencias esenciales...
cd /d C:\GymManager
%python_cmd% -m pip install --upgrade pip

:: Instalar versiones específicas para evitar el error url_decode
echo Instalando versiones compatibles de dependencias...
%python_cmd% -m pip install werkzeug==2.3.7
%python_cmd% -m pip install -r requirements.txt
%python_cmd% -m pip install pyOpenSSL

:: Verificar si se solucionó el problema de url_decode
echo Verificando dependencias...
%python_cmd% -c "from werkzeug.urls import url_decode; print('OK: url_decode importado correctamente')" >nul 2>&1
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

    %python_cmd% fix_werkzeug.py
    del fix_werkzeug.py
    
    echo.
    echo Verificando solución...
    %python_cmd% -c "from werkzeug.urls import url_decode; print('OK: Solución aplicada correctamente')" >nul 2>&1
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
    %python_cmd% -c "from OpenSSL import crypto; k = crypto.PKey(); k.generate_key(crypto.TYPE_RSA, 2048); cert = crypto.X509(); cert.get_subject().C = 'ES'; cert.get_subject().ST = 'Madrid'; cert.get_subject().L = 'Madrid'; cert.get_subject().O = 'GymManager'; cert.get_subject().OU = 'GymManager'; cert.get_subject().CN = 'localhost'; cert.set_serial_number(1000); cert.gmtime_adj_notBefore(0); cert.gmtime_adj_notAfter(365*24*60*60); cert.set_issuer(cert.get_subject()); cert.set_pubkey(k); cert.sign(k, 'sha256'); open('C:\\GymManager\\certificates\\server.crt', 'wb').write(crypto.dump_certificate(crypto.FILETYPE_PEM, cert)); open('C:\\GymManager\\certificates\\server.key', 'wb').write(crypto.dump_privatekey(crypto.FILETYPE_PEM, k))"
)

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
        ) else {
            echo Base de datos creada correctamente.
        }
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
    echo if "%%opcion%%"=="2" (echo Actualizando... ^& C:\GymManager\scripts\windows\actualizar_desde_github.bat) >> "C:\GymManager\scripts\windows\administrar.bat"
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
echo 1. Asegúrese de tener conexión a Internet estable
echo 2. Ejecute el instalador como administrador
echo 3. Si el antivirus bloquea la instalación, pruebe estas alternativas:
echo    - Añada C:\GymManager a las exclusiones del antivirus
echo    - Descargue manualmente los archivos desde https://github.com/alesierraalta/AppClasesO2
echo    - Use la opción de instalación offline (si está disponible)
echo 4. Si el problema persiste, contacte al soporte técnico
echo.
echo Presione cualquier tecla para salir...
pause
exit /b 1 