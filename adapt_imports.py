#!/usr/bin/env python
"""
Script para adaptar las importaciones después de la reorganización del proyecto.
Este script actualizará las referencias de importación en los archivos Python.
"""

import os
import re
import glob
import fileinput
import sys

# Mapeo de importaciones antiguas a nuevas
IMPORT_MAPPING = {
    'from app import': 'from app.core.app import',
    'import app': 'import app.core.app as app',
    'from models import': 'from app.models.models import',
    'import models': 'import app.models.models as models',
    'from api_routes import': 'from app.routes.api_routes import',
    'import api_routes': 'import app.routes.api_routes as api_routes',
    'from app_routes import': 'from app.routes.app_routes import',
    'import app_routes': 'import app.routes.app_routes as app_routes',
    'from audio_routes import': 'from app.routes.audio_routes import',
    'import audio_routes': 'import app.routes.audio_routes as audio_routes',
    'from espectrograma_routes import': 'from app.routes.espectrograma_routes import',
    'import espectrograma_routes': 'import app.routes.espectrograma_routes as espectrograma_routes',
    'from audio_functions import': 'from app.utils.audio_functions import',
    'import audio_functions': 'import app.utils.audio_functions as audio_functions',
    'from audio_utils import': 'from app.utils.audio_utils import',
    'import audio_utils': 'import app.utils.audio_utils as audio_utils',
    'from add_waveform_route import': 'from app.utils.add_waveform_route import',
    'import add_waveform_route': 'import app.utils.add_waveform_route as add_waveform_route',
    'from notifications import': 'from app.utils.notifications import',
    'import notifications': 'import app.utils.notifications as notifications',
    'from register_audio import': 'from app.utils.register_audio import',
    'import register_audio': 'import app.utils.register_audio as register_audio',
    'from verify_notifications import': 'from app.utils.verify_notifications import',
    'import verify_notifications': 'import app.utils.verify_notifications as verify_notifications',
}

# Directorio base para buscar archivos Python
BASE_DIRS = ['app', 'scripts', 'database', 'tests']

def update_imports_in_file(file_path):
    """Actualiza las importaciones en un archivo específico."""
    print(f"Procesando: {file_path}")
    file_updated = False
    
    with fileinput.FileInput(file_path, inplace=True, backup='.bak') as file:
        for line in file:
            original_line = line
            
            # Revisar si alguna importación necesita ser actualizada
            for old_import, new_import in IMPORT_MAPPING.items():
                if line.strip().startswith(old_import):
                    line = line.replace(old_import, new_import)
                    if original_line != line:
                        file_updated = True
                        break
            
            # Imprimir la línea (potencialmente modificada) al archivo
            print(line, end='')
    
    if file_updated:
        print(f"  > Importaciones actualizadas")
    else:
        # Eliminar el archivo de backup si no hubo cambios
        backup_file = f"{file_path}.bak"
        if os.path.exists(backup_file):
            os.remove(backup_file)

def find_python_files():
    """Encuentra todos los archivos Python en los directorios especificados."""
    python_files = []
    
    for base_dir in BASE_DIRS:
        if os.path.exists(base_dir):
            # Buscar archivos Python en el directorio y subdirectorios
            for root, _, files in os.walk(base_dir):
                for file in files:
                    if file.endswith('.py'):
                        python_files.append(os.path.join(root, file))
    
    return python_files

def main():
    """Función principal."""
    print("Adaptando importaciones a la nueva estructura del proyecto...")
    
    # Encontrar archivos Python
    python_files = find_python_files()
    print(f"Encontrados {len(python_files)} archivos Python para procesar")
    
    # Actualizar importaciones en cada archivo
    for file_path in python_files:
        update_imports_in_file(file_path)
    
    print("\nProceso completado.\n")
    print("NOTA: Es posible que necesites ajustar manualmente algunas importaciones.")
    print("      Revisa los archivos principales para asegurarte de que todo funciona correctamente.")

if __name__ == "__main__":
    main() 