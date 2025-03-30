# Guía de Instalación de GymManager

Esta guía proporciona diferentes métodos para instalar GymManager según tus necesidades.

## Método 1: Instalación Automática (recomendado)

Este método es el más sencillo y requiere solo Python instalado previamente.

1. Descarga el archivo `scripts/windows/instalar_automatico.bat` desde el repositorio
2. Ejecuta el archivo haciendo doble clic
3. Sigue las instrucciones en pantalla

El script realizará automáticamente:
- Descarga del repositorio completo
- Instalación de dependencias
- Configuración de la base de datos
- Creación de acceso directo en el escritorio

## Método 2: Instalación Manual con Python 

Si prefieres controlar cada paso del proceso, sigue estas instrucciones:

1. **Instala Python (si no lo tienes):**
   - Descarga Python desde [python.org](https://www.python.org/downloads/) (versión 3.8 o superior)
   - Durante la instalación, marca la opción "Add Python to PATH"

2. **Descarga el código fuente:**
   - Ve a https://github.com/alesierraalta/AppClasesO2
   - Haz clic en "Code" y luego en "Download ZIP"
   - Extrae el ZIP en C:\GymManager

3. **Configura la aplicación:**
   - Abre CMD (Símbolo del sistema)
   - Ejecuta estos comandos:
   ```
   cd C:\GymManager
   python -m pip install -r requirements.txt
   python main.py --setup-db
   ```

4. **Crea un lanzador:**
   - Crea un archivo llamado `GymManager.bat` con este contenido:
   ```
   @echo off
   cd /d C:\GymManager
   python main.py
   pause
   ```
   - Coloca este archivo en el escritorio

## Método 3: Instalación en Red Multi-PC

Para configurar GymManager en múltiples computadoras de una red:

1. Instala la aplicación en cada computadora usando el Método 1 o 2
2. En cada PC, ejecuta el script de configuración:
   ```
   cd C:\GymManager
   scripts\windows\setup_pc.bat
   ```
3. Sigue las instrucciones en pantalla:
   - Para la PC principal, selecciona PC1 (servidor)
   - Para las PCs secundarias, selecciona PC2 o PC3 (clientes)
   - En las PCs secundarias, introduce la IP de la PC principal cuando se solicite

Para más detalles sobre la configuración multi-PC, consulta [Configuración Multi-PC](README_MULTIPC.md).

## Requisitos de Sistema

- **Sistema Operativo:** Windows 7, 8, 10 o 11
- **Python:** Versión 3.8 o superior
- **Espacio en disco:** Mínimo 500 MB
- **Memoria RAM:** Mínimo 4 GB recomendado
- **Conectividad:** Conexión a Internet para la instalación

## Solución de Problemas

### Python no está instalado
Si ves el mensaje "No se encontró Python", debes instalar Python:
1. Descarga el instalador desde [python.org](https://www.python.org/downloads/)
2. Ejecuta el instalador y ASEGÚRATE de marcar "Add Python to PATH"
3. Reinicia el equipo
4. Vuelve a intentar la instalación

### Error al instalar dependencias
Si ves errores relacionados con la instalación de dependencias:
1. Verifica tu conexión a Internet
2. Ejecuta el siguiente comando: `python -m pip install --upgrade pip`
3. Intenta instalar manualmente las dependencias: `pip install flask sqlalchemy`

### Problemas de sincronización entre PCs
Si tienes problemas con la sincronización entre equipos:
1. Verifica que todas las PCs estén encendidas y conectadas a la misma red
2. Ejecuta el script de diagnóstico: `scripts\windows\test_pc_config.bat`
3. Asegúrate de que el firewall permita conexiones en los puertos 5000 y 8000 