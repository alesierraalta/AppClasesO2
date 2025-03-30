@echo off
setlocal enabledelayedexpansion

:MENU
cls
echo ================================================
echo          PANEL DE ADMINISTRACION DE GYMMANAGER
echo ================================================
echo.
echo [1] Iniciar GymManager
echo [2] Verificar estado de la red
echo [3] Configurar sincronizacion
echo [4] Ver logs y diagnosticos
echo [5] Forzar sincronizacion manual
echo [6] Realizar respaldo de la base de datos
echo [7] Restaurar base de datos desde respaldo
echo [0] Salir
echo.
set /p OPTION="Seleccione una opcion: "

if "%OPTION%"=="1" goto :START_APP
if "%OPTION%"=="2" goto :CHECK_NETWORK
if "%OPTION%"=="3" goto :CONFIG_SYNC
if "%OPTION%"=="4" goto :VIEW_LOGS
if "%OPTION%"=="5" goto :FORCE_SYNC
if "%OPTION%"=="6" goto :BACKUP_DB
if "%OPTION%"=="7" goto :RESTORE_DB
if "%OPTION%"=="0" goto :EOF

echo Opcion invalida. Intente nuevamente.
timeout /t 2 >nul
goto :MENU

:START_APP
cls
echo Iniciando GymManager...

if exist dist\GymManager.exe (
    start "" "dist\GymManager.exe"
    echo Aplicacion iniciada correctamente.
) else (
    echo ERROR: No se encontro el ejecutable.
    echo Debe compilar la aplicacion primero con build_app.bat
)

timeout /t 3 >nul
goto :MENU

:CHECK_NETWORK
cls
echo Verificando estado de la red...
call verificar_red.bat
goto :MENU

:CONFIG_SYNC
cls
echo Configurando sincronizacion...
call setup_network.bat
goto :MENU

:VIEW_LOGS
cls
echo ================================================
echo                 LOGS DEL SISTEMA
echo ================================================
echo.
echo [1] Ver logs de la aplicacion
echo [2] Ver logs de sincronizacion
echo [3] Ver informacion de sistema
echo [0] Volver al menu principal
echo.
set /p LOG_OPTION="Seleccione una opcion: "

if "%LOG_OPTION%"=="1" (
    cls
    echo *** ULTIMAS 30 LINEAS DEL LOG DE APLICACION ***
    echo.
    if exist gymmanager.log (
        type gymmanager.log | findstr /n "." | findstr /r "^[1-9][0-9]*:" | tail -30
    ) else (
        echo No se encontro el archivo de log.
    )
    echo.
    pause
    goto :VIEW_LOGS
)

if "%LOG_OPTION%"=="2" (
    cls
    echo *** ULTIMAS 30 LINEAS DEL LOG DE SINCRONIZACION ***
    echo.
    if exist gymmanager.log (
        type gymmanager.log | findstr "sincroniza" | tail -30
    ) else (
        echo No se encontro el archivo de log.
    )
    echo.
    pause
    goto :VIEW_LOGS
)

if "%LOG_OPTION%"=="3" (
    cls
    echo *** INFORMACION DEL SISTEMA ***
    echo.
    echo -- Informacion de red --
    ipconfig | findstr /r /c:"IPv4"
    echo.
    echo -- Estado de GymManager --
    tasklist | findstr "GymManager"
    echo.
    echo -- Espacio en disco --
    dir /-c
    echo.
    pause
    goto :VIEW_LOGS
)

if "%LOG_OPTION%"=="0" goto :MENU

echo Opcion invalida. Intente nuevamente.
timeout /t 2 >nul
goto :VIEW_LOGS

:FORCE_SYNC
cls
echo ================================================
echo           SINCRONIZACION MANUAL
echo ================================================
echo.
echo Este proceso intentara sincronizar manualmente
echo la base de datos con las otras computadoras.
echo.
echo IMPORTANTE: Todas las computadoras deben estar
echo encendidas y la aplicacion debe estar ejecutandose.
echo.
echo [1] Continuar con la sincronizacion
echo [0] Cancelar y volver al menu
echo.
set /p SYNC_OPTION="Seleccione una opcion: "

