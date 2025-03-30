import os
import sqlite3
import logging
from pathlib import Path

# Obtener el logger configurado
logger = logging.getLogger('GymManager')

def init_database(db_path):
    """
    Inicializa la base de datos con las tablas necesarias
    
    Args:
        db_path: Ruta al archivo de base de datos
    """
    # Asegurar que el directorio existe
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    
    logger.info(f"Inicializando base de datos en: {db_path}")
    
    # Conectar a la base de datos (la crea si no existe)
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Crear tablas
    try:
        # Tabla de usuarios
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            email TEXT,
            role TEXT DEFAULT 'user',
            is_active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_login TIMESTAMP
        )
        ''')
        
        # Tabla de profesores
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS teachers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            email TEXT,
            phone TEXT,
            rate_per_class REAL DEFAULT 0,
            is_active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        ''')
        
        # Tabla de clases
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS classes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            class_type TEXT DEFAULT 'OTHER',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        ''')
        
        # Tabla de horarios de clase
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS schedules (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            class_id INTEGER NOT NULL,
            teacher_id INTEGER NOT NULL,
            day_of_week INTEGER NOT NULL, -- 0=Monday, 6=Sunday
            start_time TIME NOT NULL,
            duration INTEGER DEFAULT 60, -- Duration in minutes
            max_capacity INTEGER DEFAULT 20,
            is_active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (class_id) REFERENCES classes (id),
            FOREIGN KEY (teacher_id) REFERENCES teachers (id)
        )
        ''')
        
        # Tabla de clases realizadas (asistencia)
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            schedule_id INTEGER NOT NULL,
            teacher_id INTEGER NOT NULL,
            class_date DATE NOT NULL,
            arrival_time TIME,
            students_count INTEGER DEFAULT 0,
            notes TEXT,
            audio_file TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (schedule_id) REFERENCES schedules (id),
            FOREIGN KEY (teacher_id) REFERENCES teachers (id)
        )
        ''')
        
        # Tabla de configuración
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT,
            description TEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        ''')
        
        # Tabla de sincronización
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS sync_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pc_number INTEGER NOT NULL,
            sync_type TEXT NOT NULL,
            sync_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            status TEXT NOT NULL,
            details TEXT
        )
        ''')
        
        # Guardar cambios
        conn.commit()
        logger.info("Tablas creadas correctamente")
        
        # Insertar datos iniciales si la base de datos está vacía
        cursor.execute("SELECT COUNT(*) FROM users")
        user_count = cursor.fetchone()[0]
        
        if user_count == 0:
            # Insertar usuario admin por defecto (contraseña: admin)
            cursor.execute('''
            INSERT INTO users (username, password_hash, email, role)
            VALUES ('admin', '$2b$12$Vqr5ISdE0WoF9GlE0Ic.JOiwSJZ8YzGJOIwKaumHLvf1XnbL8F7.y', 'admin@example.com', 'admin')
            ''')
            
            # Insertar configuraciones iniciales
            settings = [
                ('app_name', 'GymManager', 'Nombre de la aplicación'),
                ('gym_name', 'Mi Gimnasio', 'Nombre del gimnasio'),
                ('notification_phone', '', 'Número de teléfono para notificaciones'),
                ('sync_enabled', 'true', 'Habilitar sincronización entre equipos'),
                ('version', '1.0.0', 'Versión de la aplicación')
            ]
            
            cursor.executemany('''
            INSERT INTO settings (key, value, description)
            VALUES (?, ?, ?)
            ''', settings)
            
            conn.commit()
            logger.info("Datos iniciales insertados correctamente")
    
    except Exception as e:
        conn.rollback()
        logger.error(f"Error al crear tablas: {e}")
        raise
    
    finally:
        # Cerrar conexión
        conn.close()
    
    return True

def get_db_connection(db_path):
    """
    Obtiene una conexión a la base de datos
    
    Args:
        db_path: Ruta al archivo de base de datos
        
    Returns:
        Conexión a la base de datos
    """
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row  # Permite acceder a las filas como diccionarios
    return conn 