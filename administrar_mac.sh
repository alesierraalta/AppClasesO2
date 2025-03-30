#!/bin/bash

# Colores para formatear salida
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funciones
show_menu() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}     PANEL DE ADMINISTRACIÓN DE GYMMANAGER      ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    echo -e "${YELLOW}[1]${NC} Iniciar GymManager"
    echo -e "${YELLOW}[2]${NC} Verificar estado de la red"
    echo -e "${YELLOW}[3]${NC} Configurar sincronización"
    echo -e "${YELLOW}[4]${NC} Ver logs y diagnósticos"
    echo -e "${YELLOW}[5]${NC} Forzar sincronización manual"
    echo -e "${YELLOW}[6]${NC} Realizar respaldo de la base de datos"
    echo -e "${YELLOW}[7]${NC} Restaurar base de datos desde respaldo"
    echo -e "${YELLOW}[0]${NC} Salir"
    echo ""
    echo -n "Seleccione una opción: "
}

start_app() {
    clear
    echo -e "${BLUE}Iniciando GymManager...${NC}"
    
    if [ -f "./run_gymmanager.sh" ]; then
        ./run_gymmanager.sh &
        echo -e "${GREEN}Aplicación iniciada correctamente.${NC}"
    else
        echo -e "${RED}ERROR: No se encontró el script de inicio.${NC}"
        echo "Debe ejecutar setup_mac.sh primero para configurar la aplicación."
    fi
    
    echo ""
    read -p "Presione ENTER para continuar..."
}

check_network() {
    clear
    echo -e "${BLUE}Verificando estado de la red...${NC}"
    ./verificar_red_mac.sh
    echo ""
    read -p "Presione ENTER para continuar..."
}

config_sync() {
    clear
    echo -e "${BLUE}Configurando sincronización...${NC}"
    ./setup_mac.sh
    echo ""
    read -p "Presione ENTER para continuar..."
}

view_logs() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}                LOGS DEL SISTEMA               ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    echo -e "${YELLOW}[1]${NC} Ver logs de la aplicación"
    echo -e "${YELLOW}[2]${NC} Ver logs de sincronización"
    echo -e "${YELLOW}[3]${NC} Ver información de sistema"
    echo -e "${YELLOW}[0]${NC} Volver al menú principal"
    echo ""
    echo -n "Seleccione una opción: "
    read LOG_OPTION
    
    case $LOG_OPTION in
        1)
            clear
            echo -e "${YELLOW}*** ÚLTIMAS 30 LÍNEAS DEL LOG DE APLICACIÓN ***${NC}"
            echo ""
            if [ -f "gymmanager.log" ]; then
                tail -n 30 gymmanager.log
            else
                echo -e "${RED}No se encontró el archivo de log.${NC}"
            fi
            echo ""
            read -p "Presione ENTER para continuar..."
            view_logs
            ;;
        2)
            clear
            echo -e "${YELLOW}*** ÚLTIMAS 30 LÍNEAS DEL LOG DE SINCRONIZACIÓN ***${NC}"
            echo ""
            if [ -f "gymmanager.log" ]; then
                grep "sincroniza" gymmanager.log | tail -n 30
            else
                echo -e "${RED}No se encontró el archivo de log.${NC}"
            fi
            echo ""
            read -p "Presione ENTER para continuar..."
            view_logs
            ;;
        3)
            clear
            echo -e "${YELLOW}*** INFORMACIÓN DEL SISTEMA ***${NC}"
            echo ""
            echo -e "${GREEN}-- Información de red --${NC}"
            ifconfig | grep "inet " | grep -v 127.0.0.1
            echo ""
            echo -e "${GREEN}-- Estado de GymManager --${NC}"
            ps aux | grep "desktop_app.py" | grep -v grep
            echo ""
            echo -e "${GREEN}-- Espacio en disco --${NC}"
            df -h .
            echo ""
            read -p "Presione ENTER para continuar..."
            view_logs
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Opción inválida. Intente nuevamente.${NC}"
            sleep 2
            view_logs
            ;;
    esac
}

force_sync() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}            SINCRONIZACIÓN MANUAL              ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    echo -e "${YELLOW}Este proceso intentará sincronizar manualmente${NC}"
    echo -e "${YELLOW}la base de datos con las otras computadoras.${NC}"
    echo ""
    echo -e "${RED}IMPORTANTE: Todas las computadoras deben estar${NC}"
    echo -e "${RED}encendidas y la aplicación debe estar ejecutándose.${NC}"
    echo ""
    echo -e "${YELLOW}[1]${NC} Continuar con la sincronización"
    echo -e "${YELLOW}[0]${NC} Cancelar y volver al menú"
    echo ""
    echo -n "Seleccione una opción: "
    read SYNC_OPTION
    
    if [ "$SYNC_OPTION" == "1" ]; then
        echo ""
        echo -e "${BLUE}Iniciando sincronización manual...${NC}"
        echo ""
        
        # Extraer IPs de las computadoras de sync_config.json
        if ! command -v jq &> /dev/null; then
            echo -e "${RED}ERROR: El comando 'jq' no está disponible.${NC}"
            echo "Este script requiere jq para parsear JSON."
            echo "Instálalo con: brew install jq"
            echo ""
            read -p "Presione ENTER para continuar..."
            return
        fi
        
        IPS=($(cat sync_config.json | jq -r '.sync_servers[]' | sed 's|http://||' | sed 's|:5000/sync||'))
        COUNT=${#IPS[@]}
        
        # Obtener la IP local
        IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -n 1 | awk '{print $2}')
        
        # Intentar sincronización con cada IP
        SUCCESS=0
        for current_ip in "${IPS[@]}"; do
            # Evitar sincronizar con la propia IP
            if [ "$current_ip" != "$IP" ]; then
                echo -e "${YELLOW}Sincronizando con $current_ip...${NC}"
                
                # Intentar sincronización
                curl -s -m 10 -X POST http://$current_ip:5000/sync > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}[OK] Sincronización exitosa con $current_ip${NC}"
                    ((SUCCESS++))
                else
                    echo -e "${RED}[ERROR] No se pudo sincronizar con $current_ip${NC}"
                fi
            fi
        done
        
        echo ""
        echo -e "${GREEN}Sincronización completada con $SUCCESS de $((COUNT-1)) computadoras.${NC}"
        echo ""
        read -p "Presione ENTER para continuar..."
    fi
}

