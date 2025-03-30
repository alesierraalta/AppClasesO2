#!/bin/bash

# Colores para formatear salida
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}     VERIFICADOR DE RED PARA GYMMANAGER (MAC)    ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${YELLOW}Este script verificará la conectividad con las${NC}"
echo -e "${YELLOW}otras computadoras definidas en sync_config.json${NC}"
echo ""

# Verificar que curl esté disponible
if ! command -v curl &> /dev/null; then
    echo -e "${RED}ERROR: El comando 'curl' no está disponible.${NC}"
    echo "Este script requiere curl para funcionar correctamente."
    echo "Instálalo con: brew install curl"
    echo ""
    exit 1
fi

# Verificar que jq esté disponible (para parsear JSON)
if ! command -v jq &> /dev/null; then
    echo -e "${RED}ERROR: El comando 'jq' no está disponible.${NC}"
    echo "Este script requiere jq para parsear JSON."
    echo "Instálalo con: brew install jq"
    echo ""
    exit 1
fi

# Verificar que sync_config.json existe
if [ ! -f "sync_config.json" ]; then
    echo -e "${RED}ERROR: No se encontró el archivo sync_config.json${NC}"
    echo "Ejecute primero setup_mac.sh para configurar la red."
    echo ""
    exit 1
fi

# Extraer IPs de las computadoras de sync_config.json
echo -e "${BLUE}Leyendo configuración de red...${NC}"
IPS=($(cat sync_config.json | jq -r '.sync_servers[]' | sed 's|http://||' | sed 's|:5000/sync||'))
COUNT=${#IPS[@]}

echo -e "${GREEN}Encontradas $COUNT direcciones IP para verificar.${NC}"
echo ""

# Obtener la IP local
IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -n 1 | awk '{print $2}')
echo -e "${YELLOW}Esta computadora:${NC}"
echo -e "${GREEN}$IP${NC}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}          VERIFICANDO CONECTIVIDAD              ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Verificar conectividad con cada IP
SUCCESS=0

for current_ip in "${IPS[@]}"; do
    # Evitar comprobar la propia IP
    if [ "$current_ip" != "$IP" ]; then
        echo -e "${YELLOW}Verificando $current_ip...${NC}"
        
        # Intentar ping
        ping -c 1 $current_ip > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[OK] Ping exitoso a $current_ip${NC}"
            
            # Intentar conexión al servicio
            curl -s -m 5 http://$current_ip:5000/config > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}[OK] Servicio GymManager accesible en $current_ip:5000${NC}"
                ((SUCCESS++))
            else
                echo -e "${RED}[ERROR] No se puede conectar al servicio GymManager en $current_ip:5000${NC}"
                echo "         Posibles causas:"
                echo "         - La aplicación no está en ejecución"
                echo "         - El firewall está bloqueando la conexión"
                echo "         - El puerto 5000 no está abierto"
            fi
        else
            echo -e "${RED}[ERROR] No se pudo hacer ping a $current_ip${NC}"
            echo "         Posibles causas:"
            echo "         - La computadora está apagada"
            echo "         - La IP es incorrecta"
            echo "         - Hay un problema de red"
        fi
        echo ""
    fi
done

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}             RESUMEN DE VERIFICACIÓN            ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

if [ $SUCCESS -gt 0 ]; then
    echo -e "${GREEN}Conectividad verificada con $SUCCESS de $((COUNT-1)) computadoras.${NC}"
    
    if [ $SUCCESS -eq $((COUNT-1)) ]; then
        echo -e "${GREEN}[EXCELENTE] La red está correctamente configurada.${NC}"
    else
        echo -e "${YELLOW}[ADVERTENCIA] No todas las computadoras están accesibles.${NC}"
        echo -e "${YELLOW}               Revise la configuración de red.${NC}"
    fi
else
    echo -e "${RED}[ERROR] No se pudo conectar con ninguna computadora.${NC}"
    echo "         Posibles soluciones:"
    echo "         - Verifique que las computadoras estén encendidas"
    echo "         - Revise las direcciones IP en sync_config.json"
    echo "         - Asegúrese de que todas las computadoras estén"
    echo "           conectadas a la misma red"
    echo "         - Desactive temporalmente el firewall para pruebas"
fi

echo ""
echo -e "${YELLOW}Para corregir problemas de conectividad:${NC}"
echo "1. Ejecute setup_mac.sh para actualizar IPs"
echo "2. Asegúrese de que GymManager esté en ejecución"
echo "3. Verifique la configuración de red del sistema"
echo "" 