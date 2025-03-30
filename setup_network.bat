@echo off
setlocal enabledelayedexpansion

echo ======================================
echo  GymManager - Configuracion de Red
echo ======================================
echo.

REM Detectar IP local
echo Detectando IP local...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /r /c:"IPv4"') do (
    set IP=%%a
    set IP=!IP:~1!
    goto :found_ip
)

:found_ip
echo IP local detectada: %IP%
echo.

REM Definir modo de la computadora
echo Seleccione el tipo de computadora:
echo 1 - Principal (Gerente - solo una computadora debe ser principal)
echo 2 - Recepcion 1
echo 3 - Recepcion 2
echo.
set /p COMPUTER_TYPE="Ingrese el numero (1, 2 o 3): "

if "%COMPUTER_TYPE%"=="1" (
    set IS_PRIMARY=true
    set COMPUTER_NAME=Gerencia
) else if "%COMPUTER_TYPE%"=="2" (
    set IS_PRIMARY=false
    set COMPUTER_NAME=Recepcion 1
) else if "%COMPUTER_TYPE%"=="3" (
    set IS_PRIMARY=false
    set COMPUTER_NAME=Recepcion 2
) else (
    echo Opcion invalida. Seleccionando Recepcion 1 por defecto.
    set IS_PRIMARY=false
    set COMPUTER_NAME=Recepcion 1
)

echo.
echo Configurando como: %COMPUTER_NAME% (Principal: %IS_PRIMARY%)

REM Configurar IPs de las otras computadoras
echo.
echo Por favor ingrese las IPs de las computadoras en la red:
echo Deje en blanco para usar la configuracion predeterminada:
echo - 192.168.1.100 (Gerencia)
echo - 192.168.1.101 (Recepcion 1)
echo - 192.168.1.102 (Recepcion 2)
echo.

REM Establecer valores predeterminados
set IP_MAIN=192.168.1.100
set IP_REC1=192.168.1.101
set IP_REC2=192.168.1.102

echo IMPORTANTE: Si no conoce las IPs exactas, deje en blanco los campos
echo para usar valores predeterminados y luego actualice manualmente.
echo.

set /p IP_MAIN_INPUT="IP de Gerencia: "
set /p IP_REC1_INPUT="IP de Recepcion 1: "
set /p IP_REC2_INPUT="IP de Recepcion 2: "

if not "%IP_MAIN_INPUT%"=="" set IP_MAIN=%IP_MAIN_INPUT%
if not "%IP_REC1_INPUT%"=="" set IP_REC1=%IP_REC1_INPUT%
if not "%IP_REC2_INPUT%"=="" set IP_REC2=%IP_REC2_INPUT%

echo.
echo Creando archivo de configuracion sync_config.json...

echo {> sync_config.json
echo     "sync_interval": 300,>> sync_config.json
echo     "is_primary_server": %IS_PRIMARY%,>> sync_config.json
echo     "sync_servers": [>> sync_config.json
echo         "http://%IP_MAIN%:5000/sync",>> sync_config.json
echo         "http://%IP_REC1%:5000/sync",>> sync_config.json
echo         "http://%IP_REC2%:5000/sync">> sync_config.json
echo     ],>> sync_config.json
echo     "server_name": "%COMPUTER_NAME%",>> sync_config.json
echo     "backup_folder": "backups">> sync_config.json
echo }>> sync_config.json

echo.
echo ¡Configuracion guardada correctamente!
echo.

REM Compilar la aplicación si se selecciona la opción
echo ¿Desea compilar la aplicacion ahora? (S/N)
set /p COMPILE_NOW="Ingrese S para compilar o N para salir: "

if /i "%COMPILE_NOW%"=="S" (
    echo.
    echo Iniciando compilacion...
    call build_app.bat
) else (
    echo.
    echo Para compilar la aplicacion mas tarde, ejecute build_app.bat
)

echo.
echo ======================================
echo     Configuracion completada
echo ======================================
echo.
echo ¡Configuracion finalizada! Ahora puede:
echo 1. Compilar la aplicacion con build_app.bat (si aun no lo ha hecho)
echo 2. Ejecutar la aplicacion con dist\GymManager.exe
echo.

pause 