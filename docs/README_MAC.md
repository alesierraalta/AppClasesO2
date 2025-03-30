# Guía de Instalación y Desarrollo de GymManager en Mac

Esta guía explica cómo instalar, configurar y utilizar GymManager en macOS para desarrollo y pruebas.

## Requisitos Previos

1. **Python 3.8 o superior** instalado en su Mac
   - Recomendado instalar con Homebrew: `brew install python`
   
2. **Herramientas adicionales**:
   - **jq** para procesar JSON: `brew install jq`
   - **curl** para las pruebas de red (generalmente ya está instalado en macOS)

3. **Conexión a la misma red local** que las otras computadoras del gimnasio

## Scripts Disponibles para macOS

Este paquete incluye los siguientes scripts optimizados para macOS:

- **setup_mac.sh**: Configura el entorno y sincronización para Mac
- **verificar_red_mac.sh**: Verifica la conectividad con las otras computadoras
- **administrar_mac.sh**: Panel de control para administrar GymManager en Mac
- **run_gymmanager.sh**: Script para iniciar la aplicación (generado automáticamente por setup_mac.sh)

## Instalación y Configuración (Paso a Paso)

### 1. Preparación Inicial

1. Clona el repositorio de GymManager en tu Mac:
   ```bash
   git clone [URL_DEL_REPOSITORIO] gymmanager
   cd gymmanager
   ```

2. Asegúrate de que los scripts tengan permisos de ejecución:
   ```bash
   chmod +x *.sh
   ```

### 2. Instalación y Configuración

1. Ejecuta el script de configuración para Mac:
   ```bash
   ./setup_mac.sh
   ```

2. Sigue las instrucciones en pantalla para:
   - Seleccionar el tipo de computadora (generalmente "Desarrollo (Mac)")
   - Configurar las IPs de las computadoras del gimnasio
   - Instalar todas las dependencias necesarias

### 3. Verificación de Conectividad

Después de configurar la aplicación, verifica la conectividad con las otras computadoras:

```bash
./verificar_red_mac.sh
```

Este script comprobará si tu Mac puede comunicarse con las computadoras del gimnasio.

### 4. Uso del Panel de Administración

El script `administrar_mac.sh` proporciona un panel de control completo:

```bash
./administrar_mac.sh
```

Este panel te permite:
- Iniciar GymManager
- Verificar estado de la red
- Configurar sincronización
- Ver logs y diagnósticos
- Forzar sincronización manual
- Realizar respaldos de la base de datos
- Restaurar la base de datos desde respaldos

## Desarrollo en Mac

### Flujo de Trabajo entre Windows y Mac

Para mantener un flujo de trabajo eficiente entre tu PC Windows y tu Mac:

1. **Control de versiones**: Utiliza Git para sincronizar tu código entre ambas plataformas:
   - En Windows: `git push` para subir cambios
   - En Mac: `git pull` para obtener los últimos cambios

2. **Sincronización de base de datos**: Utiliza la opción "Forzar sincronización manual" del panel de administración para mantener la base de datos actualizada entre todas las computadoras.

3. **Compilación**: No es necesario compilar la aplicación en Mac para desarrollo. Para producción, la compilación debe realizarse en Windows con PyInstaller.

## Resolución de Problemas

### Problemas de Red

Si hay problemas de conectividad:

1. Verifica que todas las computadoras estén conectadas a la misma red Wi-Fi o LAN
2. Asegúrate de que las IPs en `sync_config.json` sean correctas
3. Comprueba que el firewall de macOS permita conexiones entrantes en el puerto 5000:
   - Abre "Preferencias del Sistema" > "Seguridad y Privacidad" > "Firewall"
   - Haz clic en "Opciones del Firewall" y asegúrate de que Python/Flask pueda recibir conexiones

### Errores de Dependencias

Si encuentras errores relacionados con dependencias de Python:

```bash
# Actualiza pip
pip install --upgrade pip

# Reinstala las dependencias
pip install -r requirements.txt
```

Para problemas específicos con librerías nativas en macOS, puede ser necesario instalar Xcode Command Line Tools:

```bash
xcode-select --install
```

## Notas Importantes

- La sincronización funciona mejor cuando la computadora principal (Gerencia) está encendida
- Realiza respaldos regulares de la base de datos usando la opción en el panel de administración
- Si cambias de red o las IPs cambian, ejecuta nuevamente `setup_mac.sh` para actualizar la configuración

Para más información sobre la aplicación, consulta el archivo `README_SYNC.md` 