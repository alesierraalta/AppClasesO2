#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Título
echo -e "${BLUE}===================================================================="
echo "         CREADOR DE USB DE INSTALACION PARA GYMMANAGER"
echo -e "====================================================================${NC}"
echo ""
echo "Este script preparará un USB para instalar GymManager en cualquier PC Windows."
echo ""

# Solicitar la ruta del USB
echo "Conecte un USB con al menos 500 MB de espacio libre y continúe."
echo ""
read -p "Ingrese la ruta de montaje del USB (ej. /Volumes/USBDRIVE): " USB_PATH

# Verificar que la ruta existe
if [ ! -d "$USB_PATH" ]; then
    echo -e "${RED}Error: La ruta $USB_PATH no existe.${NC}"
    echo "Por favor, inserte un USB y ejecute este script nuevamente."
    exit 1
fi

echo ""
echo -e "${GREEN}Preparando el USB en $USB_PATH...${NC}"
echo ""

# Crear estructura de directorios
echo "Creando directorios..."
mkdir -p "$USB_PATH/GymManager_Installer/Python"
mkdir -p "$USB_PATH/GymManager_Installer/AppFiles"
echo "Directorios creados."

# Descargar Python para Windows
echo ""
echo "Descargando Python para Windows (esto puede tardar unos minutos)..."
curl -L "https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe" -o "$USB_PATH/GymManager_Installer/Python/python-3.8.10-amd64.exe"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error al descargar Python. Compruebe su conexión a Internet.${NC}"
    exit 1
fi
echo "Python descargado correctamente."

# Copiar scripts de Windows
echo ""
echo "Copiando scripts de instalación y actualización..."
cp "../windows/instalacion_completa.bat" "$USB_PATH/GymManager_Installer/instalar_GymManager.bat"
cp "../windows/actualizar_gymmanager.bat" "$USB_PATH/GymManager_Installer/actualizar_GymManager.bat"
cp "../windows/exclude_list.txt" "$USB_PATH/GymManager_Installer/exclude_list.txt"

# Crear ZIP con el repositorio actual
echo ""
echo "Preparando copia local del repositorio..."
cd ../../../
zip -r "$USB_PATH/GymManager_Installer/AppFiles/GymManager.zip" . -x "*.git*" -x "venv/*" -x "__pycache__/*" -x "*.pyc" -x "*.DS_Store"

# Crear README.txt con instrucciones
echo ""
echo "Creando archivo de instrucciones..."

cat > "$USB_PATH/GymManager_Installer/LEEME.txt" << EOL
======================================================================
                 INSTALADOR DE GYMMANAGER
======================================================================

Instrucciones para instalar GymManager:

1. Haga doble clic en el archivo "instalar_GymManager.bat"
2. Siga las instrucciones en pantalla
3. Al finalizar, encontrará los accesos directos en el escritorio

Notas importantes:
- Se requieren permisos de administrador para la instalación
- La PC1 debe instalarse primero, luego las demás PCs
- Para las PC2 y PC3, necesitará conocer la IP de la PC1
- La instalación tardará aproximadamente 5-10 minutos

Para actualizar una instalación existente:
1. Ejecute "actualizar_GymManager.bat"
2. Este proceso preservará todos sus datos

Para soporte técnico, contacte al administrador del sistema.
EOL

# Modificar los scripts para usar archivos locales
echo ""
echo "Adaptando instalador para modo offline..."

# Ruta del Python
sed -i '' "s|powershell -Command \"& {Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe' -OutFile 'C:\\\\GymManager\\\\Temp\\\\python-installer.exe'}\"|copy \"%~dp0Python\\python-3.8.10-amd64.exe\" \"C:\\GymManager\\Temp\\python-installer.exe\"|g" "$USB_PATH/GymManager_Installer/instalar_GymManager.bat"

# Ruta del ZIP
sed -i '' "s|powershell -Command \"& {Invoke-WebRequest -Uri 'https://github.com/alesierraalta/AppClasesO2/archive/refs/heads/main.zip' -OutFile 'C:\\\\GymManager\\\\Temp\\\\GymManager.zip'}\"|copy \"%~dp0AppFiles\\GymManager.zip\" \"C:\\GymManager\\Temp\\GymManager.zip\"|g" "$USB_PATH/GymManager_Installer/instalar_GymManager.bat"

# Crear ícono para ReadMe
echo ""
echo "Creando archivo README en la raíz del USB..."
cat > "$USB_PATH/README.txt" << EOL
======================================================================
                 INSTALADOR DE GYMMANAGER
======================================================================

Para instalar GymManager en una computadora Windows:

1. Abra la carpeta "GymManager_Installer"
2. Ejecute "instalar_GymManager.bat" como administrador
3. Siga las instrucciones en pantalla

Para más información, consulte el archivo LEEME.txt dentro de la carpeta.
EOL

# Finalización
echo ""
echo -e "${GREEN}===================================================================="
echo "                 USB DE INSTALACION CREADO"
echo -e "====================================================================${NC}"
echo ""
echo "El USB de instalación ha sido creado exitosamente en $USB_PATH."
echo ""
echo "Para instalar GymManager en cualquier computadora Windows:"
echo "1. Inserte este USB"
echo "2. Abra la carpeta 'GymManager_Installer'"
echo "3. Ejecute 'instalar_GymManager.bat'"
echo "4. Siga las instrucciones en pantalla"
echo ""
echo "Proceso completado."
exit 0 