# Redis

## 1. ¿Qué es?
Redis es una base de datos en memoria (in-memory), extremadamente rápida, usada como caché o almacén de estructuras de datos temporales — a diferencia de PostgreSQL, que persiste en disco como fuente de verdad histórica.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Se usa para guardar la **última lectura conocida** de cada sensor con acceso casi instantáneo (útil para dashboards en vivo), y para datos de sesión/estado interno de los servicios, sin sobrecargar a PostgreSQL con consultas repetitivas de datos que cambian a cada segundo.

## 3. Conceptos básicos
* **Master:** El nodo que acepta escrituras (VM1).
* **Replica:** El nodo que recibe una copia continua del master, normalmente solo lectura (VM2).
* **Persistencia RDB:** Guarda "fotos" periódicas completas de la memoria a disco.
* **Persistencia AOF (Append Only File):** Guarda cada operación de escritura en un log, permitiendo una recuperación más precisa tras un reinicio.
* **Replicación asíncrona:** El master no espera confirmación de la réplica antes de responder al cliente — es rápido, pero puede perder el último segundo de datos si el master cae de forma abrupta.

## 4. Sistema de archivos / Estructura
* `/etc/redis/redis.conf`: archivo principal de configuración.
* `/var/lib/redis/`: donde se guardan los archivos de persistencia (`dump.rdb`, `appendonly.aof`).

## 5. Usuarios y permisos
Redis moderno soporta ACLs (`ACL SETUSER`) para crear usuarios con permisos limitados a ciertos comandos o topics de claves. Como mínimo, siempre se debe configurar `requirepass` para exigir contraseña.

## 6. Procesos
El proceso `redis-server` es single-threaded para el procesamiento de comandos (por diseño, para evitar condiciones de carrera), lo que lo hace simple de razonar pero significa que un solo comando muy pesado puede bloquear momentáneamente al resto.

## 7. Servicios
```bash
systemctl status redis-server
systemctl restart redis-server
```

## 8. Red
* **Puerto 6379:** puerto por defecto para clientes y para la replicación master-replica.
* Se recomienda que este puerto **nunca** esté expuesto directamente a Internet.

## 9. Acceso / SSH
La administración se hace por SSH y luego con el cliente `redis-cli`: `redis-cli -h <IP> -p 6379 -a <contraseña>`.

## 10. Logs
* Ruta configurada por `logfile` en `redis.conf` (por defecto puede ir a syslog).
* `journalctl -u redis-server -f`.

## 11. Bash / Scripting
Configurar una réplica apuntando al master (puede hacerse en caliente o en `redis.conf`):
```bash
redis-cli -h <IP_VM2> REPLICAOF <IP_VM1> 6379
```
Para revertir un nodo a master independiente: `redis-cli REPLICAOF NO ONE`.

## 12. Comandos fundamentales
* `redis-cli`: consola interactiva.
* `PING`: verifica que el servidor responde.
* `INFO replication`: muestra el rol (master/slave) y el estado de sincronización.
* `SET clave valor` / `GET clave`: operaciones básicas.
* `MONITOR`: observa en vivo todos los comandos que llegan (solo para depuración, es costoso en producción).

## 13. Prácticas
1. Instala Redis en dos VMs de prueba.
2. Configura una como master y la otra como replica con `REPLICAOF`.
3. Escribe un valor en el master (`SET`) y verifica que aparece en la replica (`GET`).
4. Revisa `INFO replication` en ambos nodos.

## 14. Errores frecuentes
* **Réplica que nunca sincroniza:** contraseña (`masterauth`) no configurada o distinta a la del master.
* **Pérdida de datos tras un reinicio:** no se configuró persistencia RDB/AOF.
* **Exponer Redis sin contraseña:** riesgo de seguridad crítico si el puerto es alcanzable desde fuera del clúster.

## 15. Troubleshooting
1. ¿El servicio está corriendo? (`systemctl status redis-server`).
2. ¿Hay conectividad al puerto 6379? (`redis-cli -h <IP> ping`).
3. ¿Qué dice `INFO replication`?
4. ¿El log muestra errores de autenticación o de red?

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Redis por sí solo no decide automáticamente cuándo promover una réplica a master — eso lo hace **Redis Sentinel**, que se estudia en el Módulo 08 junto con el resto del quórum. Este módulo cubre la base (replicación); el Módulo 08 cubre la automatización del failover.

## 17. Documentación oficial
* [Redis Docs - Replication](https://redis.io/docs/latest/operate/oss_and_stack/management/replication/)
* [Redis Docs - Persistence](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/)

## 18. Checklist
- [ ] Entiendo la diferencia entre master y replica en Redis.
- [ ] Sé configurar una replicación básica con `REPLICAOF`.
- [ ] Entiendo la diferencia entre persistencia RDB y AOF.
- [ ] Sé revisar el estado de replicación con `INFO replication`.

➡️ **[Ir al Módulo 08 - Alta Disponibilidad](../08-alta-disponibilidad/README.md)**
