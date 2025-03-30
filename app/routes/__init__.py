# Archivo __init__.py para el módulo routes
# Este directorio contiene las rutas de la aplicación

def register_routes(app):
    """
    Registra todas las rutas de la aplicación
    
    Args:
        app: La aplicación Flask
    """
    from flask import render_template, redirect, url_for, request
    
    # Rutas básicas
    @app.route('/')
    def index():
        """Página principal de la aplicación"""
        return render_template('index.html')
    
    @app.route('/dashboard')
    def dashboard():
        """Panel de control principal"""
        return render_template('dashboard.html')
    
    # Aquí se importarán y registrarán las demás rutas
    from app.routes.auth import auth_bp
    from app.routes.admin import admin_bp
    from app.routes.api import api_bp
    
    # Registrar blueprints
    app.register_blueprint(auth_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(api_bp) 