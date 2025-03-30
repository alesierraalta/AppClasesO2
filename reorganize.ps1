# Script para reorganizar la estructura de archivos del proyecto GymManager

# Función para mover archivos asegurándose de que el directorio destino existe
function MoveSafely {
    param (
        [string]$source,
        [string]$destination
    )
    
    $destDir = Split-Path -Path $destination -Parent
    
    # Verificar si el directorio destino existe, si no, crearlo
    if (!(Test-Path -Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force
    }
    
    # Verificar si el archivo fuente existe
    if (Test-Path -Path $source) {
        # Verificar si el archivo destino ya existe
        if (Test-Path -Path $destination) {
            Write-Host "El archivo $destination ya existe. Sobrescribiendo..." -ForegroundColor Yellow
            Remove-Item -Path $destination -Force
        }
        
        # Copiar el archivo
        Copy-Item -Path $source -Destination $destination -Force
        Write-Host "Copiado: $source -> $destination" -ForegroundColor Green
    } else {
        Write-Host "Archivo no encontrado: $source" -ForegroundColor Red
    }
}

# Crear directorios base
$directories = @(
    "app\core",
    "app\routes",
    "app\models",
    "app\utils",
    "scripts\windows",
    "scripts\mac",
    "scripts\common",
    "docs",
    "database",
    "logs",
    "tests\unit",
    "tests\integration"
)

foreach ($dir in $directories) {
    if (!(Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force
        Write-Host "Directorio creado: $dir" -ForegroundColor Cyan
    }
}

# Mover archivos del núcleo de la aplicación
MoveSafely "app.py" "app\core\app.py"
MoveSafely "models.py" "app\models\models.py"

# Mover rutas
MoveSafely "api_routes.py" "app\routes\api_routes.py"
MoveSafely "app_routes.py" "app\routes\app_routes.py"
MoveSafely "audio_routes.py" "app\routes\audio_routes.py"
MoveSafely "espectrograma_routes.py" "app\routes\espectrograma_routes.py"

# Mover utilidades
MoveSafely "audio_functions.py" "app\utils\audio_functions.py"
MoveSafely "audio_utils.py" "app\utils\audio_utils.py"
MoveSafely "add_waveform_route.py" "app\utils\add_waveform_route.py"
MoveSafely "notifications.py" "app\utils\notifications.py"
MoveSafely "register_audio.py" "app\utils\register_audio.py"
MoveSafely "verify_notifications.py" "app\utils\verify_notifications.py"

# Mover scripts para Windows que ya están en el directorio correcto
MoveSafely "scripts\windows\setup_network.bat" "scripts\windows\setup_network.bat"
MoveSafely "scripts\windows\instalar_gymmanager.bat" "scripts\windows\instalar_gymmanager.bat"
MoveSafely "scripts\windows\verificar_red.bat" "scripts\windows\verificar_red.bat"
MoveSafely "scripts\windows\administrar.bat" "scripts\windows\administrar.bat"
MoveSafely "scripts\windows\build_app.bat" "scripts\windows\build_app.bat"
MoveSafely "scripts\windows\run.bat" "scripts\windows\run.bat"

# Mover scripts para Windows que aún están en el directorio raíz
MoveSafely "run_tests.bat" "scripts\windows\run_tests.bat"
MoveSafely "ejecutar_tests.bat" "scripts\windows\ejecutar_tests.bat"
MoveSafely "test_simple.bat" "scripts\windows\test_simple.bat"
MoveSafely "run_notification_tests.bat" "scripts\windows\run_notification_tests.bat"
MoveSafely "run_specific_tests.bat" "scripts\windows\run_specific_tests.bat"

# Mover scripts para Mac que ya están en el directorio correcto
MoveSafely "scripts\mac\setup_mac.sh" "scripts\mac\setup_mac.sh"
MoveSafely "scripts\mac\verificar_red_mac.sh" "scripts\mac\verificar_red_mac.sh"
MoveSafely "scripts\mac\administrar_mac.sh" "scripts\mac\administrar_mac.sh"

# Mover scripts comunes
MoveSafely "app_launcher.py" "scripts\common\app_launcher.py"
MoveSafely "gym_app.spec" "scripts\common\gym_app.spec"

# Mover herramientas de base de datos
MoveSafely "create_tables.py" "database\create_tables.py"
MoveSafely "view_tables.py" "database\view_tables.py"
MoveSafely "update_db.py" "database\update_db.py"
MoveSafely "reset_db.py" "database\reset_db.py"
MoveSafely "gimnasio.db" "database\gimnasio.db"

# Mover documentación
MoveSafely "README.md" "docs\README.md"
MoveSafely "README_SYNC.md" "docs\README_SYNC.md"
MoveSafely "README_MAC.md" "docs\README_MAC.md"
MoveSafely "README_INSTALACION.md" "docs\README_INSTALACION.md"

# Mover logs
MoveSafely "notifications.log" "logs\notifications.log"
MoveSafely "crash_log.txt" "logs\crash_log.txt"
MoveSafely "import_debug.log" "logs\import_debug.log"
MoveSafely "import_errors.log" "logs\import_errors.log"
MoveSafely "PyWhatKit_DB.txt" "logs\PyWhatKit_DB.txt"
MoveSafely ".coverage" "logs\.coverage"

# Mover archivos de configuración
MoveSafely "sync_config.json" "app\core\sync_config.json"
MoveSafely ".env" "app\core\.env"
MoveSafely "pytest.ini" "tests\pytest.ini"

# Mover directorios existentes
if (Test-Path -Path "static" -PathType Container) {
    # Crear directorio de destino si no existe
    if (!(Test-Path -Path "app\static")) {
        New-Item -ItemType Directory -Path "app\static" -Force
    }
    
    # Copiar los archivos (sin usar comodines que pueden ser problemáticos)
    Get-ChildItem -Path "static" -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring((Get-Item "static").FullName.Length)
        $destination = Join-Path "app\static" $relativePath
        
        if ($_.PSIsContainer) {
            # Si es directorio, crearlo en el destino
            if (!(Test-Path -Path $destination)) {
                New-Item -ItemType Directory -Path $destination -Force | Out-Null
            }
        } else {
            # Si es archivo, copiarlo
            Copy-Item -Path $_.FullName -Destination $destination -Force
        }
    }
    Write-Host "Contenido de 'static' movido a 'app\static'" -ForegroundColor Green
}

if (Test-Path -Path "templates" -PathType Container) {
    # Crear directorio de destino si no existe
    if (!(Test-Path -Path "app\templates")) {
        New-Item -ItemType Directory -Path "app\templates" -Force
    }
    
    # Copiar los archivos (sin usar comodines que pueden ser problemáticos)
    Get-ChildItem -Path "templates" -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring((Get-Item "templates").FullName.Length)
        $destination = Join-Path "app\templates" $relativePath
        
        if ($_.PSIsContainer) {
            # Si es directorio, crearlo en el destino
            if (!(Test-Path -Path $destination)) {
                New-Item -ItemType Directory -Path $destination -Force | Out-Null
            }
        } else {
            # Si es archivo, copiarlo
            Copy-Item -Path $_.FullName -Destination $destination -Force
        }
    }
    Write-Host "Contenido de 'templates' movido a 'app\templates'" -ForegroundColor Green
}

