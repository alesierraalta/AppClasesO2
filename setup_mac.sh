#!/bin/bash

# Colores para formatear salida
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}      CONFIGURACIÓN DE GYMMANAGER PARA MAC      ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Verificar que Python esté instalado
echo -e "${BLUE}Verificando instalación de Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}ERROR: Python 3 no está instalado en este sistema.${NC}"
    echo "Por favor, instala Python 3 usando Homebrew:"
    echo "  brew install python"
    echo ""
    echo "Si no tienes Homebrew, instálalo con:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}$PYTHON_VERSION encontrado correctamente.${NC}"

# Crear entorno virtual
echo ""
echo -e "${BLUE}Configurando entorno de desarrollo...${NC}"
if [ ! -d "venv" ]; then
    echo "Creando entorno virtual..."
    python3 -m venv venv
else
    echo "Entorno virtual ya existe, usando el existente."
fi

# Activar entorno virtual
source venv/bin/activate

# Instalar dependencias
echo ""
echo -e "${BLUE}Instalando dependencias...${NC}"
pip install -r requirements.txt

# Crear directorios necesarios
echo ""
echo -e "${BLUE}Creando directorios de la aplicación...${NC}"
mkdir -p static templates uploads backups

# Configuración para Mac
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}          CONFIGURACIÓN DE RED PARA MAC         ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Obtener dirección IP
IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -n 1 | awk '{print $2}')
echo -e "${GREEN}IP local detectada: $IP${NC}"
echo ""

# Preguntar por el tipo de computadora
echo -e "${YELLOW}Seleccione el tipo de computadora:${NC}"
echo "1 - Principal (Gerente - solo una computadora debe ser principal)"
echo "2 - Recepción 1"
echo "3 - Recepción 2"
echo "4 - Desarrollo (Mac)"
echo ""
read -p "Ingrese el número (1, 2, 3 o 4): " COMPUTER_TYPE

if [ "$COMPUTER_TYPE" == "1" ]; then
    IS_PRIMARY=true
    COMPUTER_NAME="Gerencia"
elif [ "$COMPUTER_TYPE" == "2" ]; then
    IS_PRIMARY=false
    COMPUTER_NAME="Recepcion 1"
elif [ "$COMPUTER_TYPE" == "3" ]; then
    IS_PRIMARY=false
    COMPUTER_NAME="Recepcion 2"
elif [ "$COMPUTER_TYPE" == "4" ]; then
    IS_PRIMARY=false
    COMPUTER_NAME="Desarrollo (Mac)"
else
    echo -e "${YELLOW}Opción inválida. Seleccionando 'Desarrollo (Mac)' por defecto.${NC}"
    IS_PRIMARY=false
    COMPUTER_NAME="Desarrollo (Mac)"
fi

echo ""
echo -e "${GREEN}Configurando como: $COMPUTER_NAME (Principal: $IS_PRIMARY)${NC}"

# Configurar IPs
echo ""
echo -e "${YELLOW}Por favor ingrese las IPs de las computadoras en la red:${NC}"
echo "Deje en blanco para usar la configuración predeterminada:"
echo "- 192.168.1.100 (Gerencia)"
echo "- 192.168.1.101 (Recepción 1)"
echo "- 192.168.1.102 (Recepción 2)"
echo ""

# Establecer valores predeterminados
IP_MAIN="192.168.1.100"
IP_REC1="192.168.1.101"
IP_REC2="192.168.1.102"

echo -e "${YELLOW}IMPORTANTE: Si no conoce las IPs exactas, deje en blanco los campos${NC}"
echo "para usar valores predeterminados y luego actualice manualmente."
echo ""

read -p "IP de Gerencia: " IP_MAIN_INPUT
read -p "IP de Recepción 1: " IP_REC1_INPUT
read -p "IP de Recepción 2: " IP_REC2_INPUT

if [ ! -z "$IP_MAIN_INPUT" ]; then IP_MAIN=$IP_MAIN_INPUT; fi
if [ ! -z "$IP_REC1_INPUT" ]; then IP_REC1=$IP_REC1_INPUT; fi
if [ ! -z "$IP_REC2_INPUT" ]; then IP_REC2=$IP_REC2_INPUT; fi

# Crear archivo de configuración
echo ""
echo -e "${BLUE}Creando archivo de configuración sync_config.json...${NC}"

cat > sync_config.json << EOL
{
    "sync_interval": 300,
    "is_primary_server": $IS_PRIMARY,
    "sync_servers": [
        "http://$IP_MAIN:5000/sync",
        "http://$IP_REC1:5000/sync",
        "http://$IP_REC2:5000/sync",
        "http://$IP:5000/sync"
    ],
    "server_name": "$COMPUTER_NAME",
    "backup_folder": "backups"
}
EOL

echo -e "${GREEN}¡Configuración guardada correctamente!${NC}"

# Crear script de inicio
echo ""
echo -e "${BLUE}Creando script de inicio...${NC}"

cat > run_gymmanager.sh << EOL
#!/bin/bash
source venv/bin/activate
python desktop_app.py
EOL

chmod +x run_gymmanager.sh

echo -e "${GREEN}Script de inicio creado.${NC}"

# Finalizar
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}          CONFIGURACIÓN COMPLETADA              ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}GymManager ha sido configurado correctamente para Mac.${NC}"
echo ""
echo -e "${YELLOW}Para iniciar la aplicación, ejecute:${NC}"
echo "./run_gymmanager.sh"
echo ""
echo -e "${YELLOW}NOTAS IMPORTANTES:${NC}"
echo "1. Asegúrese de que todas las computadoras estén en la misma red"
echo "2. Verifique que el puerto 5000 esté abierto en el firewall"
echo "3. Si cambia la configuración de red, ejecute este script nuevamente"
echo ""
echo -e "${GREEN}¡Listo para usar GymManager en su Mac!${NC}" 