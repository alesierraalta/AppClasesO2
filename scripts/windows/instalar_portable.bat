@echo off
title Instalador Portable de GymManager
color 0A
setlocal enabledelayedexpansion

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

:: Eliminar comillas si las hay y asegurar que las rutas terminan con \
set "INSTALL_DIR=!INSTALL_DIR:"=!"
if not "!INSTALL_DIR:~-1!"=="\" set "INSTALL_DIR=!INSTALL_DIR!\"

echo Cambiando al directorio de instalación: !INSTALL_DIR!
cd /d "!INSTALL_DIR!"
if %errorLevel% neq 0 (
    echo ERROR: No se pudo cambiar al directorio !INSTALL_DIR!
    echo Directorio actual: %cd%
    goto ERROR
)

echo Instalando GymManager en modo portable en:
echo !INSTALL_DIR!
echo.
echo Directorio actual de trabajo: %cd%
echo.

:: Verificar que estamos en el repositorio
if not exist "!INSTALL_DIR!main.py" (
    echo.
    echo ¡ERROR! No se encontró el archivo main.py en el repositorio.
    echo Asegúrese de ejecutar este script desde la carpeta correcta:
    echo scripts\windows\instalar_portable.bat
    echo.
    echo Ubicación actual: !INSTALL_DIR!
    echo Contenido del directorio:
    dir "!INSTALL_DIR!"
    goto ERROR
)

:: Crear directorios necesarios con verificación explícita
echo Creando directorios de datos...
echo.

echo Intentando crear: logs
mkdir "!INSTALL_DIR!logs" 2>nul
if not exist "!INSTALL_DIR!logs" (
    echo ¡ERROR! No se pudo crear el directorio logs
    echo Intentando con ruta completa...
    mkdir "!INSTALL_DIR!logs"
    if !errorLevel! neq 0 (
        echo Error al crear el directorio logs
        goto ERROR
    )
)
echo - Directorio logs creado exitosamente.

echo Intentando crear: database
mkdir "!INSTALL_DIR!database" 2>nul
if not exist "!INSTALL_DIR!database" (
    echo ¡ERROR! No se pudo crear el directorio database
    mkdir "!INSTALL_DIR!database"
    if !errorLevel! neq 0 (
        echo Error al crear el directorio database
        goto ERROR
    )
)
echo - Directorio database creado exitosamente.

echo Intentando crear: backups
mkdir "!INSTALL_DIR!backups" 2>nul
if not exist "!INSTALL_DIR!backups" (
    mkdir "!INSTALL_DIR!backups"
    if !errorLevel! neq 0 (
        echo Error al crear el directorio backups
        goto ERROR
    )
)
echo - Directorio backups creado exitosamente.

echo Intentando crear: temp
mkdir "!INSTALL_DIR!temp" 2>nul
if not exist "!INSTALL_DIR!temp" (
    mkdir "!INSTALL_DIR!temp"
    if !errorLevel! neq 0 (
        echo Error al crear el directorio temp
        goto ERROR
    )
)
echo - Directorio temp creado exitosamente.

echo Intentando crear: app\uploads
mkdir "!INSTALL_DIR!app\uploads" 2>nul
if not exist "!INSTALL_DIR!app\uploads" (
    mkdir "!INSTALL_DIR!app"
    mkdir "!INSTALL_DIR!app\uploads"
    if !errorLevel! neq 0 (
        echo Error al crear el directorio app\uploads
        goto ERROR
    )
)
echo - Directorio app\uploads creado exitosamente.

echo Intentando crear: app\core
mkdir "!INSTALL_DIR!app\core" 2>nul
if not exist "!INSTALL_DIR!app\core" (
    mkdir "!INSTALL_DIR!app\core"
    if !errorLevel! neq 0 (
        echo Error al crear el directorio app\core
        goto ERROR
    )
)
echo - Directorio app\core creado exitosamente.

