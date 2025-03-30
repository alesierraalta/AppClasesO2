#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Punto de entrada principal para la aplicación GymManager.
Este archivo permite iniciar la aplicación desde la raíz del proyecto.
"""

import os
import sys
import argparse
from pathlib import Path

# Asegurar que el directorio actual esté en el path
BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))

def parse_arguments():
    """Procesa los argumentos de línea de comandos."""
    parser = argparse.ArgumentParser(description='Aplicación GymManager')
    parser.add_argument('--debug', action='store_true', 
                        help='Iniciar en modo debug')
    parser.add_argument('--test', action='store_true',
                        help='Ejecutar tests')
    parser.add_argument('--desktop', action='store_true',
                        help='Iniciar interfaz de escritorio')
    return parser.parse_args()

def run_app(debug=False):
    """Inicia la aplicación Flask."""
    try:
        from app.core.app import app
        port = int(os.environ.get('PORT', 5000))
        app.run(host='0.0.0.0', port=port, debug=debug)
    except ImportError as e:
        print(f"Error al importar la aplicación: {e}")
        print("Asegúrese de que la estructura del proyecto sea correcta.")
        sys.exit(1)

def run_desktop_app():
    """Inicia la aplicación de escritorio."""
    try:
        from app.core.desktop_app import main as desktop_main
        desktop_main()
    except ImportError as e:
        print(f"Error al importar la aplicación de escritorio: {e}")
        print("Asegúrese de que la estructura del proyecto sea correcta.")
        sys.exit(1)

def run_tests():
    """Ejecuta las pruebas del proyecto."""
    import unittest
    tests_dir = os.path.join(BASE_DIR, 'tests')
    test_suite = unittest.defaultTestLoader.discover(tests_dir)
    test_runner = unittest.TextTestRunner(verbosity=2)
    result = test_runner.run(test_suite)
    return 0 if result.wasSuccessful() else 1

def main():
    """Función principal que coordina la ejecución de la aplicación."""
    args = parse_arguments()

    # Configurar variables de entorno importantes
    os.environ['APP_ROOT'] = str(BASE_DIR)
    
    # Ejecutar la acción solicitada
    if args.test:
        return run_tests()
    elif args.desktop:
        run_desktop_app()
    else:
        run_app(debug=args.debug)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
