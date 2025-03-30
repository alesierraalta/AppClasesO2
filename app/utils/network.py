"""
Utilidades de red para la aplicación GymManager

Este módulo proporciona funciones para trabajar con la red:
- Obtener la dirección IP de la máquina local
- Verificar la conexión con el servidor principal
- Obtener la información de la máquina actual
"""

import os
import json
import socket
import platform
import logging
import requests
from pathlib import Path

# Obtener el logger configurado
logger = logging.getLogger('GymManager')

def get_machine_ip():
    """
    Obtiene la dirección IP de la máquina local en la red
    
    Returns:
        str: Dirección IP de la máquina local, o 127.0.0.1 si no se puede determinar
    """
    try:
        # Crear un socket para determinar la IP externa
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        # No es necesario que realmente se conecte
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception as e:
        logger.warning(f"No se pudo determinar la IP de la máquina: {e}")
        
        # Plan B: obtener el hostname
        try:
            hostname = socket.gethostname()
            ip = socket.gethostbyname(hostname)
            return ip
        except Exception as e2:
            logger.error(f"Error al obtener IP por hostname: {e2}")
            return '127.0.0.1'

def check_server_connection(server_ip, server_port):
    """
    Verifica si se puede conectar al servidor principal
    
    Args:
        server_ip (str): Dirección IP del servidor
        server_port (int): Puerto del servidor
        
    Returns:
        bool: True si la conexión es exitosa, False en caso contrario
    """
    try:
        # Intentar crear un socket y conectar al servidor
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(2)  # Timeout de 2 segundos
        s.connect((server_ip, server_port))
        s.close()
        logger.info(f"Conexión exitosa al servidor {server_ip}:{server_port}")
        return True
    except Exception as e:
        logger.warning(f"No se pudo conectar al servidor {server_ip}:{server_port}: {e}")
        return False

def check_server_api(server_ip, server_port):
    """
    Verifica si la API del servidor está respondiendo
    
    Args:
        server_ip (str): Dirección IP del servidor
        server_port (int): Puerto del servidor
        
    Returns:
        bool: True si la API responde correctamente, False en caso contrario
    """
    try:
        # Intentar hacer una petición a la API de estado
        url = f"http://{server_ip}:{server_port}/api/status"
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            logger.info(f"API del servidor respondiendo. Versión: {data.get('version', 'desconocida')}")
            return True
        else:
            logger.warning(f"API del servidor respondió con código {response.status_code}")
            return False
    except Exception as e:
        logger.warning(f"No se pudo conectar a la API del servidor: {e}")
        return False

def get_pc_info():
    """
    Obtiene información sobre la PC actual, incluyendo PC number, si es servidor, etc.
    
    Returns:
        dict: Información de la PC o valores por defecto si no se encuentra
    """
    # Valores por defecto
    default_info = {
        "pc_number": 1,
        "is_server": True,
        "sync_enabled": False,
        "description": "PC Principal (Servidor) - Configuración por defecto"
    }
    
    try:
        # Determinar si estamos en modo ejecutable o script
        is_frozen = getattr(os, "frozen", False)
        
        if is_frozen:
            # En modo ejecutable
            base_dir = Path(os.path.dirname(sys.executable))
            config_path = base_dir / 'data' / 'config' / 'pc_config.json'
        else:
            # En modo script
            base_dir = Path(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
            config_path = base_dir / 'app' / 'core' / 'pc_config.json'
        
        # Verificar si existe el archivo de configuración
        if config_path.exists():
            with open(config_path, 'r') as f:
                pc_info = json.load(f)
            return pc_info
        else:
            logger.warning(f"No se encontró archivo de configuración en {config_path}")
            return default_info
    except Exception as e:
        logger.error(f"Error al obtener información de la PC: {e}")
        return default_info

def get_network_config():
    """
    Obtiene la configuración de red para sincronización
    
    Returns:
        dict: Configuración de red o valores por defecto si no se encuentra
    """
    # Valores por defecto
    default_config = {
        "server_ip": "192.168.1.100",
        "server_port": 5000,
        "sync_port": 8000,
        "sync_interval": 300,
        "backup_before_sync": True
    }
    
    try:
        # Determinar si estamos en modo ejecutable o script
        is_frozen = getattr(os, "frozen", False)
        
        if is_frozen:
            # En modo ejecutable
            base_dir = Path(os.path.dirname(sys.executable))
            config_path = base_dir / 'data' / 'config' / 'network_config.json'
        else:
            # En modo script
            base_dir = Path(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
            config_path = base_dir / 'app' / 'core' / 'network_config.json'
        
        # Verificar si existe el archivo de configuración
        if config_path.exists():
            with open(config_path, 'r') as f:
                network_config = json.load(f)
            return network_config
        else:
            logger.warning(f"No se encontró archivo de configuración de red en {config_path}")
            return default_config
    except Exception as e:
        logger.error(f"Error al obtener configuración de red: {e}")
        return default_config

def get_system_info():
    """
    Obtiene información del sistema operativo
    
    Returns:
        dict: Información del sistema
    """
    info = {
        "os": platform.system(),
        "os_version": platform.version(),
        "hostname": socket.gethostname(),
        "ip": get_machine_ip(),
        "python_version": platform.python_version(),
        "platform": platform.platform()
    }
    
    return info 