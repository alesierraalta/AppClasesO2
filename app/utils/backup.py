"""
Utilidades para crear y restaurar copias de seguridad de la aplicación GymManager

Este módulo proporciona funciones para:
- Crear copias de seguridad de la base de datos
- Crear copias de seguridad de archivos de configuración
- Restaurar desde copias de seguridad
"""

import os
import sys
import shutil
import logging
import sqlite3
from datetime import datetime
from pathlib import Path
import zipfile

# Obtener el logger configurado
logger = logging.getLogger('GymManager')

def get_backup_dir():
    """
    Obtiene el directorio donde se almacenan las copias de seguridad
    
    Returns:
        Path: Ruta al directorio de copias de seguridad
    """
    # Determinar si estamos en modo ejecutable o script
    is_frozen = getattr(sys, 'frozen', False)
    
    if is_frozen:
        # En modo ejecutable
        base_dir = Path(os.path.dirname(sys.executable))
        backup_dir = base_dir / 'data' / 'backups'
    else:
        # En modo script
        base_dir = Path(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
        backup_dir = base_dir / 'backups'
    
    # Asegurar que el directorio existe
    backup_dir.mkdir(parents=True, exist_ok=True)
    
    return backup_dir

def get_db_path():
    """
    Obtiene la ruta a la base de datos principal
    
    Returns:
        Path: Ruta al archivo de base de datos
    """
    # Determinar si estamos en modo ejecutable o script
    is_frozen = getattr(sys, 'frozen', False)
    
    if is_frozen:
        # En modo ejecutable
        base_dir = Path(os.path.dirname(sys.executable))
        db_path = base_dir / 'data' / 'database' / 'gymmanager.db'
    else:
        # En modo script
        base_dir = Path(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
        db_path = base_dir / 'database' / 'gymmanager.db'
    
    return db_path

def get_config_dir():
    """
    Obtiene el directorio donde se almacenan los archivos de configuración
    
    Returns:
        Path: Ruta al directorio de configuración
    """
    # Determinar si estamos en modo ejecutable o script
    is_frozen = getattr(sys, 'frozen', False)
    
    if is_frozen:
        # En modo ejecutable
        base_dir = Path(os.path.dirname(sys.executable))
        config_dir = base_dir / 'data' / 'config'
    else:
        # En modo script
        base_dir = Path(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
        config_dir = base_dir / 'app' / 'core'
    
    return config_dir

def create_backup():
    """
    Crea una copia de seguridad de la base de datos y archivos de configuración
    
    Returns:
        str: Ruta a la copia de seguridad creada, o None si hay error
    """
    try:
        # Crear un nombre único para la copia basado en la fecha y hora
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = get_backup_dir()
        backup_zip_path = backup_dir / f"backup_{timestamp}.zip"
        
        # Obtener rutas importantes
        db_path = get_db_path()
        config_dir = get_config_dir()
        
        # Verificar que la base de datos existe
        if not db_path.exists():
            logger.error(f"No se encontró la base de datos en {db_path}")
            return None
        
        # Crear un archivo ZIP con todo el contenido
        with zipfile.ZipFile(backup_zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            # Agregar base de datos
            zipf.write(db_path, arcname=f"database/gymmanager.db")
            
            # Agregar archivos de configuración
            for config_file in config_dir.glob('*.json'):
                zipf.write(config_file, arcname=f"config/{config_file.name}")
        
        logger.info(f"Copia de seguridad creada exitosamente en {backup_zip_path}")
        return str(backup_zip_path)
    
    except Exception as e:
        logger.error(f"Error al crear copia de seguridad: {e}")
        return None

def backup_database():
    """
    Crea una copia de seguridad solo de la base de datos
    
    Returns:
        str: Ruta a la copia de seguridad creada, o None si hay error
    """
    try:
        # Crear un nombre único para la copia basado en la fecha y hora
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = get_backup_dir()
        backup_db_path = backup_dir / f"db_backup_{timestamp}.db"
        
        # Obtener ruta de la base de datos
        db_path = get_db_path()
        
        # Verificar que la base de datos existe
        if not db_path.exists():
            logger.error(f"No se encontró la base de datos en {db_path}")
            return None
        
        # Crear una copia de la base de datos
        # Usamos conexión SQLite para asegurar que la copia es consistente
        conn = sqlite3.connect(db_path)
        try:
            # Crear una copia de seguridad usando el método de SQLite
            backup = sqlite3.connect(backup_db_path)
            conn.backup(backup)
            backup.close()
        finally:
            conn.close()
        
        logger.info(f"Copia de seguridad de base de datos creada exitosamente en {backup_db_path}")
        return str(backup_db_path)
    
    except Exception as e:
        logger.error(f"Error al crear copia de seguridad de base de datos: {e}")
        return None

def restore_from_backup(backup_path):
    """
    Restaura la aplicación desde una copia de seguridad
    
    Args:
        backup_path (str): Ruta al archivo de copia de seguridad (.zip)
        
    Returns:
        bool: True si la restauración fue exitosa, False en caso contrario
    """
    try:
        backup_path = Path(backup_path)
        
        # Verificar que el archivo de copia existe
        if not backup_path.exists():
            logger.error(f"No se encontró el archivo de copia de seguridad en {backup_path}")
            return False
        
        # Obtener rutas importantes
        db_path = get_db_path()
        config_dir = get_config_dir()
        
        # Crear directorio temporal para extracción
        temp_dir = get_backup_dir() / "temp_restore"
        if temp_dir.exists():
            shutil.rmtree(temp_dir)
        temp_dir.mkdir(parents=True)
        
        try:
            # Extraer el archivo ZIP
            with zipfile.ZipFile(backup_path, 'r') as zipf:
                zipf.extractall(temp_dir)
            
            # Verificar que los archivos necesarios existen en la copia
            if not (temp_dir / "database" / "gymmanager.db").exists():
                logger.error("El archivo de copia de seguridad no contiene la base de datos")
                return False
            
            # Hacer copia de seguridad de los archivos actuales antes de reemplazarlos
            current_timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            pre_restore_backup = get_backup_dir() / f"pre_restore_{current_timestamp}.zip"
            create_backup()
            
            # Restaurar la base de datos
            # Primero cerramos cualquier conexión abierta
            # En una aplicación real, podríamos tener que detener servicios primero
            
            # Copiar la base de datos restaurada
            shutil.copy2(temp_dir / "database" / "gymmanager.db", db_path)
            
            # Restaurar archivos de configuración
            if (temp_dir / "config").exists():
                for config_file in (temp_dir / "config").glob('*.json'):
                    shutil.copy2(config_file, config_dir / config_file.name)
            
            logger.info(f"Restauración completada exitosamente desde {backup_path}")
            return True
            
        finally:
            # Limpiar directorio temporal
            if temp_dir.exists():
                shutil.rmtree(temp_dir)
    
    except Exception as e:
        logger.error(f"Error al restaurar desde copia de seguridad: {e}")
        return False

def list_backups():
    """
    Obtiene una lista de copias de seguridad disponibles
    
    Returns:
        list: Lista de diccionarios con información de cada copia de seguridad
    """
    try:
        backup_dir = get_backup_dir()
        backups = []
        
        # Buscar archivos de copia de seguridad
        for backup_file in backup_dir.glob('backup_*.zip'):
            try:
                # Obtener estadísticas del archivo
                stats = backup_file.stat()
                
                # Intentar extraer la fecha del nombre del archivo
                date_str = backup_file.stem.replace('backup_', '')
                if len(date_str) >= 8:  # Al menos YYYYMMDD
                    try:
                        date = datetime.strptime(date_str[:8], "%Y%m%d")
                    except:
                        date = datetime.fromtimestamp(stats.st_mtime)
                else:
                    date = datetime.fromtimestamp(stats.st_mtime)
                
                backups.append({
                    'path': str(backup_file),
                    'filename': backup_file.name,
                    'size': stats.st_size,
                    'date': date.strftime("%Y-%m-%d"),
                    'timestamp': datetime.fromtimestamp(stats.st_mtime).strftime("%Y-%m-%d %H:%M:%S")
                })
            except Exception as e:
                logger.warning(f"Error al procesar archivo de copia de seguridad {backup_file}: {e}")
        
        # Ordenar por fecha de modificación (más reciente primero)
        backups.sort(key=lambda x: x['timestamp'], reverse=True)
        
        return backups
    
    except Exception as e:
        logger.error(f"Error al listar copias de seguridad: {e}")
        return []

def delete_old_backups(days_to_keep=30, max_backups=20):
    """
    Elimina copias de seguridad antiguas para liberar espacio
    
    Args:
        days_to_keep (int): Número de días a conservar copias de seguridad
        max_backups (int): Número máximo de copias a conservar
        
    Returns:
        int: Número de archivos eliminados
    """
    try:
        backup_dir = get_backup_dir()
        all_backups = list_backups()
        
        # Si hay menos copias que el máximo, no eliminamos nada
        if len(all_backups) <= max_backups:
            return 0
        
        # Calcular la fecha límite
        cutoff_date = datetime.now().timestamp() - (days_to_keep * 24 * 60 * 60)
        
        # Conservar las copias más recientes (hasta max_backups)
        to_keep = all_backups[:max_backups]
        to_keep_paths = [b['path'] for b in to_keep]
        
        # Eliminar las copias antiguas que no están en la lista de conservar
        count = 0
        for backup in all_backups:
            backup_path = Path(backup['path'])
            file_timestamp = backup_path.stat().st_mtime
            
            # Si el archivo es antiguo y no está en la lista de conservar, eliminarlo
            if file_timestamp < cutoff_date and backup['path'] not in to_keep_paths:
                backup_path.unlink()
                count += 1
                logger.info(f"Eliminada copia de seguridad antigua: {backup_path}")
        
        return count
    
    except Exception as e:
        logger.error(f"Error al eliminar copias de seguridad antiguas: {e}")
        return 0 