@echo off
title Test de Configuración de PC - GymManager
color 0A
setlocal enabledelayedexpansion

echo ====================================================================
echo           TEST DE CONFIGURACIÓN DE RED - GYMMANAGER
echo ====================================================================
echo.
echo Este script verificará la configuración de red y conectividad
echo para el sistema de sincronización de GymManager.
echo.

:: Determinar si es PC principal o secundaria
set "SCRIPT_DIR=%~dp0"
set "BASE_DIR=%SCRIPT_DIR%..\..\"
cd /d "%BASE_DIR%"

set IS_SERVER=true
set PC_NUM=1

:: Verificar si estamos en modo ejecutable o modo script
if exist "dist" (
    set "CONFIG_DIR=dist\data\config"
) else if exist "app" (
    set "CONFIG_DIR=app\core"
) else (
    set "CONFIG_DIR=config"
)

:: Verificar configuración de PC
if exist "%CONFIG_DIR%\pc_config.json" (
    echo Leyendo configuración de PC...
    
    :: Intentar leer el archivo con PowerShell para extraer valores JSON
    for /f "tokens=*" %%a in ('powershell -Command "Get-Content '%CONFIG_DIR%\pc_config.json' | ConvertFrom-Json | Select-Object -ExpandProperty pc_number"') do (
        set PC_NUM=%%a
    )
    
    for /f "tokens=*" %%a in ('powershell -Command "Get-Content '%CONFIG_DIR%\pc_config.json' | ConvertFrom-Json | Select-Object -ExpandProperty is_server"') do (
        set IS_SERVER=%%a
    )
    
    echo - Número de PC: !PC_NUM!
    echo - Tipo: !IS_SERVER!
) else (
    echo No se encontró archivo de configuración de PC.
    echo Usando valores por defecto (PC1 - Servidor).
)

:: Mostrar información de red
echo.
echo Información de red:
echo -----------------
ipconfig | findstr /C:"IPv4"
echo.

:: Función para probar conexión a un servidor
echo Pruebas de conectividad:
echo -----------------

:: Si es PC secundaria, verificar conexión al servidor principal
if /i "!IS_SERVER!"=="false" (
    if exist "%CONFIG_DIR%\network_config.json" (
        echo Verificando conexión al servidor principal...
        
        :: Leer configuración de red
        for /f "tokens=*" %%a in ('powershell -Command "Get-Content '%CONFIG_DIR%\network_config.json' | ConvertFrom-Json | Select-Object -ExpandProperty server_ip"') do (
            set SERVER_IP=%%a
        )
        
        for /f "tokens=*" %%a in ('powershell -Command "Get-Content '%CONFIG_DIR%\network_config.json' | ConvertFrom-Json | Select-Object -ExpandProperty server_port"') do (
            set SERVER_PORT=%%a
        )
        
        echo - Servidor: !SERVER_IP!:!SERVER_PORT!
        echo.
        
        :: Probar ping al servidor
        echo Probando ping al servidor (!SERVER_IP!)...
        ping -n 4 !SERVER_IP!
        
        :: Probar puerto HTTP (5000)
        echo.
        echo Probando puerto HTTP (!SERVER_PORT!) del servidor...
        powershell -Command "Test-NetConnection -ComputerName !SERVER_IP! -Port !SERVER_PORT! | Format-List"
        
        :: Probar puerto de sincronización (8000)
        echo.
        echo Probando puerto de sincronización (8000) del servidor...
        powershell -Command "Test-NetConnection -ComputerName !SERVER_IP! -Port 8000 | Format-List"
    ) else (
        echo No se encontró archivo de configuración de red.
        echo No se puede verificar la conexión al servidor principal.
    )
) else (
    echo Esta es la PC principal (servidor).
    echo Verificando puertos de escucha...
    
    :: Verificar puerto HTTP (5000)
    echo.
    echo Probando puerto HTTP (5000)...
    powershell -Command "Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue | Format-Table -Property LocalAddress,LocalPort,State"
    
    :: Verificar puerto sincronización (8000)
    echo.
    echo Probando puerto de sincronización (8000)...
    powershell -Command "Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | Format-Table -Property LocalAddress,LocalPort,State"
    
    :: Verificar firewall
    echo.
    echo Verificando reglas de firewall...
    powershell -Command "Get-NetFirewallRule -DisplayName '*GymManager*' | Format-Table -Property DisplayName,Enabled,Direction,Action"
)

echo.
echo ====================================================================
echo           PRUEBAS DE RED COMPLETADAS
echo ====================================================================
echo.
echo Presione cualquier tecla para finalizar...
pause >nul 