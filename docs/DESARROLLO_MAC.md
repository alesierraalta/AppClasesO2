# Guía de Desarrollo para GymManager en Mac

Este documento describe el proceso para desarrollar GymManager en un entorno Mac y luego desplegar las actualizaciones en las computadoras Windows del gimnasio.

## Configuración del Entorno de Desarrollo en Mac

### 1. Requisitos Previos

- macOS 10.14 o superior
- Python 3.8 o superior
- Git
- Visual Studio Code (recomendado) o su editor preferido

### 2. Clonar el Repositorio

```bash
# Clonar el repositorio desde GitHub
git clone https://github.com/alesierraalta/AppClasesO2.git GymManager
cd GymManager
```

### 3. Configurar Entorno Virtual

```bash
# Crear y activar entorno virtual
python -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt
```

### 4. Configuración de Desarrollo

```bash
# Configurar variables de entorno para desarrollo
export FLASK_ENV=development
export FLASK_DEBUG=1
```

O cree un archivo `.env` en `app/core/` con este contenido:

```
FLASK_ENV=development
FLASK_DEBUG=1
```

## Flujo de Trabajo de Desarrollo

### 1. Iniciar la Aplicación en Modo Desarrollo

```bash
# Desde la raíz del proyecto
python main.py --debug
```

### 2. Ejecutar Pruebas

```bash
# Ejecutar todas las pruebas
python main.py --test

# Ejecutar pruebas específicas
cd tests
python -m unittest tests/unit/test_notifications.py
```

### 3. Flujo de Trabajo Git

```bash
# Ver cambios
git status

# Añadir cambios
git add .

# Confirmar cambios
git commit -m "Descripción de los cambios"

# Enviar cambios al repositorio
git push origin main
```

## Preparación para Despliegue en Windows

### 1. Generar Actualizaciones

Después de hacer cambios significativos y probarlos:

```bash
# Crear un archivo ZIP con los cambios
cd GymManager
zip -r GymManager_update.zip . -x "*.git*" -x "venv/*" -x "__pycache__/*" -x "*.pyc"
```

### 2. Preparar USB de Instalación/Actualización

```bash
# Ejecutar el script para preparar un USB
cd scripts/mac
./prepare_usb_installer.sh
```

O manualmente:

1. Copie `GymManager_update.zip` a un USB
2. Copie `scripts/windows/actualizar_gymmanager.bat` al USB
3. Ponga los archivos en una carpeta llamada `GymManager_Installer`

## Instalación y Actualización en Windows

### Primera Instalación

1. Inserte el USB en la computadora Windows
2. Ejecute `GymManager_Installer/instalar_GymManager.bat`
3. Siga las instrucciones en pantalla

### Actualización de Versión

1. Inserte el USB en la computadora Windows
2. Ejecute `actualizar_gymmanager.bat`
3. Siga las instrucciones en pantalla

## Compilación para Distribución (Opcional)

Si desea crear un ejecutable autónomo para Windows desde su Mac:

```bash
# Instalar herramientas de compilación cruzada
pip install pyinstaller

# Compilar para Windows (requiere Wine en Mac)
pyinstaller scripts/common/gym_app.spec
```

## Resolución de Problemas

### Incompatibilidades Mac/Windows

- Use rutas relativas con barras diagonales normales `/` en el código
- Pruebe los scripts de Windows en una máquina virtual si es posible
- Tenga cuidado con las dependencias específicas de la plataforma

### Problemas de Base de Datos

Si necesita modificar el esquema de la base de datos:

1. Actualice `database/create_tables.py` con los nuevos modelos
2. Cree un script de migración en `database/migrations/`
3. Actualice `database/update_db.py` para aplicar la migración
4. Pruebe la migración antes de implementarla

## Notas para Despliegue en el Gimnasio

1. **Computadora Principal (PC1):**
   - Siempre actualice esta computadora primero
   - Verifique que los datos maestros estén intactos después de la actualización

2. **Computadoras Secundarias (PC2 y PC3):**
   - Actualice estas computadoras solo después de verificar que PC1 funciona correctamente
   - Asegúrese de que la sincronización funcione después de la actualización

3. **Respaldos:**
   - Antes de cualquier actualización mayor, cree una copia completa de la carpeta de la base de datos
   - Mantenga los respaldos en un medio externo (no solo en las computadoras del gimnasio)

## Soporte y Mantenimiento

Para problemas técnicos o solicitudes de funciones:

1. Documente el problema o la solicitud
2. Reproduzca el problema en su entorno de desarrollo Mac
3. Implemente y pruebe la solución en Mac antes de implementarla en Windows 