if "%SYNC_OPTION%"=="1" (
    echo.
    echo Iniciando sincronizacion manual...
    echo.
    
    REM Extraer IPs de las computadoras de sync_config.json
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
    
    REM Intentar sincronizacion con cada IP
    set SUCCESS=0
    for /l %%i in (1,1,!COUNT!) do (
        set current_ip=!IP%%i!
        
        REM Evitar sincronizar con la propia IP
        for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /r /c:"IPv4"') do (
            set LOCAL_IP=%%a
            set LOCAL_IP=!LOCAL_IP:~1!
            
            if "!current_ip!" NEQ "!LOCAL_IP!" (
                echo Sincronizando con !current_ip!...
                
                REM Intentar sincronizacion
                curl -s -m 10 -X POST http://!current_ip!:5000/sync >nul
                if !ERRORLEVEL! EQU 0 (
                    echo [OK] Sincronizacion exitosa con !current_ip!
                    set /a SUCCESS+=1
                ) else (
                    echo [ERROR] No se pudo sincronizar con !current_ip!
                )
            )
        )
    )
    
    echo.
    echo Sincronizacion completada con !SUCCESS! de !COUNT! computadoras.
    echo.
    pause
)

goto :MENU

:BACKUP_DB
cls
echo ================================================
echo       RESPALDO MANUAL DE BASE DE DATOS
echo ================================================
echo.

if not exist backups mkdir backups

set TIMESTAMP=%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set BACKUP_FILE=backups\gimnasio_backup_%TIMESTAMP%.db

if exist gimnasio.db (
    echo Creando respaldo en %BACKUP_FILE%...
    copy gimnasio.db "%BACKUP_FILE%" >nul
    
    if exist "%BACKUP_FILE%" (
        echo [OK] Respaldo creado exitosamente.
    ) else (
        echo [ERROR] No se pudo crear el respaldo.
    )
) else (
    echo [ERROR] No se encontro la base de datos.
)

echo.
pause
goto :MENU

:RESTORE_DB
cls
echo ================================================
echo       RESTAURAR BASE DE DATOS
echo ================================================
echo.

if not exist backups (
    echo No se encontraron respaldos.
    echo.
    pause
    goto :MENU
)

echo Respaldos disponibles:
echo.

set COUNT=0
for %%f in (backups\gimnasio_backup_*.db) do (
    set /a COUNT+=1
    echo [!COUNT!] %%~nxf  -  %%~tf
    set "FILE!COUNT!=%%f"
)

if %COUNT% EQU 0 (
    echo No se encontraron respaldos.
    echo.
    pause
    goto :MENU
)

echo.
echo [0] Cancelar y volver al menu
echo.
set /p RESTORE_OPTION="Seleccione un respaldo para restaurar: "

if "%RESTORE_OPTION%"=="0" goto :MENU

if %RESTORE_OPTION% LEQ %COUNT% (
    set SELECTED_FILE=!FILE%RESTORE_OPTION%!
    
    echo.
    echo Esta a punto de restaurar la base de datos desde:
    echo !SELECTED_FILE!
    echo.
    echo ADVERTENCIA: Esto reemplazara la base de datos actual.
    echo Todos los cambios realizados desde este respaldo se perderan.
    echo.
    echo [1] Continuar con la restauracion
    echo [0] Cancelar
    echo.
    set /p CONFIRM="Confirme la restauracion: "
    
    if "%CONFIRM%"=="1" (
        echo.
        echo Restaurando base de datos...
        
        REM Detener la aplicación si está en ejecución
        taskkill /f /im GymManager.exe >nul 2>&1
        
        REM Hacer un respaldo adicional por seguridad
        if exist gimnasio.db (
            set TIMESTAMP=%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
            set TIMESTAMP=%TIMESTAMP: =0%
            copy gimnasio.db "backups\gimnasio_pre_restauracion_%TIMESTAMP%.db" >nul
        )
        
        REM Restaurar desde el respaldo seleccionado
        copy "!SELECTED_FILE!" gimnasio.db /y >nul
        
        echo [OK] Base de datos restaurada exitosamente.
        echo.
        pause
    )
) else (
    echo Opcion invalida. Intente nuevamente.
    timeout /t 2 >nul
)

goto :MENU 