if (Test-Path -Path "uploads" -PathType Container) {
    # Crear directorio de destino si no existe
    if (!(Test-Path -Path "app\uploads")) {
        New-Item -ItemType Directory -Path "app\uploads" -Force
    }
    
    # Copiar los archivos (sin usar comodines que pueden ser problemáticos)
    Get-ChildItem -Path "uploads" -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring((Get-Item "uploads").FullName.Length)
        $destination = Join-Path "app\uploads" $relativePath
        
        if ($_.PSIsContainer) {
            # Si es directorio, crearlo en el destino
            if (!(Test-Path -Path $destination)) {
                New-Item -ItemType Directory -Path $destination -Force | Out-Null
            }
        } else {
            # Si es archivo, copiarlo
            Copy-Item -Path $_.FullName -Destination $destination -Force
        }
    }
    Write-Host "Contenido de 'uploads' movido a 'app\uploads'" -ForegroundColor Green
}

# Manejar pruebas
if (Test-Path -Path "tests" -PathType Container) {
    # Crear directorios de destino
    if (!(Test-Path -Path "tests\unit")) {
        New-Item -ItemType Directory -Path "tests\unit" -Force
    }
    if (!(Test-Path -Path "tests\integration")) {
        New-Item -ItemType Directory -Path "tests\integration" -Force
    }
    
    # Mover archivos de prueba según patrón
    Get-ChildItem -Path "tests" -File | ForEach-Object {
        if ($_.Name -like "test_*.py") {
            MoveSafely $_.FullName "tests\unit\$($_.Name)"
        } else {
            MoveSafely $_.FullName "tests\integration\$($_.Name)"
        }
    }
    
    Write-Host "Pruebas reorganizadas en 'tests\unit' y 'tests\integration'" -ForegroundColor Green
}

# Crear un archivo main.py en la raíz para facilitar la ejecución
@"
# Punto de entrada principal para GymManager
# Este archivo sirve como enlace a la aplicación reorganizada

import sys
import os

# Agregar el directorio actual al path para importaciones relativas
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Importar desde la nueva estructura
from app.core.app import app

if __name__ == "__main__":
    app.run(debug=True)
"@ | Out-File -FilePath "main.py" -Encoding utf8

Write-Host "Creado archivo 'main.py' como punto de entrada principal" -ForegroundColor Green

# Verificar la nueva estructura
Write-Host "`nReorganización completada con éxito!" -ForegroundColor Cyan
Write-Host "La nueva estructura de directorios es:" -ForegroundColor Cyan

# Mostrar estructura de directorios principal
Get-ChildItem -Directory | ForEach-Object {
    Write-Host "- $_" -ForegroundColor White
    
    # Mostrar subdirectorios de primer nivel
    Get-ChildItem -Path $_.FullName -Directory | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
        
        # Mostrar subdirectorios de segundo nivel (solo para algunos directorios clave)
        if ($_.Name -in @("app", "scripts", "tests")) {
            Get-ChildItem -Path $_.FullName -Directory | ForEach-Object {
                Write-Host "    - $_" -ForegroundColor DarkGray
            }
        }
    }
} 