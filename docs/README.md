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

## Instalación Rápida

### Windows

Para instalar rápidamente en Windows, descargue y ejecute uno de estos scripts:

- [Instalador completo](https://raw.githubusercontent.com/alesierraalta/AppClasesO2/main/scripts/windows/instalar_desde_github.bat) - Instalación con todas las funcionalidades
- [Instalador simple](https://raw.githubusercontent.com/alesierraalta/AppClasesO2/main/scripts/windows/instalar_simple.bat) - Versión simplificada compatible con todas las versiones de Python

### Actualización

Para actualizar una instalación existente:

- [Script de actualización](https://raw.githubusercontent.com/alesierraalta/AppClasesO2/main/scripts/windows/actualizar_desde_github.bat)

## Instalación Manual

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
python app/core/app.py
```

## Estructura del Proyecto

- `app/core/`: Aplicación principal Flask
- `app/models/`: Modelos de datos
- `app/utils/`: Utilidades y funciones auxiliares
- `app/routes/`: Rutas de la aplicación
- `templates/`: Plantillas HTML
- `static/`: Archivos estáticos (CSS, JS, imágenes)
- `tests/`: Pruebas unitarias y de integración
- `docs/`: Documentación adicional

## Documentación

Para obtener más información, consulte:

- [Guía de instalación detallada](docs/INSTALACION.md)
- [Configuración para múltiples PCs](docs/README_MULTIPC.md)
- [Guía para Mac](docs/README_MAC.md)

## Licencia

Este proyecto es privado y está desarrollado para uso exclusivo del propietario. 