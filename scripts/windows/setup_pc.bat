@echo off
title Configuración de PC - GymManager
color 0A
setlocal enabledelayedexpansion

echo ====================================================================
echo           CONFIGURACIÓN DE PC PARA GYMMANAGER
echo ====================================================================
echo.
echo Este script configurará esta instalación de GymManager para 
echo funcionar en una red con múltiples computadoras.
echo.
echo OPCIONES:
echo   - PC1: Servidor principal (debe configurarse primero)
echo   - PC2/PC3: Equipos secundarios que se sincronizan con el servidor
echo.

:MENU_PRINCIPAL
set PC_NUM=
set /p PC_NUM="¿Qué número de PC es esta? (1, 2 o 3): "

if "%PC_NUM%"=="" set PC_NUM=1
if not "%PC_NUM%"=="1" if not "%PC_NUM%"=="2" if not "%PC_NUM%"=="3" (
    echo.
    echo Número no válido. Debe ser 1, 2 o 3.
    echo.
    goto MENU_PRINCIPAL
)

echo.
echo Ha seleccionado: PC%PC_NUM%
if "%PC_NUM%"=="1" (
    echo Esta será la PC principal (servidor).
    set "IS_SERVER=true"
    set "DESCRIPTION=PC Principal (Servidor)"
) else (
    echo Esta será una PC secundaria (cliente).
    set "IS_SERVER=false"
    if "%PC_NUM%"=="2" (
        set "DESCRIPTION=PC Secundaria 2 (Cliente)"
    ) else (
        set "DESCRIPTION=PC Secundaria 3 (Cliente)"
    )
)

echo.
set SYNC_ENABLED=true
set /p CONFIRM_SYNC="¿Desea habilitar la sincronización? (S/N, por defecto S): "
if /i "%CONFIRM_SYNC%"=="N" set SYNC_ENABLED=false

:: Determinar rutas según el tipo de instalación
set "SCRIPT_DIR=%~dp0"
set "BASE_DIR=%SCRIPT_DIR%..\..\"
cd /d "%BASE_DIR%"

:: Verificar si estamos en modo ejecutable o modo script
if exist "dist" (
    set "CONFIG_DIR=dist\data\config"
) else if exist "app" (
    set "CONFIG_DIR=app\core"
) else (
    set "CONFIG_DIR=config"
)

echo.
echo Creando archivo de configuración para PC%PC_NUM%...
(
echo {
echo   "pc_number": %PC_NUM%,
echo   "is_server": %IS_SERVER%,
echo   "sync_enabled": %SYNC_ENABLED%,
echo   "description": "%DESCRIPTION%"
echo }
) > "%CONFIG_DIR%\pc_config.json"

:: Si es una PC secundaria, configurar la conexión al servidor
if not "%PC_NUM%"=="1" (
    if "%SYNC_ENABLED%"=="true" (
        echo.
        echo Esta PC debe sincronizarse con la PC principal (PC1).
        set SERVER_IP=
        set /p SERVER_IP="Introduce la dirección IP de la PC principal: "
        
        if "%SERVER_IP%"=="" (
            echo IP no válida. Se usará 192.168.1.100 por defecto.
            set SERVER_IP=192.168.1.100
        )
        
        echo.
        echo Creando configuración de red...
        (
        echo {
        echo   "server_ip": "%SERVER_IP%",
        echo   "server_port": 5000,
        echo   "sync_port": 8000,
        echo   "sync_interval": 300,
        echo   "backup_before_sync": true
        echo }
        ) > "%CONFIG_DIR%\network_config.json"
        
        echo Configuración de red guardada.
    ) else (
        echo No se requiere configuración de red ya que la sincronización está desactivada.
    )
) else (
    echo No se requiere configuración de red adicional para la PC principal.
)

echo.
echo ====================================================================
echo           CONFIGURACIÓN COMPLETADA EXITOSAMENTE
echo ====================================================================
echo.
echo Esta computadora ha sido configurada como PC%PC_NUM%.
if "%PC_NUM%"=="1" (
    echo IMPORTANTE: Esta es la PC principal (servidor).
    echo - Debe mantenerse encendida para que otras PCs puedan sincronizarse.
    echo - Asegúrese de que el firewall permita conexiones en los puertos 5000 y 8000.
) else (
    echo IMPORTANTE: Esta es una PC secundaria (cliente).
    echo - Se sincronizará con la PC principal (%SERVER_IP%).
    echo - Asegúrese de que la PC principal esté encendida antes de iniciar GymManager.
)
echo.
echo Para iniciar la aplicación, ejecute:
if exist "dist" (
    echo   GymManager.exe
) else (
    echo   python main.py
)
echo.
echo Presione cualquier tecla para finalizar...
pause >nul 