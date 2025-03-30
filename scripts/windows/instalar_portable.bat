@echo off
title Instalador Portable de GymManager
color 0A
echo ====================================================================
echo            INSTALADOR PORTABLE DE GYMMANAGER
echo ====================================================================
echo.
echo Este script instalará GymManager como aplicación portable
echo en la misma carpeta donde se encuentra el repositorio.
echo.
echo No se requiere instalación en el disco C:.
echo.
echo Presiona cualquier tecla para continuar...
pause
cls

:: Determinar ruta del script actual y establecer la instalación portable
set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%..\..\"
set "INSTALL_DIR=%REPO_ROOT%"
cd "%REPO_ROOT%"

echo Instalando GymManager en modo portable en:
echo %INSTALL_DIR%
echo.

:: Verificar que estamos en el repositorio
if not exist "%REPO_ROOT%\main.py" (
    echo.
    echo ¡ERROR! No se encontró el archivo main.py en el repositorio.
    echo Asegúrese de ejecutar este script desde la carpeta correcta:
    echo scripts\windows\instalar_portable.bat
    echo.
    goto ERROR
)

:: Crear directorios necesarios
echo Creando directorios de datos...
mkdir "%INSTALL_DIR%\logs" 2>nul
mkdir "%INSTALL_DIR%\database" 2>nul
mkdir "%INSTALL_DIR%\backups" 2>nul
mkdir "%INSTALL_DIR%\temp" 2>nul
mkdir "%INSTALL_DIR%\app\uploads" 2>nul
mkdir "%INSTALL_DIR%\app\core" 2>nul
echo Directorios creados correctamente.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Verificar si Python está instalado
echo Verificando instalacion de Python...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo Python no está instalado en su sistema.
    echo Descargando e instalando Python automáticamente...
    echo.
    
    :: Crear directorio temporal si no existe
    mkdir "%INSTALL_DIR%\temp" 2>nul
    
    :: Descargar Python
    echo Descargando Python 3.8.10 (esto puede tomar unos minutos)...
    echo Por favor, espere...
    
    :: Usar métodos alternativos para la descarga para evitar bloqueos de antivirus
    >nul 2>nul powershell -Command "& {try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webClient = New-Object System.Net.WebClient; $webClient.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'); $webClient.DownloadFile('https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe', '%INSTALL_DIR%\temp\python-installer.exe') } catch { try { Start-BitsTransfer -Source 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe' -Destination '%INSTALL_DIR%\temp\python-installer.exe' } catch { exit 1 } } }"
    
    if %errorLevel% neq 0 (
        echo.
        echo ¡ERROR! No se pudo descargar Python.
        echo - Intentando método alternativo de descarga...
        
        >nul 2>nul powershell -Command "& {try { $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe' -OutFile '%INSTALL_DIR%\temp\python-installer.exe' -UseBasicParsing } catch { exit 1 } }"
        
        if %errorLevel% neq 0 (
            echo.
            echo ¡ERROR! No se pudo descargar Python.
            echo - Verifique su conexión a Internet
            goto ERROR
        ) else (
            echo Descarga completada mediante método alternativo.
        )
    )
    
    :: Instalar Python silenciosamente y agregar al PATH
    echo Instalando Python 3.8.10...
    "%INSTALL_DIR%\temp\python-installer.exe" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_doc=0
    
    if %errorLevel% neq 0 (
        echo ¡ERROR! No se pudo instalar Python.
        goto ERROR
    )
    
    :: Refrescar variables de entorno para reconocer Python recién instalado
    echo Actualizando variables de entorno...
    :: Refrescar PATH para este script
    for /f "tokens=2*" %%a in ('reg query HKCU\Environment /v PATH') do set "USERPATH=%%b"
    for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH') do set "SYSTEMPATH=%%b"
    set "PATH=%USERPATH%;%SYSTEMPATH%;%PATH%"
    
    :: Verificar de nuevo si Python está instalado
    echo Verificando instalación de Python...
    python --version >nul 2>&1
    if %errorLevel% neq 0 (
        echo.
        echo ¡ERROR! La instalación de Python falló o Python no está en el PATH.
        echo Es posible que necesite cerrar y abrir una nueva ventana de comandos.
        echo.
        echo Para continuar la instalación manualmente:
        echo 1. Reinicie su computadora para asegurar que PATH se actualice
        echo 2. Ejecute este script nuevamente
        goto ERROR
    ) else (
        echo.
        echo Python ha sido instalado exitosamente.
    )
    
) else (
    echo Python ya está instalado en el sistema.
)
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Instalar dependencias de Python
echo Instalando dependencias de Python...
if not exist "%INSTALL_DIR%\requirements.txt" (
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

:: Configurar archivos
echo { "pc_number": %PC_NUM%, "is_server": %PC_NUM% == 1, "sync_enabled": true } > "%INSTALL_DIR%\app\core\pc_config.json"
echo { "install_mode": "portable", "app_path": "%INSTALL_DIR%" } > "%INSTALL_DIR%\app\core\install_config.json"

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
    
    echo { "server_ip": "%SERVER_IP%", "server_port": 5000 } > "%INSTALL_DIR%\app\core\network_config.json"
    echo Configuración de red guardada.
) else (
    echo Esta PC es la principal. No se requiere configuración adicional.
)
echo.

