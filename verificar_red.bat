@echo off
setlocal enabledelayedexpansion

echo ================================================
echo      VERIFICADOR DE RED PARA GYMMANAGER
echo ================================================
echo.
echo Este script verificara la conectividad con las
echo otras computadoras definidas en sync_config.json
echo.

REM Verificar que curl esté disponible
curl --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: El comando 'curl' no esta disponible.
    echo Este script requiere curl para funcionar correctamente.
    echo.
    pause
    exit /b 1
)

REM Verificar que sync_config.json existe
if not exist sync_config.json (
    echo ERROR: No se encontro el archivo sync_config.json
    echo Ejecute primero setup_network.bat para configurar la red.
    echo.
    pause
    exit /b 1
)

REM Extraer IPs de las computadoras de sync_config.json
echo Leyendo configuracion de red...
set COUNT=0

for /f "tokens=*" %%a in ('type sync_config.json ^| findstr "http://"') do (
    set line=%%a
    set line=!line:,=!
    set line=!line:"=!
    set line=!line:http://=!
    set line=!line::5000/sync=!
    set line=!line: =!
    set /a COUNT+=1
    set IP!COUNT!=!line!
)

echo Encontradas !COUNT! direcciones IP para verificar.
echo.

echo Esta computadora:
ipconfig | findstr /r /c:"IPv4"
echo.

echo ================================================
echo          VERIFICANDO CONECTIVIDAD
echo ================================================
echo.

REM Verificar conectividad con cada IP
set SUCCESS=0

for /l %%i in (1,1,!COUNT!) do (
    set current_ip=!IP%%i!
    
    REM Evitar comprobar la propia IP
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /r /c:"IPv4"') do (
        set LOCAL_IP=%%a
        set LOCAL_IP=!LOCAL_IP:~1!
        
        if "!current_ip!" NEQ "!LOCAL_IP!" (
            echo Verificando !current_ip!...
            
            REM Intentar ping
            ping -n 1 !current_ip! >nul
            if !ERRORLEVEL! EQU 0 (
                echo [OK] Ping exitoso a !current_ip!
                
                REM Intentar conexión al servicio
                curl -s -m 5 http://!current_ip!:5000/config >nul
                if !ERRORLEVEL! EQU 0 (
                    echo [OK] Servicio GymManager accesible en !current_ip!:5000
                    set /a SUCCESS+=1
                ) else (
                    echo [ERROR] No se puede conectar al servicio GymManager en !current_ip!:5000
                    echo         Posibles causas:
                    echo         - La aplicacion no esta en ejecucion
                    echo         - El firewall esta bloqueando la conexion
                    echo         - El puerto 5000 no esta abierto
                )
            ) else (
                echo [ERROR] No se pudo hacer ping a !current_ip!
                echo         Posibles causas:
                echo         - La computadora esta apagada
                echo         - La IP es incorrecta
                echo         - Hay un problema de red
            )
            echo.
        )
    )
)

echo ================================================
echo             RESUMEN DE VERIFICACION
echo ================================================
echo.

if !SUCCESS! GTR 0 (
    echo Conectividad verificada con !SUCCESS! de !COUNT! computadoras.
    
    if !SUCCESS! EQU !COUNT! (
        echo [EXCELENTE] La red esta correctamente configurada.
    ) else (
        echo [ADVERTENCIA] No todas las computadoras estan accesibles.
        echo               Revise la configuracion de red.
    )
) else (
    echo [ERROR] No se pudo conectar con ninguna computadora.
    echo         Posibles soluciones:
    echo         - Verifique que las computadoras esten encendidas
    echo         - Revise las direcciones IP en sync_config.json
    echo         - Asegurese de que todas las computadoras esten
    echo           conectadas a la misma red
    echo         - Desactive temporalmente el firewall para pruebas
)

echo.
echo Para corregir problemas de conectividad:
echo 1. Ejecute setup_network.bat para actualizar IPs
echo 2. Asegurese de que GymManager este en ejecucion
echo 3. Verifique la configuracion de red de Windows
echo.

pause 