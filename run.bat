@echo off
echo Iniciando entorno virtual...
if not exist venv (
    echo Creando entorno virtual...
    python -m venv venv
)

:: Activar el entorno virtual
call venv\Scripts\activate

:: Establecer variables de entorno
set FLASK_APP=main.py
set FLASK_ENV=development
:: NO MODIFICAR MANUALMENTE - ESTE VALOR SE ACTUALIZARÁ AUTOMÁTICAMENTE
set NOTIFICATION_PHONE_NUMBER=+584244461682
:: Nota: Reemplazar +numero_a_notificar_aqui con el número completo incluyendo el código del país
:: por ejemplo: +56912345678 para Chile o +34612345678 para España (sin espacios)

echo Instalando dependencias...
pip install -r requirements.txt

:: No eliminamos la base de datos para mantener persistencia
:: del gimnasio.db
echo Inicializando la base de datos...
:: Intentamos diferentes opciones para crear la base de datos
python -c "try:
    from app import db as db_app, create_app 
    app = create_app()
    with app.app_context():
        db_app.create_all()
    print('Base de datos inicializada correctamente (método 1)')
except Exception as e1:
    try:
        from main import app, db
        with app.app_context():
            db.create_all()
        print('Base de datos inicializada correctamente (método 2)')
    except Exception as e2:
        try:
            import sqlite3
            conn = sqlite3.connect('gimnasio.db')
            print('Base de datos creada correctamente (método 3)')
            conn.close()
        except Exception as e3:
            print(f'Error al crear la base de datos: {e1}\\n{e2}\\n{e3}')
"

echo Iniciando la aplicación...
:: Añadimos la opción para ignorar errores y continuar
flask run --host=0.0.0.0 --port=5000 || (
    echo Ha ocurrido un error al iniciar Flask.
    echo Asegúrate de tener todas las dependencias instaladas.
    echo.
    echo Intentando método alternativo...
    python main.py
    pause
)