echo.
echo Directorios creados correctamente.
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Verificar si Python está instalado
echo Verificando instalacion de Python...
where python >nul 2>nul
if %errorLevel% neq 0 (
    echo Python no se encuentra en el PATH del sistema.
    echo Descargando e instalando Python automáticamente...
    echo.
    
    :: Crear directorio temporal si no existe
    echo Creando directorio temporal para Python...
    if not exist "!INSTALL_DIR!temp" (
        mkdir "!INSTALL_DIR!temp"
    )
    
    :: Descargar Python
    echo Descargando Python 3.8.10 (esto puede tomar unos minutos)...
    echo Por favor, espere...
    
    :: Simplificar la descarga para reducir errores
    echo Intentando descargar Python con PowerShell...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe' -OutFile '!INSTALL_DIR!temp\python-installer.exe' } catch { Write-Host 'Error al descargar Python: $_'; exit 1 } }"
    
    if %errorLevel% neq 0 (
        echo.
        echo ¡ERROR! No se pudo descargar Python con PowerShell.
        echo - Intentando método alternativo de descarga...
        
        echo Intentando descargar con BITS...
        powershell -Command "& {try { Start-BitsTransfer -Source 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe' -Destination '!INSTALL_DIR!temp\python-installer.exe' } catch { Write-Host 'Error al descargar Python con BITS: $_'; exit 1 } }"
        
        if %errorLevel% neq 0 (
            echo.
            echo ¡ERROR! No se pudo descargar Python usando BITS.
            echo.
            echo Por favor, descargue Python manualmente desde:
            echo https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe
            echo.
            echo Luego coloque el archivo en: !INSTALL_DIR!temp\python-installer.exe
            echo y ejecute este script nuevamente.
            echo.
            echo Presione cualquier tecla para salir...
            pause
            goto ERROR
        ) else (
            echo Descarga completada mediante BITS Transfer.
        )
    ) else (
        echo Descarga completada con PowerShell.
    )
    
    :: Verificar que el archivo de instalación exista
    if not exist "!INSTALL_DIR!temp\python-installer.exe" (
        echo.
        echo ¡ERROR! No se encontró el instalador de Python después de la descarga.
        echo Por favor, descargue Python manualmente.
        goto ERROR
    )
    
    :: Instalar Python silenciosamente y agregar al PATH
    echo.
    echo Instalando Python 3.8.10...
    echo Este proceso puede tardar varios minutos. Por favor espere...
    echo.
    
    "!INSTALL_DIR!temp\python-installer.exe" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_doc=0
    
    echo Esperando a que la instalación de Python finalice...
    :: Esperar 30 segundos para dar tiempo a que la instalación se complete
    ping 127.0.0.1 -n 30 > nul
    
    :: Refrescar variables de entorno para reconocer Python recién instalado
    echo Actualizando variables de entorno...
    echo.
    
    :: Agregar Python al PATH del script actual
    for /f "tokens=*" %%a in ('where /r "%USERPROFILE%\AppData\Local\Programs\Python" python.exe 2^>nul') do set "PYTHON_PATH=%%~dpa"
    set "PATH=!PYTHON_PATH!;!PATH!"
    
    :: Verificar de nuevo si Python está instalado
    echo Verificando instalación de Python...
    echo.
    
    where python > "!INSTALL_DIR!temp\python_path.txt"
    if %errorLevel% neq 0 (
        echo.
        echo ¡ATENCIÓN! Python se instaló pero no se puede detectar en el PATH.
        echo.
        echo Esto es normal después de la instalación, ya que es necesario reiniciar
        echo el símbolo del sistema para que reconozca las nuevas variables de entorno.
        echo.
        echo Sin embargo, intentaremos continuar con la instalación usando la 
        echo ruta completa a Python.
        echo.
        
        :: Buscar Python en las ubicaciones habituales
        for /f "tokens=*" %%a in ('dir /b /s "%LOCALAPPDATA%\Programs\Python\*python.exe" 2^>nul') do (
            echo Python encontrado en: %%a
            set "PYTHON_EXE=%%a"
        )
        
        if not defined PYTHON_EXE (
            echo Python no se pudo encontrar automáticamente.
            echo.
            echo Por favor, cierre esta ventana, abra una nueva línea de comandos 
            echo y ejecute el script nuevamente.
            echo.
            echo Si el problema persiste, reinicie su computadora y vuelva a intentarlo.
            echo.
            pause
            goto ERROR
        )
        
        echo Usando Python desde: !PYTHON_EXE!
        echo.
    ) else (
        echo Python ha sido instalado correctamente y está disponible en el PATH.
        set "PYTHON_EXE=python"
    )
    
) else (
    echo Python ya está instalado en el sistema.
    set "PYTHON_EXE=python"
)
echo.

echo Presione cualquier tecla para continuar...
pause
cls

:: Instalar dependencias de Python
echo Instalando dependencias de Python...
if not exist "!INSTALL_DIR!requirements.txt" (
    echo ¡ERROR! No se encontró el archivo requirements.txt
    echo Buscando en: !INSTALL_DIR!requirements.txt
    echo Directorio actual: %cd%
    echo Contenido del directorio:
    dir "!INSTALL_DIR!"
    goto ERROR
)

echo Actualizando pip...
if defined PYTHON_EXE (
    "!PYTHON_EXE!" -m pip install --upgrade pip
) else (
    python -m pip install --upgrade pip
)

