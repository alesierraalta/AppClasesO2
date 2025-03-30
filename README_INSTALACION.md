# Guía de Instalación y Configuración Automática de GymManager

Esta guía explica cómo usar los scripts de automatización para instalar y configurar GymManager en todas las computadoras del gimnasio.

## Requisitos Previos

1. Python 3.8 o superior instalado en todas las computadoras
2. Todas las computadoras deben estar conectadas a la misma red local
3. El Firewall de Windows debe permitir conexiones en el puerto 5000

## Scripts Disponibles

Este paquete incluye los siguientes scripts de automatización:

- **instalar_gymmanager.bat**: Instala y configura GymManager de forma completa
- **setup_network.bat**: Configura la sincronización entre computadoras
- **verificar_red.bat**: Verifica la conectividad entre las computadoras
- **administrar.bat**: Panel de control para administrar GymManager
- **build_app.bat**: Compila la aplicación en un ejecutable

## Proceso de Instalación (Paso a Paso)

### 1. Instalación Completa

Para realizar una instalación completa y guiada:

1. Copie todos los archivos a una carpeta en cada computadora
2. Ejecute **instalar_gymmanager.bat** en cada computadora
3. Siga las instrucciones en pantalla

Este script guiado:
- Detecta automáticamente la IP de la computadora
- Configura el rol (Gerencia o Recepción)
- Instala todas las dependencias
- Compila la aplicación
- Crea un acceso directo en el escritorio

### 2. Configuración de Red

Si necesita reconfigurar la red después de la instalación:

1. Ejecute **setup_network.bat** en cada computadora
2. Seleccione el tipo de computadora:
   - 1: Principal (Gerencia - solo debe haber una)
   - 2: Recepción 1
   - 3: Recepción 2
3. Ingrese las IPs correctas de las tres computadoras

### 3. Verificación de Conectividad

Para verificar que todas las computadoras puedan comunicarse:

1. Asegúrese de que todas las computadoras estén encendidas
2. Ejecute GymManager en cada computadora
3. Ejecute **verificar_red.bat** para comprobar la conectividad

### 4. Administración del Sistema

El script **administrar.bat** proporciona un panel de control para:

- Iniciar GymManager
- Verificar estado de la red
- Configurar sincronización
- Ver logs y diagnósticos
- Forzar sincronización manual
- Realizar respaldos de la base de datos
- Restaurar la base de datos desde respaldos

## Resolución de Problemas

### Problemas de Conectividad

Si hay problemas de conectividad:

1. Ejecute **verificar_red.bat** para diagnosticar
2. Asegúrese de que las IPs en sync_config.json sean correctas
3. Verifique que el Firewall permita conexiones en el puerto 5000

Para permitir conexiones en el Firewall de Windows:
```
1. Abra el Panel de control > Sistema y seguridad > Firewall de Windows
2. Haga clic en "Configuración avanzada"
3. Seleccione "Reglas de entrada" > "Nueva regla"
4. Elija "Puerto", haga clic en "Siguiente"
5. Seleccione "TCP" y escriba "5000" en "Puertos locales específicos"
6. Complete el asistente permitiendo la conexión
```

### Problemas de Sincronización

Si la sincronización no funciona:

1. Asegúrese de que solo una computadora esté configurada como principal
2. Verifique que la aplicación esté en ejecución en todas las computadoras
3. Use la opción "Forzar sincronización manual" en el panel de administración

## Notas Importantes

- La computadora principal (Gerencia) debe estar encendida para garantizar sincronización completa
- Realice respaldos regulares de la base de datos usando el panel de administración
- Si cambia la configuración de red, ejecute setup_network.bat en todas las computadoras

Para más información sobre la aplicación, consulte el archivo README_SYNC.md 