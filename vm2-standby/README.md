# 🛡️ VM2 - Nodo Respaldo (Standby)

Este documento define las herramientas que operarán en esta máquina virtual y los conocimientos técnicos que el **Grupo 2** debe adquirir. Su misión es garantizar que este nodo esté listo para asumir toda la carga si la VM1 falla.

## 🛠️ 1. Herramientas y Servicios Asignados
Estas son las tecnologías que vivirán en este nodo de respaldo.

| Servicio | Función en el Nodo | Documentación Oficial Verificada |
| :--- | :--- | :--- |
| **Keepalived** | Espera activa de la IP Virtual (VIP) como nodo BACKUP. | [Keepalived Official Docs](https://keepalived.readthedocs.io/en/latest/) |
| **PostgreSQL** | Base de datos en modo recuperación (Standby/Replica). | [PostgreSQL HA Docs](https://www.postgresql.org/docs/current/high-availability.html) |
| **Redis** | Base de datos en memoria configurada como réplica. | [Redis Docs (Latest)](https://redis.io/docs/latest/) |
| **Mosquitto** | Broker MQTT en modo pasivo. | [Mosquitto Docs](https://mosquitto.org/documentation/) |
| **ChirpStack** | Servidor LoRaWAN en modo pasivo. | [ChirpStack Docs](https://www.chirpstack.io/docs/) |

## 🧠 2. Conocimientos Específicos Requeridos
Para administrar este nodo con éxito, el grupo debe enfocarse en estudiar:

* **Replicación de Bases de Datos:** Comprender el *streaming replication* de PostgreSQL y la sincronización maestro-esclavo de Redis.
* **Prioridades en VRRP:** Entender cómo Keepalived decide quién tiene la IP Virtual basándose en prioridades (VM1 tendrá mayor prioridad que VM2).
* **Sincronización de Estado:** Aprender cómo los brokers MQTT manejan sesiones y por qué no deben procesar datos simultáneamente con la VM1.

## 🚀 3. Próximos Pasos
Los archivos de configuración de referencia para esta fase ya están disponibles en [`config/`](./config/):

| Herramienta | Archivo |
| :--- | :--- |
| Keepalived (BACKUP) | [`config/keepalived/keepalived.conf`](./config/keepalived/keepalived.conf) |
| PostgreSQL (Standby) | [`config/postgresql/setup-standby.sh`](./config/postgresql/setup-standby.sh) |
| Redis (Replica) | [`config/redis/redis.conf.snippet`](./config/redis/redis.conf.snippet) |
| Redis Sentinel | [`config/redis-sentinel/sentinel.conf`](./config/redis-sentinel/sentinel.conf) |

⚠️ Todos estos archivos son puntos de partida educativos: antes de aplicarlos, **ajusta las IPs, interfaces de red y contraseñas marcadas con `AJUSTAR`/`CAMBIAR_ESTA_CLAVE`** a los valores reales del clúster Proxmox. `virtual_router_id`, `auth_pass` y la VIP en `keepalived.conf` deben coincidir exactamente con los de VM1.
