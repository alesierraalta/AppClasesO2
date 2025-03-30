import os
import sys
import logging
from desktop_app import run_app

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("gymmanager.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("GymManager")

if __name__ == '__main__':
    try:
        logger.info("Iniciando GymManager...")
        run_app()
    except Exception as e:
        logger.error(f"Error al iniciar la aplicación: {str(e)}")
        input("Presiona Enter para salir...")
        sys.exit(1) 