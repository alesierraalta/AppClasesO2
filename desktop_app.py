import os
import sys
import time
import webview
import threading
import logging
import sqlite3
import json
import socket
import datetime
import requests
from pathlib import Path
from app import app, db
from flask import request, jsonify, send_file
from apscheduler.schedulers.background import BackgroundScheduler

# Configurar registro de logs
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("gymmanager.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("GymManager")

# Cargar configuración de sincronización
def load_sync_config():
    config_path = "sync_config.json"
    default_config = {
        "sync_interval": 300,
        "is_primary_server": False,
        "sync_servers": [
            "http://192.168.1.100:5000/sync",
            "http://192.168.1.101:5000/sync",
            "http://192.168.1.102:5000/sync"
        ],
        "server_name": "Recepción",
        "backup_folder": "backups"
    }
    
    try:
        if os.path.exists(config_path):
            with open(config_path, 'r') as f:
                config = json.load(f)
                logger.info("Configuración de sincronización cargada correctamente")
                return config
        else:
            # Crear configuración por defecto si no existe
            with open(config_path, 'w') as f:
                json.dump(default_config, f, indent=4)
            logger.info("Creada configuración de sincronización por defecto")
            return default_config
    except Exception as e:
        logger.error(f"Error al cargar configuración: {str(e)}")
        return default_config

# Cargar configuración
SYNC_CONFIG = load_sync_config()
SYNC_INTERVAL = SYNC_CONFIG["sync_interval"]
DATABASE_PATH = 'gimnasio.db'
SYNC_SERVERS = SYNC_CONFIG["sync_servers"]
SERVER_NAME = SYNC_CONFIG["server_name"]
BACKUP_FOLDER = SYNC_CONFIG["backup_folder"]

# Crear carpeta de backups si no existe
if not os.path.exists(BACKUP_FOLDER):
    os.makedirs(BACKUP_FOLDER)

# Obtener la IP local de esta computadora
def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception as e:
        logger.error(f"Error al obtener IP local: {str(e)}")
        return "127.0.0.1"

LOCAL_IP = get_local_ip()
SYNC_ENDPOINT = f'http://{LOCAL_IP}:5000/sync'

# Eliminar nuestra propia IP de la lista de servidores de sincronización
SYNC_SERVERS = [server for server in SYNC_SERVERS 
               if not server.startswith(f'http://{LOCAL_IP}:')]

# Agregar un endpoint para configuración
@app.route('/config', methods=['GET'])
def get_config():
    return jsonify({
        "name": SERVER_NAME,
        "ip": LOCAL_IP,
        "sync_interval": SYNC_INTERVAL,
        "is_primary": SYNC_CONFIG["is_primary_server"],
        "sync_servers": SYNC_SERVERS,
        "db_version": os.path.getmtime(DATABASE_PATH) if os.path.exists(DATABASE_PATH) else 0
    })

# Ruta para manejo de sincronización
@app.route('/sync', methods=['GET', 'POST'])
def sync_database():
    if request.method == 'GET':
        # Enviar timestamp de última actualización y hash de BD
        last_modified = os.path.getmtime(DATABASE_PATH) if os.path.exists(DATABASE_PATH) else 0
        timestamp = datetime.datetime.fromtimestamp(last_modified).isoformat()
        return jsonify({
            'db_timestamp': timestamp,
            'server_name': SERVER_NAME,
            'status': 'ok'
        })
    
    elif request.method == 'POST':
        try:
            # Recibir actualización de base de datos
            if 'db_file' not in request.files:
                return jsonify({'status': 'error', 'message': 'No database file'}), 400
            
            db_file = request.files['db_file']
            
            # Crear backup de la base de datos actual
            if os.path.exists(DATABASE_PATH):
                backup_name = f"{os.path.basename(DATABASE_PATH)}.bak.{int(time.time())}"
                backup_path = os.path.join(BACKUP_FOLDER, backup_name)
                with open(DATABASE_PATH, 'rb') as src, open(backup_path, 'wb') as dst:
                    dst.write(src.read())
                logger.info(f"Backup creado en {backup_path}")
            
            # Guardar la nueva base de datos
            db_file.save(DATABASE_PATH)
            
            # Reiniciar conexión a la base de datos
            with app.app_context():
                db.session.remove()
            
            logger.info(f"Base de datos sincronizada desde {request.remote_addr}")
            return jsonify({'status': 'success'})
            
        except Exception as e:
            logger.error(f"Error en sincronización: {str(e)}")
            return jsonify({'status': 'error', 'message': str(e)}), 500

# Función de sincronización
def sync_with_servers():
    try:
        logger.info("Iniciando sincronización con otros servidores...")
        
        # Verificar si existe la base de datos
        if not os.path.exists(DATABASE_PATH):
            logger.warning("No se puede sincronizar: base de datos no encontrada")
            return
        
        # Obtener timestamp de nuestra base de datos
        local_last_modified = os.path.getmtime(DATABASE_PATH)
        
        # Verificar cada servidor
        for server_url in SYNC_SERVERS:
            try:
                # Obtener información de timestamp del servidor remoto
                logger.info(f"Verificando servidor: {server_url}")
                response = requests.get(server_url, timeout=5)
                if response.status_code == 200:
                    remote_data = response.json()
                    remote_timestamp = datetime.datetime.fromisoformat(remote_data['db_timestamp'])
                    remote_time = remote_timestamp.timestamp()
                    server_name = remote_data.get('server_name', 'Unknown')
                    
                    # Si el servidor remoto tiene una BD más reciente, obtenerla
                    if remote_time > local_last_modified:
                        logger.info(f"Servidor '{server_name}' tiene una BD más reciente. Descargando...")
                        
                        # Descargar la BD desde el servidor
                        response = requests.get(f"{server_url}/download", timeout=10)
                        if response.status_code == 200:
                            # Hacer backup de la BD actual
                            backup_name = f"{os.path.basename(DATABASE_PATH)}.bak.{int(time.time())}"
                            backup_path = os.path.join(BACKUP_FOLDER, backup_name)
                            with open(DATABASE_PATH, 'rb') as src, open(backup_path, 'wb') as dst:
                                dst.write(src.read())
                            
                            # Guardar la nueva BD
                            with open(DATABASE_PATH, 'wb') as f:
                                f.write(response.content)
                            
                            # Reiniciar conexión a la base de datos
                            with app.app_context():
                                db.session.remove()
                            
                            logger.info(f"Sincronización exitosa con '{server_name}'")
                            # Terminamos después de actualizar desde un servidor
                            break
                        else:
                            logger.error(f"Error al descargar BD de '{server_name}': {response.text}")
                            
                    # Si nuestra BD es más reciente y estamos en el servidor principal, enviarla
                    elif remote_time < local_last_modified and SYNC_CONFIG["is_primary_server"]:
                        logger.info(f"Enviando actualización a '{server_name}'...")
                        
                        # Enviar nuestra BD al servidor remoto
                        with open(DATABASE_PATH, 'rb') as f:
                            files = {'db_file': (os.path.basename(DATABASE_PATH), f)}
                            upload_response = requests.post(server_url, files=files, timeout=10)
                        
                        if upload_response.status_code == 200:
                            logger.info(f"Actualización enviada exitosamente a '{server_name}'")
                        else:
                            logger.error(f"Error al enviar actualización a '{server_name}': {upload_response.text}")
                    
                    else:
                        logger.info(f"Base de datos ya sincronizada con '{server_name}'")
                        
            except requests.exceptions.RequestException as e:
                logger.error(f"Error de conexión con {server_url}: {str(e)}")
                continue
                
    except Exception as e:
        logger.error(f"Error durante la sincronización: {str(e)}")

# Ruta para descargar la base de datos completa
@app.route('/sync/download', methods=['GET'])
def download_database():
    try:
        if os.path.exists(DATABASE_PATH):
            return send_file(DATABASE_PATH, as_attachment=True)
        else:
            return jsonify({'status': 'error', 'message': 'Database file not found'}), 404
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/asistencia/upload_audio/<int:horario_id>', methods=['POST'])
def upload_audio(horario_id):
    if 'audio' not in request.files:
        return 'No file part', 400
    file = request.files['audio']
    if file.filename == '':
        return 'No selected file', 400
    # Save the file logic here
    file.save(os.path.join('uploads', file.filename))
    return 'File uploaded successfully', 200

def start_server():
    """Iniciar el servidor Flask en segundo plano"""
    try:
        # Verificar si la BD existe y crearla si no
        if not os.path.exists('gimnasio.db'):
            with app.app_context():
                db.create_all()
                logger.info("Base de datos inicializada correctamente.")
        
        # Configurar la aplicación para producción
        app.config['ENV'] = 'production'
        app.config['DEBUG'] = False
        app.config['TESTING'] = False
        
        # Iniciar el programador de tareas para sincronización
        scheduler = BackgroundScheduler()
        scheduler.add_job(sync_with_servers, 'interval', seconds=SYNC_INTERVAL)
        scheduler.start()
        
        # Ejecutar la aplicación Flask
        logger.info(f"Iniciando servidor Flask en http://{LOCAL_IP}:5000 ({SERVER_NAME})")
        app.run(host='0.0.0.0', port=5000, debug=False, use_reloader=False)
    except Exception as e:
        logger.error(f"Error al iniciar el servidor: {str(e)}")
        raise

def run_app():
    """Ejecutar la aplicación como ventana de escritorio"""
    try:
        logger.info(f"Iniciando aplicación GymManager ({SERVER_NAME})...")
        
        # Iniciar el servidor Flask en un hilo separado
        t = threading.Thread(target=start_server)
        t.daemon = True
        t.start()
        
        # Esperar a que el servidor esté listo
        time.sleep(2)
        
        # Crear y mostrar la ventana de la aplicación
        logger.info("Abriendo ventana de la aplicación...")
        webview.create_window(
            title=f'GymManager - {SERVER_NAME}', 
            url=f'http://localhost:5000',
            width=1200,
            height=800,
            resizable=True,
            min_size=(800, 600),
            text_select=True,
            confirm_close=True,
            background_color='#FFFFFF'
        )
        webview.start(debug=False)
    except Exception as e:
        logger.error(f"Error en la aplicación: {str(e)}")
        input("Presiona Enter para salir...")
        sys.exit(1)

if __name__ == '__main__':
    run_app() 