if %errorLevel% neq 0 (
    echo ¡ERROR! No se pudo actualizar pip.
    goto ERROR
)

echo Instalando dependencias desde requirements.txt...
if defined PYTHON_EXE (
    "!PYTHON_EXE!" -m pip install -r "!INSTALL_DIR!requirements.txt"
) else (
    pip install -r "!INSTALL_DIR!requirements.txt"
)

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
echo Guardando configuración en: !INSTALL_DIR!app\core\pc_config.json
echo { "pc_number": %PC_NUM%, "is_server": %PC_NUM% == 1, "sync_enabled": true } > "!INSTALL_DIR!app\core\pc_config.json"
echo { "install_mode": "portable", "app_path": "!INSTALL_DIR!" } > "!INSTALL_DIR!app\core\install_config.json"

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
    
    echo { "server_ip": "%SERVER_IP%", "server_port": 5000 } > "!INSTALL_DIR!app\core\network_config.json"
    echo Configuración de red guardada.
) else (
    echo Esta PC es la principal. No se requiere configuración adicional.
)
echo.

:: Crear base de datos si no existe
echo Configurando base de datos...
if not exist "!INSTALL_DIR!database\gimnasio.db" (
    cd /d "!INSTALL_DIR!"
    if exist "!INSTALL_DIR!database\create_tables.py" (
        echo Ejecutando script de creación de tablas...
        
        if defined PYTHON_EXE (
            "!PYTHON_EXE!" "!INSTALL_DIR!database\create_tables.py"
        ) else (
            python database\create_tables.py
        )
        
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
echo Creando accesos directos de ejecución...

:: Crear o actualizar scripts de ejecución
echo Creando script run_portable.bat...
if exist "!INSTALL_DIR!scripts\windows\run_portable.bat" (
    del "!INSTALL_DIR!scripts\windows\run_portable.bat"
)
(
echo @echo off
echo cd /d "!INSTALL_DIR!"
echo python main.py
echo pause
) > "!INSTALL_DIR!scripts\windows\run_portable.bat"

echo Creando script administrar_portable.bat...
if exist "!INSTALL_DIR!scripts\windows\administrar_portable.bat" (
    del "!INSTALL_DIR!scripts\windows\administrar_portable.bat"
)
(
echo @echo off
echo cd /d "!INSTALL_DIR!"
echo echo ===== PANEL DE ADMINISTRACION =====
echo echo.
echo echo 1. Iniciar GymManager
echo echo 2. Actualizar GymManager
echo echo 3. Verificar base de datos
echo echo 4. Salir
echo echo.
echo set /p opcion="Seleccione una opcion: "
echo.
echo if "%%opcion%%"=="1" ^(cd /d "!INSTALL_DIR!" ^& python main.py^)
echo if "%%opcion%%"=="2" ^(echo Actualizando... ^& call "!INSTALL_DIR!scripts\windows\actualizar_portable.bat"^)
echo if "%%opcion%%"=="3" ^(cd /d "!INSTALL_DIR!" ^& python database\view_tables.py ^& pause^)
echo if "%%opcion%%"=="4" exit
echo.
) > "!INSTALL_DIR!scripts\windows\administrar_portable.bat"

:: Creación del script de inicio rápido en la raíz
echo Creando acceso directo GymManager.bat...
if exist "!INSTALL_DIR!GymManager.bat" (
    del "!INSTALL_DIR!GymManager.bat"
)
(
echo @echo off
echo cd /d "!INSTALL_DIR!"
echo python main.py
echo pause
) > "!INSTALL_DIR!GymManager.bat"

:: Creación del script de administración rápido en la raíz
echo Creando acceso directo Administrar.bat...
if exist "!INSTALL_DIR!Administrar.bat" (
    del "!INSTALL_DIR!Administrar.bat"
)
(
echo @echo off
echo call "!INSTALL_DIR!scripts\windows\administrar_portable.bat"
) > "!INSTALL_DIR!Administrar.bat"

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
echo !INSTALL_DIR!
echo.
echo Verificación final:
echo ✓ Directorios creados
if exist "!INSTALL_DIR!app\core\pc_config.json" echo ✓ Configuración guardada
if exist "!INSTALL_DIR!GymManager.bat" echo ✓ Accesos directos creados
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
echo Detalles del sistema:
echo - Directorio actual: %cd%
echo - Directorio de instalación: !INSTALL_DIR!
echo.
echo Intente los siguientes pasos:
echo 1. Asegúrese de que está ejecutando el script desde el directorio correcto
echo 2. Verifique que tiene permisos de escritura en la carpeta actual
echo 3. Si el problema persiste, contacte al soporte técnico
echo.
echo Presione cualquier tecla para salir...
pause
exit /b 1 