from flask import Blueprint, jsonify, request
from flask_login import login_required
import logging
import json
from datetime import datetime

# Obtener el logger configurado
logger = logging.getLogger('GymManager')

# Crear el blueprint para las rutas de la API
api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/status')
def status():
    """Verificar el estado de la API"""
    return jsonify({
        'status': 'online',
        'version': '1.0.0'
    })

@api_bp.route('/sync/status')
@login_required
def sync_status():
    """Obtener el estado de sincronización"""
    # Aquí iría la lógica para verificar el estado de sincronización
    return jsonify({
        'is_synced': True,
        'last_sync': '2023-07-01T12:00:00',
        'pending_changes': 0
    })

@api_bp.route('/users', methods=['GET'])
@login_required
def get_users():
    """Obtener lista de usuarios"""
    # Aquí iría la lógica para obtener usuarios de la base de datos
    users = [
        {'id': 1, 'username': 'admin', 'role': 'admin'},
        {'id': 2, 'username': 'usuario1', 'role': 'user'}
    ]
    return jsonify(users)

@api_bp.route('/backup', methods=['POST'])
@login_required
def create_backup():
    """Crear una copia de seguridad de datos"""
    # Aquí iría la lógica para crear una copia de seguridad
    success = True
    message = "Copia de seguridad creada correctamente"
    
    if not success:
        return jsonify({'error': 'Error al crear copia de seguridad'}), 500
        
    return jsonify({'message': message})

# Nuevos endpoints para sincronización

@api_bp.route('/sync/start', methods=['POST'])
@login_required
def sync_start():
    """Inicia una sincronización manual"""
    try:
        # Importar la función de sincronización
        from app.core.sync import manual_sync
        
        # Iniciar sincronización en un hilo en segundo plano
        success, message = manual_sync()
        
        # Registrar en log
        if success:
            logger.info(f"Sincronización manual iniciada: {message}")
        else:
            logger.warning(f"Error al iniciar sincronización manual: {message}")
        
        return jsonify({
            'success': success,
            'message': message
        })
    except Exception as e:
        logger.error(f"Error en endpoint de sincronización: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/sync/test_connection', methods=['POST'])
@login_required
def test_connection():
    """Prueba la conexión con el servidor principal"""
    try:
        # Obtener datos de la petición
        data = request.json
        server_ip = data.get('server_ip')
        server_port = int(data.get('server_port', 5000))
        
        # Importar función para probar conexión
        from app.utils.network import check_server_connection, check_server_api
        
        # Probar conexión básica
        connection_success = check_server_connection(server_ip, server_port)
        
        # Si la conexión básica es exitosa, probar API
        api_success = False
        if connection_success:
            api_success = check_server_api(server_ip, server_port)
        
        # Registrar en log
        if connection_success and api_success:
            logger.info(f"Prueba de conexión exitosa a {server_ip}:{server_port}")
            message = "Conexión exitosa al servidor principal"
            success = True
        elif connection_success:
            logger.warning(f"Conexión a {server_ip}:{server_port} exitosa, pero la API no responde")
            message = "Conexión de red exitosa, pero la API del servidor no está respondiendo"
            success = False
        else:
            logger.warning(f"No se pudo conectar al servidor {server_ip}:{server_port}")
            message = "No se pudo establecer conexión con el servidor"
            success = False
        
        return jsonify({
            'success': success,
            'message': message,
            'connection_test': connection_success,
            'api_test': api_success
        })
    except Exception as e:
        logger.error(f"Error al probar conexión: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/sync/config', methods=['GET'])
@login_required
def get_sync_config():
    """Obtiene la configuración de sincronización"""
    try:
        # Importar funciones para obtener configuración
        from app.utils.network import get_pc_info, get_network_config, get_system_info
        
        # Obtener información
        pc_info = get_pc_info()
        network_config = get_network_config()
        system_info = get_system_info()
        
        return jsonify({
            'pc_info': pc_info,
            'network_config': network_config,
            'system_info': system_info
        })
    except Exception as e:
        logger.error(f"Error al obtener configuración de sincronización: {e}")
        return jsonify({
            'error': str(e)
        }), 500

@api_bp.route('/sync/config', methods=['POST'])
@login_required
def update_sync_config():
    """Actualiza la configuración de sincronización"""
    try:
        # Obtener datos de la petición
        data = request.json
        
        # Importar funciones para determinar rutas de configuración
        import os
        import sys
        from pathlib import Path
        
        # Determinar si estamos en modo ejecutable o script
        is_frozen = getattr(sys, 'frozen', False)
        
        if is_frozen:
            # En modo ejecutable
            base_dir = Path(os.path.dirname(sys.executable))
            pc_config_path = base_dir / 'data' / 'config' / 'pc_config.json'
            network_config_path = base_dir / 'data' / 'config' / 'network_config.json'
        else:
            # En modo script
            base_dir = Path(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
            pc_config_path = base_dir / 'app' / 'core' / 'pc_config.json'
            network_config_path = base_dir / 'app' / 'core' / 'network_config.json'
        
        # Actualizar configuración de PC
        if 'pc_info' in data:
            pc_info = data['pc_info']
            # Verificar que los datos mínimos estén presentes
            if all(k in pc_info for k in ['pc_number', 'is_server', 'sync_enabled']):
                with open(pc_config_path, 'w') as f:
                    json.dump(pc_info, f, indent=2)
                logger.info(f"Configuración de PC actualizada: {pc_info}")
            else:
                return jsonify({'error': 'Datos de configuración de PC incompletos'}), 400
        
        # Actualizar configuración de red
        if 'network_config' in data:
            network_config = data['network_config']
            # Verificar que los datos mínimos estén presentes
            if all(k in network_config for k in ['server_ip', 'server_port']):
                with open(network_config_path, 'w') as f:
                    json.dump(network_config, f, indent=2)
                logger.info(f"Configuración de red actualizada: {network_config}")
            else:
                return jsonify({'error': 'Datos de configuración de red incompletos'}), 400
        
        return jsonify({
            'success': True,
            'message': 'Configuración actualizada correctamente'
        })
    except Exception as e:
        logger.error(f"Error al actualizar configuración de sincronización: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@api_bp.route('/sync/logs', methods=['GET'])
@login_required
def get_sync_logs():
    """Obtiene los registros de sincronización"""
    try:
        # En una aplicación real, esto obtendría los logs de la base de datos
        # Por ahora, devolvemos datos de muestra
        logs = [
            {
                'id': 1,
                'pc_number': 2,
                'sync_type': 'manual',
                'sync_timestamp': datetime.now().isoformat(),
                'status': 'success',
                'details': 'Sincronización manual exitosa'
            },
            {
                'id': 2,
                'pc_number': 2,
                'sync_type': 'auto',
                'sync_timestamp': datetime.now().isoformat(),
                'status': 'warning',
                'details': 'Algunos archivos no se pudieron sincronizar'
            }
        ]
        
        return jsonify(logs)
    except Exception as e:
        logger.error(f"Error al obtener logs de sincronización: {e}")
        return jsonify({
            'error': str(e)
        }), 500 