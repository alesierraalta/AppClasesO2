from flask import Blueprint, render_template, redirect, url_for, request, flash, jsonify
from flask_login import login_required
import logging
import json
from pathlib import Path
import os
import sys

# Obtener el logger configurado
logger = logging.getLogger('GymManager')

# Crear el blueprint para las rutas de administración
admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

@admin_bp.route('/')
@login_required
def index():
    """Panel de administración principal"""
    return render_template('admin/index.html')

@admin_bp.route('/users')
@login_required
def users():
    """Gestión de usuarios"""
    # Aquí iría la lógica para obtener la lista de usuarios
    users = []  # Esto se reemplazaría con una consulta a la base de datos
    return render_template('admin/users.html', users=users)

@admin_bp.route('/settings')
@login_required
def settings():
    """Configuración del sistema"""
    return render_template('admin/settings.html')

@admin_bp.route('/backup')
@login_required
def backup():
    """Gestión de copias de seguridad"""
    # Obtener lista de copias de seguridad
    from app.utils.backup import list_backups
    backups = list_backups()
    
    return render_template('admin/backup.html', backups=backups)

@admin_bp.route('/backup/create', methods=['POST'])
@login_required
def create_backup():
    """Crear una copia de seguridad"""
    try:
        from app.utils.backup import create_backup
        backup_path = create_backup()
        
        if backup_path:
            flash(f'Copia de seguridad creada correctamente en {backup_path}', 'success')
        else:
            flash('Error al crear copia de seguridad', 'danger')
            
        return redirect(url_for('admin.backup'))
    except Exception as e:
        logger.error(f"Error al crear copia de seguridad: {e}")
        flash(f'Error al crear copia de seguridad: {str(e)}', 'danger')
        return redirect(url_for('admin.backup'))

@admin_bp.route('/backup/restore/<path:backup_file>', methods=['POST'])
@login_required
def restore_backup(backup_file):
    """Restaurar desde una copia de seguridad"""
    try:
        from app.utils.backup import restore_from_backup
        success = restore_from_backup(backup_file)
        
        if success:
            flash('Restauración completada correctamente', 'success')
        else:
            flash('Error al restaurar desde copia de seguridad', 'danger')
            
        return redirect(url_for('admin.backup'))
    except Exception as e:
        logger.error(f"Error al restaurar desde copia de seguridad: {e}")
        flash(f'Error al restaurar desde copia de seguridad: {str(e)}', 'danger')
        return redirect(url_for('admin.backup'))

@admin_bp.route('/backup/delete/<path:backup_file>', methods=['POST'])
@login_required
def delete_backup(backup_file):
    """Eliminar una copia de seguridad"""
    try:
        import os
        if os.path.exists(backup_file):
            os.remove(backup_file)
            flash('Copia de seguridad eliminada correctamente', 'success')
        else:
            flash('No se encontró el archivo de copia de seguridad', 'warning')
            
        return redirect(url_for('admin.backup'))
    except Exception as e:
        logger.error(f"Error al eliminar copia de seguridad: {e}")
        flash(f'Error al eliminar copia de seguridad: {str(e)}', 'danger')
        return redirect(url_for('admin.backup'))

@admin_bp.route('/sync')
@login_required
def sync():
    """Configuración de sincronización entre computadoras"""
    try:
        # Importar funciones de red
        from app.utils.network import get_pc_info, get_network_config, get_system_info
        
        # Obtener información de configuración
        pc_info = get_pc_info()
        network_config = get_network_config()
        system_info = get_system_info()
        
        # Obtener estado de sincronización
        from app.core.sync import sync_config
        sync_status = {
            'is_synced': True,  # Por defecto, asumimos que está sincronizado
            'last_sync': sync_config.get('last_sync', None),
            'is_running': sync_config.get('is_running', False)
        }
        
        # Obtener logs de sincronización (en una app real, estos vendrían de la BD)
        sync_logs = [
            {
                'id': 1,
                'pc_number': pc_info.get('pc_number', 1),
                'sync_type': 'auto',
                'sync_timestamp': '2023-07-01T10:00:00',
                'status': 'success',
                'details': 'Sincronización automática exitosa'
            },
            {
                'id': 2,
                'pc_number': pc_info.get('pc_number', 1),
                'sync_type': 'manual',
                'sync_timestamp': '2023-07-01T15:30:00',
                'status': 'warning',
                'details': 'Sincronización parcial: algunos archivos no se pudieron sincronizar'
            }
        ]
        
        return render_template(
            'admin/sync.html',
            pc_info=pc_info,
            network_config=network_config,
            system_info=system_info,
            sync_status=sync_status,
            sync_logs=sync_logs
        )
    except Exception as e:
        logger.error(f"Error al cargar página de sincronización: {e}")
        flash(f'Error al cargar configuración de sincronización: {str(e)}', 'danger')
        return render_template('admin/sync.html')

