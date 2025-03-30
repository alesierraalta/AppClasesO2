import os
import sys
import logging
import threading
from pathlib import Path
from flask import Flask, render_template, request, jsonify, redirect, url_for

# Obtener el logger configurado en main.py
logger = logging.getLogger('GymManager')

# Crear la aplicación Flask
app = Flask(__name__, 
           template_folder=os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'templates'),
           static_folder=os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'static'))

# Verificar si estamos ejecutando como ejecutable compilado
is_frozen = getattr(sys, 'frozen', False) or os.environ.get('GYMMANAGER_EXEC_MODE') == 'True'

# Verificar si esta instancia es el servidor principal
is_server = True  # Por defecto, asumimos que es el servidor

# Configurar la aplicación
def configure_app():
    """Configurar la aplicación con las rutas y settings necesarios"""
    from app.routes import register_routes
    
    # Configuramos la aplicación
    app.config['SECRET_KEY'] = 'clave_secreta_gymmanager'
    app.config['UPLOAD_FOLDER'] = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'uploads')
    app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max upload
    
    # Registrar rutas de la aplicación
    register_routes(app)
    
    # Cargar configuración de la PC
    global is_server
    try:
        # Determinar ubicación de archivos de configuración según modo
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
            import json
            with open(config_path, 'r') as f:
                pc_config = json.load(f)
            is_server = pc_config.get('is_server', True)
            pc_number = pc_config.get('pc_number', 1)
            sync_enabled = pc_config.get('sync_enabled', True)
            
            logger.info(f"Configuración cargada: PC{pc_number}, {'Servidor' if is_server else 'Cliente'}, Sincronización {'activada' if sync_enabled else 'desactivada'}")
            
            # Si es cliente y tiene sincronización activada, configurar comunicación con servidor
            if not is_server and sync_enabled:
                # Cargar configuración de red
                if is_frozen:
                    network_config_path = base_dir / 'data' / 'config' / 'network_config.json'
                else:
                    network_config_path = base_dir / 'app' / 'core' / 'network_config.json'
                
                if network_config_path.exists():
                    with open(network_config_path, 'r') as f:
                        network_config = json.load(f)
                    server_ip = network_config.get('server_ip', '127.0.0.1')
                    server_port = network_config.get('server_port', 5000)
                    
                    logger.info(f"Configuración de red: Servidor en {server_ip}:{server_port}")
                    
                    # Configurar sincronización
                    from app.core.sync import setup_sync
                    setup_sync(server_ip, server_port)
                else:
                    logger.warning("No se encontró configuración de red. La sincronización no estará disponible.")
        else:
            logger.warning("No se encontró archivo de configuración de PC. Se usará configuración por defecto.")
    except Exception as e:
        logger.error(f"Error al cargar configuración: {e}")

# Manejar errores 404
@app.errorhandler(404)
def not_found(error):
    return render_template('404.html'), 404

# Manejar errores 500
@app.errorhandler(500)
def server_error(error):
    return render_template('500.html'), 500

# Iniciar el servidor de sincronización si es el servidor principal
def start_sync_server():
    """Inicia el servidor de sincronización en un hilo separado si esta es la PC principal"""
    if is_server:
        try:
            from app.core.sync import start_sync_server
            sync_thread = threading.Thread(target=start_sync_server)
            sync_thread.daemon = True
            sync_thread.start()
            logger.info("Servidor de sincronización iniciado en segundo plano")
        except Exception as e:
            logger.error(f"Error al iniciar servidor de sincronización: {e}")

# Función principal para iniciar la aplicación
def start_app(debug=False):
    """Inicia la aplicación Flask"""
    logger.info("Iniciando aplicación GymManager...")
    
    try:
        # Configurar la aplicación
        configure_app()
        
        # Iniciar servidor de sincronización si corresponde
        start_sync_server()
        
        # Iniciar la aplicación Flask
        host = '0.0.0.0'  # Escuchar en todas las interfaces
        port = 5000       # Puerto por defecto
        
        logger.info(f"Iniciando servidor web en {host}:{port}")
        app.run(host=host, port=port, debug=debug)
        
    except Exception as e:
        logger.error(f"Error al iniciar la aplicación: {e}")
        raise

# Si este script se ejecuta directamente
if __name__ == "__main__":
    # Configuración básica de logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger('GymManager')
    
    # Iniciar la aplicación en modo debug
    start_app(debug=True)