:: Crear base de datos si no existe
echo Configurando base de datos...
if not exist "%INSTALL_DIR%\database\gimnasio.db" (
    cd "%INSTALL_DIR%"
    if exist "%INSTALL_DIR%\database\create_tables.py" (
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

:: Crear o actualizar scripts de ejecución
if not exist "%INSTALL_DIR%\scripts\windows\run_portable.bat" (
    echo @echo off > "%INSTALL_DIR%\scripts\windows\run_portable.bat"
    echo cd "%INSTALL_DIR%" >> "%INSTALL_DIR%\scripts\windows\run_portable.bat"
    echo python main.py >> "%INSTALL_DIR%\scripts\windows\run_portable.bat"
    echo pause >> "%INSTALL_DIR%\scripts\windows\run_portable.bat"
)

if not exist "%INSTALL_DIR%\scripts\windows\administrar_portable.bat" (
    echo @echo off > "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo cd "%INSTALL_DIR%" >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo echo ===== PANEL DE ADMINISTRACION ===== >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo echo. >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo echo 1. Iniciar GymManager >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo echo 2. Actualizar GymManager >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo echo 3. Verificar base de datos >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo echo 4. Salir >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo echo. >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo set /p opcion="Seleccione una opcion: " >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo. >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo if "%%opcion%%"=="1" (cd "%INSTALL_DIR%" ^& python main.py) >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo if "%%opcion%%"=="2" (echo Actualizando... ^& call "%INSTALL_DIR%\scripts\windows\actualizar_portable.bat") >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo if "%%opcion%%"=="3" (cd "%INSTALL_DIR%" ^& python database\view_tables.py ^& pause) >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo if "%%opcion%%"=="4" exit >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
    echo. >> "%INSTALL_DIR%\scripts\windows\administrar_portable.bat"
)

:: Creación del script de inicio rápido en la raíz
if not exist "%INSTALL_DIR%\GymManager.bat" (
    echo @echo off > "%INSTALL_DIR%\GymManager.bat"
    echo cd "%INSTALL_DIR%" >> "%INSTALL_DIR%\GymManager.bat"
    echo python main.py >> "%INSTALL_DIR%\GymManager.bat"
    echo pause >> "%INSTALL_DIR%\GymManager.bat"
)

:: Creación del script de administración rápido en la raíz
if not exist "%INSTALL_DIR%\Administrar.bat" (
    echo @echo off > "%INSTALL_DIR%\Administrar.bat"
    echo call "%INSTALL_DIR%\scripts\windows\administrar_portable.bat" >> "%INSTALL_DIR%\Administrar.bat"
)

echo Accesos directos creados en la carpeta de la aplicación.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Finalización
echo ====================================================================
echo            INSTALACION PORTABLE COMPLETADA EXITOSAMENTE
echo ====================================================================
echo.
echo GymManager ha sido instalado en modo portable en:
echo %INSTALL_DIR%
echo.
echo Para iniciar la aplicación, use el archivo:
echo - GymManager.bat (en la carpeta principal)
echo.
echo Para administrar la aplicación, use:
echo - Administrar.bat (en la carpeta principal)
echo.
echo IMPORTANTE: No mueva estos archivos fuera de su carpeta actual,
echo ya que la instalación es portable y depende de la ubicación relativa
echo de los archivos.
echo.
echo Presione cualquier tecla para finalizar...
pause
exit /b 0

:ERROR
echo.
echo ====================================================================
echo                 ERROR DE INSTALACION PORTABLE
echo ====================================================================
echo.
echo Ha ocurrido un error durante la instalación portable.
echo.
echo Intente los siguientes pasos:
echo 1. Verifique que Python está instalado correctamente
echo 2. Compruebe que está ejecutando el script desde el directorio correcto
echo 3. Asegúrese de tener permisos de escritura en la carpeta actual
echo 4. Si el problema persiste, contacte al soporte técnico
echo.
echo Presione cualquier tecla para salir...
pause
exit /b 1 