# Solución de Problemas Comunes en GymManager

Este documento describe problemas comunes que pueden surgir al instalar o ejecutar GymManager y sus soluciones.

## Errores de Dependencias

### Error: "cannot import name 'url_decode' from 'werkzeug.urls'"

Este error ocurre cuando hay incompatibilidades entre las versiones de Flask y Werkzeug.

**Solución:**

1. Descargue y ejecute el [solucionador de dependencias](https://raw.githubusercontent.com/alesierraalta/AppClasesO2/main/scripts/windows/solucionar_dependencias.bat)

2. O instale manualmente versiones compatibles:
   ```
   pip uninstall -y werkzeug flask flask-login flask-sqlalchemy flask-wtf
   pip install werkzeug==2.3.7
   pip install flask==2.3.3 flask-login==0.6.2 flask-sqlalchemy==3.1.1 flask-wtf==1.2.1
   ```

## Problemas con Python 3.11+

GymManager funciona mejor con Python 3.8, 3.9 o 3.10. Las versiones más recientes pueden causar problemas con algunas dependencias.

**Solución:**

1. Instale una versión anterior de Python (3.8, 3.9 o 3.10)
2. O utilice el [Instalador Simple](https://raw.githubusercontent.com/alesierraalta/AppClasesO2/main/scripts/windows/instalar_simple.bat) que está diseñado para ser más compatible

## Errores en la Base de Datos

Si encuentra errores relacionados con la base de datos:

**Solución:**

1. Verifique que tiene permisos de escritura en la carpeta `C:\GymManager`
2. Ejecute el comando de configuración de la base de datos:
   ```
   cd C:\GymManager
   python main.py --setup-db
   ```
3. Si continúa teniendo problemas, inicie con la opción para resetear la base de datos:
   ```
   cd C:\GymManager
   python main.py --reset-db
   ```
   **Nota**: Esta opción eliminará todos los datos existentes.

## Problemas con el Inicio Automático

Si la aplicación no inicia correctamente o se cierra inmediatamente:

**Solución:**

1. Intente ejecutar la aplicación desde la línea de comandos para ver los errores:
   ```
   cd C:\GymManager
   python main.py
   ```
2. Verifique que todas las dependencias estén instaladas:
   ```
   cd C:\GymManager
   pip install -r requirements.txt
   ```

## Recursos Adicionales

Si continúa teniendo problemas:

1. Consulte la [documentación detallada de instalación](INSTALACION.md)
2. Realice una instalación limpia utilizando el [Instalador Simple](https://raw.githubusercontent.com/alesierraalta/AppClasesO2/main/scripts/windows/instalar_simple.bat)
3. Si es un problema específico de Mac, consulte la [guía para Mac](README_MAC.md) 