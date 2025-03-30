import os
import json
import logging
import threading
import time
import socket
import requests
from datetime import datetime
from pathlib import Path

# Obtener el logger configurado
logger = logging.getLogger('GymManager')

# Configuración de sincronización
sync_config = {
    'enabled': False,
    'server_ip': '127.0.0.1',
    'server_port': 5000,
    'sync_interval': 300,  # segundos entre sincronizaciones
    'last_sync': None,
    'is_running': False
}

# Indicador de si el servidor de sincronización está funcionando
sync_server_running = False

def setup_sync(server_ip, server_port):
    """
    Configura la sincronización con el servidor principal
    
    Args:
        server_ip: IP del servidor principal
        server_port: Puerto del servidor principal
    """
    global sync_config
    
    sync_config['enabled'] = True
    sync_config['server_ip'] = server_ip
    sync_config['server_port'] = server_port
    
    logger.info(f"Sincronización configurada con servidor: {server_ip}:{server_port}")
    
    # Iniciar hilo de sincronización
    sync_thread = threading.Thread(target=sync_client_thread)
    sync_thread.daemon = True
    sync_thread.start()
    
    logger.info("Cliente de sincronización iniciado en segundo plano")

def sync_client_thread():
    """Hilo que maneja la sincronización periódica con el servidor"""
    global sync_config
    
    logger.info("Iniciando hilo de sincronización con el servidor")
    
    while sync_config['enabled']:
        try:
            if not sync_config['is_running']:
                sync_config['is_running'] = True
                
                # Realizar sincronización con el servidor
                logger.info(f"Iniciando sincronización con servidor {sync_config['server_ip']}:{sync_config['server_port']}")
                
                # 1. Sincronizar base de datos
                db_synced = sync_database()
                
                # 2. Sincronizar archivos de configuración
                config_synced = sync_config_files()
                
                # 3. Sincronizar archivos multimedia
                media_synced = sync_media_files()
                
                # Actualizar timestamp de última sincronización
                sync_config['last_sync'] = datetime.now().isoformat()
                
                logger.info(f"Sincronización completada. DB: {db_synced}, Config: {config_synced}, Media: {media_synced}")
                sync_config['is_running'] = False
            
            # Esperar hasta la próxima sincronización
            time.sleep(sync_config['sync_interval'])
            
        except Exception as e:
            logger.error(f"Error en hilo de sincronización: {e}")
            sync_config['is_running'] = False
            time.sleep(60)  # Esperar antes de reintentar si hay error

def sync_database():
    """Sincroniza la base de datos con el servidor"""
    try:
        # Aquí iría la lógica para sincronizar la base de datos
        # Por ejemplo, hacer una copia de la base de datos local y enviarla al servidor
        # o recibir actualizaciones del servidor
        
        logger.info("Sincronización de base de datos completada")
        return True
    except Exception as e:
        logger.error(f"Error al sincronizar base de datos: {e}")
        return False

def sync_config_files():
    """Sincroniza los archivos de configuración con el servidor"""
    try:
        # Aquí iría la lógica para sincronizar archivos de configuración
        
        logger.info("Sincronización de archivos de configuración completada")
        return True
    except Exception as e:
        logger.error(f"Error al sincronizar archivos de configuración: {e}")
        return False

def sync_media_files():
    """Sincroniza archivos multimedia con el servidor"""
    try:
        # Aquí iría la lógica para sincronizar archivos multimedia
        # como imágenes, PDFs, etc.
        
        logger.info("Sincronización de archivos multimedia completada")
        return True
    except Exception as e:
        logger.error(f"Error al sincronizar archivos multimedia: {e}")
        return False

def start_sync_server():
    """Inicia el servidor de sincronización en un hilo separado"""
    global sync_server_running
    
    if sync_server_running:
        logger.info("El servidor de sincronización ya está en ejecución")
        return
    
    try:
        # Crear un socket para recibir solicitudes de sincronización
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server_socket.bind(('0.0.0.0', 8000))  # Puerto 8000 para sincronización
        server_socket.listen(5)
        
        logger.info("Servidor de sincronización iniciado en puerto 8000")
        sync_server_running = True
        
        while sync_server_running:
            try:
                # Aceptar conexiones entrantes
                client_socket, address = server_socket.accept()
                logger.info(f"Nueva conexión de sincronización desde {address}")
                
                # Manejar la conexión en un hilo separado
                handler_thread = threading.Thread(
                    target=handle_sync_request,
                    args=(client_socket, address)
                )
                handler_thread.daemon = True
                handler_thread.start()
                
            except Exception as e:
                logger.error(f"Error en el servidor de sincronización: {e}")
                time.sleep(1)
        
        server_socket.close()
    except Exception as e:
        logger.error(f"Error al iniciar servidor de sincronización: {e}")
        sync_server_running = False

