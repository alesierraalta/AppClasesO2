#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Punto de entrada principal para la aplicación GymManager.
Este archivo permite iniciar la aplicación desde la raíz del proyecto.
"""

import os
import sys
import json
import argparse
import logging
import shutil
from pathlib import Path
from datetime import datetime

# Configurar logging
def setup_logging(debug_mode=False):
    """Configura el sistema de logging de la aplicación"""
    log_level = logging.DEBUG if debug_mode else logging.INFO
    
    # Crear directorio de logs si no existe
    log_dir = get_data_dir() / 'logs'
    log_dir.mkdir(parents=True, exist_ok=True)
    
    # Configurar formato de logs
    log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    
    # Configurar manejadores de logs
    handlers = [
        # Handler para archivo
        logging.FileHandler(
            log_dir / f'gymmanager_{datetime.now().strftime("%Y%m%d")}.log',
            encoding='utf-8'
        ),
        # Handler para consola
        logging.StreamHandler()
    ]
    
    # Configuración básica
    logging.basicConfig(
        level=log_level,
        format=log_format,
        handlers=handlers
    )
    
    # Obtener logger para la aplicación
    logger = logging.getLogger('GymManager')
    
    # Configurar nivel de logging para bibliotecas externas
    logging.getLogger('werkzeug').setLevel(logging.WARNING)
    logging.getLogger('flask').setLevel(logging.WARNING)
    
    return logger

# Determinar si estamos en modo frozen (ejecutable) o script
def is_frozen():
    """Determina si la aplicación se está ejecutando desde un ejecutable"""
    return getattr(sys, 'frozen', False) or os.environ.get('GYMMANAGER_EXEC_MODE') == 'True'

# Obtener el directorio base para la aplicación
def get_base_dir():
    """Obtiene el directorio base de la aplicación"""
    if is_frozen():
        # Si es ejecutable compilado, el directorio base es donde está el ejecutable
        return Path(os.path.dirname(sys.executable))
    else:
        # Si es script, el directorio base es donde está este archivo
        return Path(os.path.dirname(os.path.abspath(__file__)))

# Obtener el directorio de datos
def get_data_dir():
    """Obtiene el directorio de datos de la aplicación"""
    base_dir = get_base_dir()
    
    if is_frozen():
        # En modo ejecutable, los datos están en un subdirectorio 'data'
        data_dir = base_dir / 'data'
    else:
        # En modo script, los datos están en el directorio base
        data_dir = base_dir
    
    # Asegurar que el directorio existe
    data_dir.mkdir(parents=True, exist_ok=True)
    
    return data_dir

# Crear y verificar los directorios necesarios
def setup_directories():
    """Crea los directorios necesarios para la aplicación"""
    data_dir = get_data_dir()
    
    # Crear directorios base
    dirs = [
        data_dir / 'database',
        data_dir / 'logs',
        data_dir / 'backups',
        data_dir / 'config',
        data_dir / 'temp'
    ]
    
    for directory in dirs:
        directory.mkdir(parents=True, exist_ok=True)
    
    # Verificar permisos de escritura
    test_file = data_dir / 'write_test.tmp'
    try:
        with open(test_file, 'w') as f:
            f.write('test')
        test_file.unlink()  # Eliminar archivo de prueba
    except Exception as e:
        logger.error(f"No se puede escribir en el directorio de datos: {e}")
        return False
    
    return True

# Verificar y crear configuración
def setup_configuration():
    """Verifica y crea la configuración inicial si es necesario"""
    config_dir = get_data_dir() / 'config'
    config_path = config_dir / 'app_config.json'
    
    # Configuración por defecto
    default_config = {
        'database': {
            'type': 'sqlite',
            'path': str(get_data_dir() / 'database' / 'gymmanager.db')
        },
        'server': {
            'host': '0.0.0.0',
            'port': 5000,
            'debug': False
        },
        'app': {
            'secret_key': os.urandom(24).hex(),
            'max_upload_size': 16 * 1024 * 1024,  # 16MB
            'timezone': 'America/Caracas'
        }
    }
    
    # Crear archivo de configuración si no existe
    if not config_path.exists():
        with open(config_path, 'w', encoding='utf-8') as f:
            json.dump(default_config, f, indent=4)
        logger.info(f"Archivo de configuración creado: {config_path}")
    
    # Cargar configuración
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        logger.info("Configuración cargada correctamente")
        return config
    except Exception as e:
        logger.error(f"Error al cargar configuración: {e}")
        return default_config

# Crear base de datos inicial
def create_initial_database():
    """Crea la base de datos inicial y tablas necesarias"""
    from app.models.database import init_database
    
    try:
        db_path = get_data_dir() / 'database' / 'gymmanager.db'
        init_database(str(db_path))
        logger.info(f"Base de datos inicializada en: {db_path}")
        return True
    except Exception as e:
        logger.error(f"Error al inicializar base de datos: {e}")
        return False

# Iniciar la aplicación Flask
def start_app(debug=False):
    """Inicia la aplicación Flask"""
    from app.core.app import start_app as start_flask_app
    
    try:
        # Iniciar aplicación Flask
        logger.info(f"Iniciando aplicación GymManager (Debug: {debug})")
        start_flask_app(debug=debug)
        return True
    except Exception as e:
        logger.error(f"Error al iniciar aplicación: {e}")
        return False

# Función principal
def main():
    """Función principal que inicia la aplicación"""
    parser = argparse.ArgumentParser(description='GymManager - Aplicación para gestión de gimnasios')
    parser.add_argument('--setup-db', action='store_true', help='Configura la base de datos inicial')
    parser.add_argument('--debug', action='store_true', help='Ejecuta en modo debug')
    args = parser.parse_args()
    
    # Configurar logging
    global logger
    logger = setup_logging(debug_mode=args.debug)
    
    # Mostrar información básica
    logger.info(f"GymManager iniciando...")
    logger.info(f"Modo: {'Ejecutable' if is_frozen() else 'Script'}")
    logger.info(f"Directorio base: {get_base_dir()}")
    logger.info(f"Directorio de datos: {get_data_dir()}")
    
    # Configurar directorios
    if not setup_directories():
        logger.error("Error al configurar directorios. Verifique permisos de escritura.")
        sys.exit(1)
    
    # Cargar configuración
    config = setup_configuration()
    
    # Configurar base de datos si se especificó
    if args.setup_db:
        logger.info("Configurando base de datos inicial...")
        if create_initial_database():
            logger.info("Base de datos configurada correctamente")
        else:
            logger.error("Error al configurar base de datos")
            sys.exit(1)
    
    # Iniciar la aplicación
    try:
        start_app(debug=args.debug)
    except KeyboardInterrupt:
        logger.info("Aplicación detenida por el usuario")
    except Exception as e:
        logger.error(f"Error al ejecutar la aplicación: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
