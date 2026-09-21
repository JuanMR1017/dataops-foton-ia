# 🖥️ VM1 - Nodo Principal (Activo)

Este documento define las herramientas que operarán en esta máquina virtual y los conocimientos técnicos que el **Grupo 1** debe adquirir antes de pasar a la fase de implementación.

## 🛠️ 1. Herramientas y Servicios Asignados
Estas son las tecnologías que vivirán en este nodo. 

| Servicio | Función en el Nodo | Documentación Oficial Verificada |
| :--- | :--- | :--- |
| **Keepalived** | Gestión de la IP Virtual (VIP) como nodo MASTER. | [Keepalived Official Docs](https://keepalived.readthedocs.io/en/latest/) |
| **PostgreSQL** | Base de datos principal (Primary) para almacenamiento. | [PostgreSQL Docs](https://www.postgresql.org/docs/) |
| **Redis** | Base de datos en memoria (Master) para caché rápido. | [Redis Docs (Latest)](https://redis.io/docs/latest/) |
| **Mosquitto** | Broker MQTT principal para ingesta de datos. | [Mosquitto Docs](https://mosquitto.org/documentation/) |
| **ChirpStack** | Servidor LoRaWAN activo para recibir telemetría. | [ChirpStack Docs](https://www.chirpstack.io/docs/) |

## 🧠 2. Conocimientos Específicos Requeridos
Para administrar este nodo con éxito, el grupo debe enfocarse en estudiar:

* **Administración Básica de Linux:** Manejo de servicios (`systemctl`), revisión de logs y configuración de red estática.
* **Modelo Publicador/Suscriptor (MQTT):** Entender cómo los sensores enviarán datos al broker local.
* **Bases de Datos (Nivel 1):** Instalación, creación de usuarios, asignación de permisos y configuración de accesos remotos en PostgreSQL y Redis.
* **Concepto de IP Virtual:** Comprender qué es una VIP y cómo Keepalived permite que esta IP "flote" entre servidores.

## 🚀 3. Próximos Pasos
Los archivos de configuración de referencia para esta fase ya están disponibles en [`config/`](./config/):

| Herramienta | Archivo |
| :--- | :--- |
| Keepalived (MASTER) | [`config/keepalived/keepalived.conf`](./config/keepalived/keepalived.conf) |
| PostgreSQL (Primary) | [`config/postgresql/`](./config/postgresql/) |
| Redis (Master) | [`config/redis/redis.conf.snippet`](./config/redis/redis.conf.snippet) |
| Redis Sentinel | [`config/redis-sentinel/sentinel.conf`](./config/redis-sentinel/sentinel.conf) |
| Patroni | [`config/postgresql/patroni.yml.example`](./config/postgresql/patroni.yml.example) |
| Mosquitto | [`config/mosquitto/mosquitto.conf`](./config/mosquitto/mosquitto.conf) |
| ChirpStack (Docker) | [`config/chirpstack/docker-compose.yml`](./config/chirpstack/docker-compose.yml) |

⚠️ Todos estos archivos son puntos de partida educativos: antes de aplicarlos, **ajusta las IPs, interfaces de red y contraseñas marcadas con `AJUSTAR`/`CAMBIAR_ESTA_CLAVE`** a los valores reales del clúster Proxmox.
