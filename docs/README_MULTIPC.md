# Configuración de GymManager en Múltiples Equipos

GymManager está diseñado para funcionar en una red con múltiples computadoras, permitiendo que todas se sincronicen entre sí.

## Arquitectura

La configuración consiste en:

- **PC1 (Servidor)**: Actúa como servidor central y almacena la base de datos principal
- **PC2/PC3 (Clientes)**: Se sincronizan con el servidor para mantener los datos actualizados

## Requisitos

1. Todas las computadoras deben estar en la misma red local
2. La PC1 (servidor) debe tener una IP fija en la red local
3. Los puertos 5000 (web) y 8000 (sincronización) deben estar permitidos en el firewall

## Instrucciones de Configuración

### Configuración de PC1 (Servidor)

1. Instale GymManager en la PC que será el servidor principal
2. Ejecute el script de configuración: `scripts/windows/setup_pc.bat`
3. Seleccione la opción "1" cuando se pregunte qué PC es esta
4. Complete la configuración siguiendo las instrucciones en pantalla
5. Al finalizar, inicie la aplicación con `python main.py` o el ejecutable

### Configuración de PC2/PC3 (Clientes)

1. Instale GymManager en las PCs secundarias
2. Ejecute el script de configuración: `scripts/windows/setup_pc.bat`
3. Seleccione la opción "2" o "3" según corresponda
4. Ingrese la dirección IP de la PC1 (servidor) cuando se solicite
5. Complete la configuración siguiendo las instrucciones en pantalla
6. Al finalizar, inicie la aplicación con `python main.py` o el ejecutable

## Importante

- La PC1 (servidor) debe estar siempre encendida y con GymManager en ejecución para que las demás PCs puedan sincronizarse
- Si cambia la IP de la PC1, deberá reconfigurar todas las PCs secundarias
- Las PCs secundarias pueden funcionar temporalmente sin conexión, pero deberán sincronizarse eventualmente

## Proceso de Sincronización

La sincronización ocurre automáticamente:

1. Al iniciar la aplicación en las PCs secundarias
2. Cada 5 minutos durante la operación normal
3. Al realizar cambios importantes en la base de datos

## Solución de Problemas

Si tiene problemas con la sincronización:

1. Verifique que la PC1 esté encendida y ejecutando GymManager
2. Confirme que todas las PCs estén en la misma red
3. Verifique la configuración de firewall para permitir conexiones en los puertos 5000 y 8000
4. Ejecute nuevamente el script de configuración si es necesario actualizar la IP del servidor

## Respaldo y Recuperación

Antes de cada sincronización, se crea automáticamente un respaldo de la base de datos. Estos respaldos se almacenan en:

- Modo script: `backups/`
- Modo ejecutable: `data/backups/`

En caso de corrupción de datos, puede restaurar desde estos respaldos.

## Archivos de Configuración

Los archivos de configuración se encuentran en:

- Modo script: `app/core/`
- Modo ejecutable: `data/config/`

Los archivos principales son:
- `pc_config.json`: Configuración de esta PC
- `network_config.json`: Configuración de red (solo en PCs secundarias) 