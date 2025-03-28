@echo off
echo Iniciando entorno virtual...
if not exist venv (
    echo Creando entorno virtual...
    python -m venv venv
)

:: Activar el entorno virtual
call venv\Scripts\activate

:: Establecer variables de entorno
set FLASK_APP=app.py
set FLASK_ENV=development
:: NO MODIFICAR MANUALMENTE - ESTE VALOR SE ACTUALIZARÁ AUTOMÁTICAMENTE
set NOTIFICATION_PHONE_NUMBER=+584244461682
:: Nota: Reemplazar +numero_a_notificar_aqui con el número completo incluyendo el código del país
:: por ejemplo: +56912345678 para Chile o +34612345678 para España (sin espacios)

echo Instalando dependencias...
pip install -r requirements.txt

echo Iniciando la aplicación...
:: No eliminamos la base de datos para mantener persistencia
:: del gimnasio.db
:: flask init-db

echo Iniciando la aplicación...
flask run