backup_db() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}       RESPALDO MANUAL DE BASE DE DATOS        ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    # Crear carpeta de backups si no existe
    mkdir -p backups
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="backups/gimnasio_backup_$TIMESTAMP.db"
    
    if [ -f "gimnasio.db" ]; then
        echo -e "${YELLOW}Creando respaldo en $BACKUP_FILE...${NC}"
        cp gimnasio.db "$BACKUP_FILE"
        
        if [ -f "$BACKUP_FILE" ]; then
            echo -e "${GREEN}[OK] Respaldo creado exitosamente.${NC}"
        else
            echo -e "${RED}[ERROR] No se pudo crear el respaldo.${NC}"
        fi
    else
        echo -e "${RED}[ERROR] No se encontró la base de datos.${NC}"
    fi
    
    echo ""
    read -p "Presione ENTER para continuar..."
}

restore_db() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}           RESTAURAR BASE DE DATOS             ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    if [ ! -d "backups" ]; then
        echo -e "${RED}No se encontraron respaldos.${NC}"
        echo ""
        read -p "Presione ENTER para continuar..."
        return
    fi
    
    BACKUPS=(backups/gimnasio_backup_*.db)
    
    # Verificar si hay backups
    if [ ${#BACKUPS[@]} -eq 0 ] || [ ! -f "${BACKUPS[0]}" ]; then
        echo -e "${RED}No se encontraron respaldos.${NC}"
        echo ""
        read -p "Presione ENTER para continuar..."
        return
    fi
    
    echo -e "${YELLOW}Respaldos disponibles:${NC}"
    echo ""
    
    COUNT=0
    for file in "${BACKUPS[@]}"; do
        if [ -f "$file" ]; then
            ((COUNT++))
            FILEDATE=$(date -r "$file" "+%d/%m/%Y %H:%M:%S")
            echo -e "${YELLOW}[$COUNT]${NC} $(basename "$file") - $FILEDATE"
            FILES[$COUNT]=$file
        fi
    done
    
    echo ""
    echo -e "${YELLOW}[0]${NC} Cancelar y volver al menú"
    echo ""
    echo -n "Seleccione un respaldo para restaurar: "
    read RESTORE_OPTION
    
    if [ "$RESTORE_OPTION" == "0" ]; then
        return
    fi
    
    if [ "$RESTORE_OPTION" -le "$COUNT" ] 2>/dev/null; then
        SELECTED_FILE=${FILES[$RESTORE_OPTION]}
        
        echo ""
        echo -e "${YELLOW}Está a punto de restaurar la base de datos desde:${NC}"
        echo "$SELECTED_FILE"
        echo ""
        echo -e "${RED}ADVERTENCIA: Esto reemplazará la base de datos actual.${NC}"
        echo -e "${RED}Todos los cambios realizados desde este respaldo se perderán.${NC}"
        echo ""
        echo -e "${YELLOW}[1]${NC} Continuar con la restauración"
        echo -e "${YELLOW}[0]${NC} Cancelar"
        echo ""
        echo -n "Confirme la restauración: "
        read CONFIRM
        
        if [ "$CONFIRM" == "1" ]; then
            echo ""
            echo -e "${YELLOW}Restaurando base de datos...${NC}"
            
            # Matar la aplicación si está en ejecución
            pkill -f "desktop_app.py" > /dev/null 2>&1
            
            # Hacer un respaldo adicional por seguridad
            if [ -f "gimnasio.db" ]; then
                TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
                cp gimnasio.db "backups/gimnasio_pre_restauracion_$TIMESTAMP.db"
            fi
            
            # Restaurar desde el respaldo seleccionado
            cp "$SELECTED_FILE" gimnasio.db
            
            echo -e "${GREEN}[OK] Base de datos restaurada exitosamente.${NC}"
            echo ""
            read -p "Presione ENTER para continuar..."
        fi
    else
        echo -e "${RED}Opción inválida. Intente nuevamente.${NC}"
        sleep 2
    fi
}

# Bucle principal
while true; do
    show_menu
    read OPTION
    
    case $OPTION in
        1) start_app ;;
        2) check_network ;;
        3) config_sync ;;
        4) view_logs ;;
        5) force_sync ;;
        6) backup_db ;;
        7) restore_db ;;
        0) 
            echo ""
            echo -e "${GREEN}¡Hasta pronto!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opción inválida. Intente nuevamente.${NC}"
            sleep 2
            ;;
    esac
done 