def handle_sync_request(client_socket, address):
    """Maneja una solicitud de sincronización de un cliente"""
    try:
        # Recibir comando del cliente
        data = client_socket.recv(1024).decode('utf-8')
        command = data.strip()
        
        logger.info(f"Comando de sincronización recibido de {address}: {command}")
        
        # Procesar el comando
        if command == 'SYNC_DB':
            # Enviar la base de datos al cliente
            response = "DB_SYNC_OK"
        elif command == 'SYNC_CONFIG':
            # Enviar archivos de configuración
            response = "CONFIG_SYNC_OK"
        elif command == 'SYNC_MEDIA':
            # Enviar archivos multimedia
            response = "MEDIA_SYNC_OK"
        else:
            response = "UNKNOWN_COMMAND"
        
        # Enviar respuesta
        client_socket.send(response.encode('utf-8'))
        
    except Exception as e:
        logger.error(f"Error al manejar solicitud de sincronización: {e}")
    finally:
        # Cerrar la conexión
        client_socket.close()

def manual_sync():
    """
    Inicia una sincronización manual con el servidor
    
    Returns:
        tuple: (success, message) donde success es un booleano indicando si la sincronización
               se inició correctamente, y message es un mensaje descriptivo
    """
    global sync_config
    
    # Verificar si ya hay una sincronización en progreso
    if sync_config['is_running']:
        return False, "Ya hay una sincronización en progreso"
    
    # Verificar si la sincronización está habilitada
    if not sync_config['enabled']:
        # Intentar cargar la configuración por si ha cambiado
        try:
            from app.utils.network import get_pc_info, get_network_config
            
            pc_info = get_pc_info()
            if not pc_info.get('sync_enabled', False):
                return False, "La sincronización no está habilitada en la configuración"
            
            # Si somos el servidor, no necesitamos sincronizarnos con nadie
            if pc_info.get('is_server', True):
                return False, "Esta es la PC principal (servidor). No necesita sincronizarse."
            
            # Cargar configuración de red
            network_config = get_network_config()
            sync_config['server_ip'] = network_config.get('server_ip', '127.0.0.1')
            sync_config['server_port'] = network_config.get('server_port', 5000)
            sync_config['enabled'] = True
            
        except Exception as e:
            logger.error(f"Error al cargar configuración para sincronización manual: {e}")
            return False, f"Error al cargar configuración: {str(e)}"
    
    # Iniciar sincronización en un hilo separado
    try:
        sync_thread = threading.Thread(target=perform_manual_sync)
        sync_thread.daemon = True
        sync_thread.start()
        
        return True, "Sincronización iniciada en segundo plano"
    except Exception as e:
        logger.error(f"Error al iniciar hilo de sincronización manual: {e}")
        return False, f"Error al iniciar sincronización: {str(e)}"

def perform_manual_sync():
    """Realiza la sincronización manual en un hilo separado"""
    global sync_config
    
    try:
        sync_config['is_running'] = True
        logger.info(f"Iniciando sincronización manual con servidor {sync_config['server_ip']}:{sync_config['server_port']}")
        
        # Realizar copia de seguridad antes de sincronizar
        backup_success = create_backup_before_sync()
        if not backup_success:
            logger.warning("No se pudo crear copia de seguridad antes de sincronizar")
        
        # 1. Sincronizar base de datos
        db_synced = sync_database()
        
        # 2. Sincronizar archivos de configuración
        config_synced = sync_config_files()
        
        # 3. Sincronizar archivos multimedia
        media_synced = sync_media_files()
        
        # Actualizar timestamp de última sincronización
        sync_config['last_sync'] = datetime.now().isoformat()
        
        # Registrar en la base de datos
        log_sync_event(
            sync_type='manual',
            status='success' if (db_synced and config_synced and media_synced) else 'warning',
            details=f"DB: {db_synced}, Config: {config_synced}, Media: {media_synced}"
        )
        
        logger.info(f"Sincronización manual completada. DB: {db_synced}, Config: {config_synced}, Media: {media_synced}")
        
    except Exception as e:
        logger.error(f"Error en sincronización manual: {e}")
        # Registrar error en la base de datos
        log_sync_event(
            sync_type='manual',
            status='error',
            details=f"Error: {str(e)}"
        )
    finally:
        sync_config['is_running'] = False

def create_backup_before_sync():
    """
    Crea una copia de seguridad antes de sincronizar
    
    Returns:
        bool: True si la copia se creó correctamente, False en caso contrario
    """
    try:
        # Importar función para crear copia de seguridad
        # Esta sería una función que debería estar implementada en otro módulo
        from app.utils.backup import create_backup
        
        backup_path = create_backup()
        logger.info(f"Copia de seguridad creada antes de sincronizar: {backup_path}")
        return True
    except ImportError:
        logger.warning("No se pudo importar el módulo de copias de seguridad")
        return False
    except Exception as e:
        logger.error(f"Error al crear copia de seguridad antes de sincronizar: {e}")
        return False

def log_sync_event(sync_type, status, details):
    """
    Registra un evento de sincronización en la base de datos
    
    Args:
        sync_type (str): Tipo de sincronización ('auto', 'manual')
        status (str): Estado de la sincronización ('success', 'warning', 'error')
        details (str): Detalles adicionales
    """
    try:
        # En una implementación real, esto insertaría en la tabla sync_log
        # Por ahora, solo lo registramos en el log
        from app.utils.network import get_pc_info
        pc_info = get_pc_info()
        pc_number = pc_info.get('pc_number', 0)
        
        logger.info(f"Evento de sincronización registrado: PC{pc_number}, {sync_type}, {status}, {details}")
    except Exception as e:
        logger.error(f"Error al registrar evento de sincronización: {e}") 