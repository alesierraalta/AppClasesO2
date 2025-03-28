# AppClasesO2

Sistema de gestión de clases para gimnasios y estudios fitness. Permite la administración de profesores, horarios, asistencia y generación de informes.

## Características

- Gestión de profesores y sus tarifas
- Creación y modificación de horarios de clases
- Registro de asistencia y puntualidad de profesores
- Conteo de alumnos por clase
- Cálculo automático de pagos (con reglas de negocio como reducción del 50% de tarifa cuando un profesor asiste pero no tiene alumnos)
- Generación de informes mensuales
- Exportación de datos a Excel
- Sistema de notificaciones
- Grabación de audio asociado a clases

## Requisitos

- Python 3.7+
- Flask
- SQLAlchemy
- Otras dependencias en requirements.txt

## Instalación

1. Clonar el repositorio:
```
git clone https://github.com/alesierraalta/AppClasesO2.git
cd AppClasesO2
```

2. Crear entorno virtual:
```
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
```

3. Instalar dependencias:
```
pip install -r requirements.txt
```

4. Configurar variables de entorno (opcional):
```
cp .env.example .env
# Editar .env con tus configuraciones
```

5. Iniciar la aplicación:
```
python app.py
```

## Estructura del Proyecto

- `app.py`: Aplicación principal Flask
- `models.py`: Modelos de datos
- `notifications.py`: Sistema de notificaciones
- `templates/`: Plantillas HTML
- `static/`: Archivos estáticos (CSS, JS, imágenes)
- `tests/`: Pruebas unitarias y de integración

## Licencia

Este proyecto es privado y está desarrollado para uso exclusivo del propietario. 