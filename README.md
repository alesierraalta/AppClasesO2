# GymManager - Sistema de Gestión para Gimnasios

GymManager es una aplicación completa para la gestión de gimnasios y academias de fitness, diseñada para facilitar el control de horarios, profesores, clases y más.

## Características Principales

- Gestión de horarios de clases
- Control de asistencia de profesores
- Registro de alumnos en clases
- Generación de informes y estadísticas
- Sincronización entre múltiples computadoras
- Interfaz fácil de usar

## Instalación Rápida (Nuevo)

1. **Descarga el instalador automático:**
   - [Descargar instalar_automatico.bat](https://raw.githubusercontent.com/alesierraalta/AppClasesO2/main/scripts/windows/instalar_automatico.bat) (clic derecho → Guardar como...)
   - Este método requiere que Python esté previamente instalado

2. **Ejecuta el instalador:**
   - Haz doble clic en el archivo descargado
   - El script descargará e instalará todo automáticamente
   - Se creará un acceso directo en el escritorio

Para métodos alternativos de instalación e instrucciones detalladas, consulta nuestra [Guía de Instalación](docs/INSTALACION.md).

## Requisitos del Sistema

- Python 3.8 o superior
- Windows 10/11 (recomendado)
- 4GB de RAM mínimo
- Conexión a internet para instalación inicial
- Red local para sincronización multi-PC

## Configuración en Múltiples Equipos

GymManager está diseñado para funcionar en una red con múltiples computadoras:

- **PC1**: Servidor principal que almacena la base de datos central
- **PC2/PC3**: Equipos secundarios que se sincronizan con el servidor

Para la configuración detallada, consulte [Configuración Multi-PC](docs/README_MULTIPC.md).

### Configuración Rápida

1. En cada PC, ejecute el script de configuración:
   ```
   scripts/windows/setup_pc.bat
   ```

2. Siga las instrucciones en pantalla para configurar cada equipo

## Estructura del Proyecto

```
GymManager/
├── app/                 # Código principal de la aplicación
│   ├── core/            # Núcleo y funcionalidad principal
│   ├── models/          # Modelos de datos
│   ├── routes/          # Rutas y controladores web
│   └── utils/           # Utilidades y helpers
├── database/            # Scripts y archivos de base de datos
├── docs/                # Documentación
├── logs/                # Archivos de registro
├── scripts/             # Scripts de utilidad
│   ├── windows/         # Scripts para Windows
│   └── mac/             # Scripts para Mac
├── static/              # Archivos estáticos (CSS, JS, imágenes)
├── templates/           # Plantillas HTML
└── tests/               # Pruebas automatizadas
```

## Uso Básico

1. Inicie la aplicación
2. Acceda con el usuario por defecto:
   - Usuario: `admin`
   - Contraseña: `admin`
3. Configure sus profesores, clases y horarios
4. Comience a registrar la asistencia diaria

## Soporte y Contacto

Si necesita ayuda o tiene preguntas:

- Consulte la [documentación completa](docs/)
- Abra un [issue en GitHub](https://github.com/tu-usuario/gymmanager/issues)
- Contacte al desarrollador: [tu-email@example.com](mailto:tu-email@example.com)

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - vea el archivo [LICENSE](LICENSE) para más detalles. 