@admin_bp.route('/sync/config', methods=['POST'])
@login_required
def sync_config_update():
    """Actualiza la configuración de sincronización"""
    try:
        # Obtener datos del formulario
        sync_enabled = 'sync_enabled' in request.form
        
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
        
        # Cargar configuración actual
        from app.utils.network import get_pc_info, get_network_config
        pc_info = get_pc_info()
        network_config = get_network_config()
        
        # Actualizar configuración de PC
        pc_info['sync_enabled'] = sync_enabled
        
        # Guardar configuración de PC
        with open(pc_config_path, 'w') as f:
            json.dump(pc_info, f, indent=2)
        
        # Si no es el servidor principal, actualizar configuración de red
        if not pc_info.get('is_server', True):
            server_ip = request.form.get('server_ip', network_config.get('server_ip', '127.0.0.1'))
            server_port = int(request.form.get('server_port', network_config.get('server_port', 5000)))
            sync_interval = int(request.form.get('sync_interval', network_config.get('sync_interval', 300)))
            backup_before_sync = 'backup_before_sync' in request.form
            
            # Actualizar configuración de red
            network_config['server_ip'] = server_ip
            network_config['server_port'] = server_port
            network_config['sync_interval'] = sync_interval
            network_config['backup_before_sync'] = backup_before_sync
            
            # Guardar configuración de red
            with open(network_config_path, 'w') as f:
                json.dump(network_config, f, indent=2)
        
        flash('Configuración de sincronización actualizada correctamente', 'success')
        
        # Actualizar la configuración en el módulo de sincronización
        if sync_enabled:
            from app.core.sync import setup_sync
            setup_sync(
                network_config.get('server_ip', '127.0.0.1'),
                network_config.get('server_port', 5000)
            )
        
        return redirect(url_for('admin.sync'))
    except Exception as e:
        logger.error(f"Error al actualizar configuración de sincronización: {e}")
        flash(f'Error al actualizar configuración: {str(e)}', 'danger')
        return redirect(url_for('admin.sync'))

@admin_bp.route('/sync/test', methods=['POST'])
@login_required
def test_sync_connection():
    """Prueba la conexión con el servidor principal"""
    try:
        # Obtener datos del formulario
        server_ip = request.form.get('server_ip')
        server_port = int(request.form.get('server_port', 5000))
        
        # Importar función para probar conexión
        from app.utils.network import check_server_connection, check_server_api
        
        # Probar conexión básica
        connection_success = check_server_connection(server_ip, server_port)
        
        # Si la conexión básica es exitosa, probar API
        api_success = False
        if connection_success:
            api_success = check_server_api(server_ip, server_port)
        
        # Mostrar mensaje según resultado
        if connection_success and api_success:
            flash(f'Conexión exitosa con el servidor {server_ip}:{server_port}', 'success')
        elif connection_success:
            flash(f'Conexión de red exitosa, pero la API del servidor no está respondiendo', 'warning')
        else:
            flash(f'No se pudo establecer conexión con el servidor {server_ip}:{server_port}', 'danger')
        
        return redirect(url_for('admin.sync'))
    except Exception as e:
        logger.error(f"Error al probar conexión: {e}")
        flash(f'Error al probar conexión: {str(e)}', 'danger')
        return redirect(url_for('admin.sync'))

@admin_bp.route('/sync/start', methods=['POST'])
@login_required
def start_sync():
    """Inicia una sincronización manual"""
    try:
        # Importar función para sincronización manual
        from app.core.sync import manual_sync
        
        # Iniciar sincronización
        success, message = manual_sync()
        
        if success:
            flash(f'Sincronización iniciada: {message}', 'success')
        else:
            flash(f'Error al iniciar sincronización: {message}', 'danger')
        
        return redirect(url_for('admin.sync'))
    except Exception as e:
        logger.error(f"Error al iniciar sincronización manual: {e}")
        flash(f'Error al iniciar sincronización: {str(e)}', 'danger')
        return redirect(url_for('admin.sync'))