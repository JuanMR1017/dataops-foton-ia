# PostgreSQL

## 1. ¿Qué es?
PostgreSQL es un sistema de gestión de bases de datos relacional, de código abierto, conocido por su robustez y su soporte nativo para replicación — justo la característica que necesitamos para la Alta Disponibilidad.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Es donde se guarda de forma permanente toda la telemetría de los sensores (nivel de agua, calidad, timestamps) para análisis histórico, además de la configuración de dispositivos de ChirpStack. Si se pierde esta base de datos, se pierde el historial completo del proyecto.

## 3. Conceptos básicos
* **Primary (Primario):** El nodo que acepta escrituras (VM1).
* **Standby / Replica:** El nodo que recibe una copia continua de los cambios del primario, en modo solo lectura (VM2).
* **WAL (Write-Ahead Log):** El registro de todas las transacciones antes de aplicarse — es lo que se envía al standby para mantenerlo sincronizado.
* **Streaming Replication:** El mecanismo por el cual el standby recibe el WAL casi en tiempo real, en lugar de esperar copias completas periódicas.
* **Replication Slot:** Un mecanismo que evita que el primario borre WAL que el standby aún no ha recibido.

## 4. Sistema de archivos / Estructura
* `/etc/postgresql/<versión>/main/postgresql.conf`: configuración general del servidor.
* `/etc/postgresql/<versión>/main/pg_hba.conf`: reglas de quién puede conectarse y cómo se autentica.
* `/var/lib/postgresql/<versión>/main/`: los archivos reales de datos.
* `standby.signal`: archivo vacío que, si existe en el directorio de datos, le dice a Postgres "arranca en modo standby".

## 5. Usuarios y permisos
PostgreSQL maneja sus propios roles internos (`CREATE ROLE`, `GRANT`), independientes de los usuarios del sistema operativo. Para la replicación se crea un rol específico con el privilegio `REPLICATION` (ej. `repl_user`).

## 6. Procesos
El proceso principal (`postgres`) lanza procesos hijos por cada conexión, además de procesos internos como el `walsender` (en el primario, envía el WAL) y el `walreceiver` (en el standby, lo recibe).

## 7. Servicios
```bash
systemctl status postgresql
systemctl restart postgresql
pg_lsclusters        # (Debian/Ubuntu) lista los clústeres de Postgres instalados
```

## 8. Red
* **Puerto 5432:** conexiones normales y tráfico de replicación streaming (usa el mismo puerto).
* `pg_hba.conf` debe permitir explícitamente la IP de VM2 con el método de autenticación de replicación.

## 9. Acceso / SSH
La administración se hace por SSH a la VM, y luego con el cliente `psql` para interactuar con la base de datos: `psql -U usuario -d nombre_bd -h localhost`.

## 10. Logs
* `/var/log/postgresql/postgresql-<versión>-main.log`: errores de conexión, consultas lentas, y el estado de la replicación.
* Ver retraso de replicación desde el primario: `SELECT * FROM pg_stat_replication;`

## 11. Bash / Scripting
Crear la copia base inicial para levantar el standby (VM2) desde el primario (VM1):
```bash
pg_basebackup -h <IP_VM1> -D /var/lib/postgresql/16/main -U repl_user -P -R
```
El flag `-R` genera automáticamente la configuración de conexión al primario.

## 12. Comandos fundamentales
* `psql -U usuario -d bd`: entra a la consola interactiva.
* `\l`: lista bases de datos. `\dt`: lista tablas.
* `SELECT pg_is_in_recovery();`: `true` si el nodo es un standby.
* `SELECT * FROM pg_stat_replication;`: estado de los standbys conectados (ejecutar en el primario).
* `pg_ctl status`: estado del servidor.

## 13. Prácticas
1. Instala PostgreSQL en dos VMs de prueba.
2. Crea el usuario de replicación en la VM "primario".
3. Usa `pg_basebackup` para clonar los datos hacia la VM "standby".
4. Verifica con `pg_is_in_recovery()` que el standby quedó en modo réplica.

## 14. Errores frecuentes
* **`pg_hba.conf` sin la regla de replicación:** el standby no logra conectarse al primario.
* **Espacio en disco lleno por WAL acumulado:** ocurre si el standby se cae y el primario no puede purgar el WAL pendiente.
* **Reloj desincronizado entre nodos:** puede generar confusión en los timestamps de los datos replicados.

## 15. Troubleshooting
1. ¿El servicio está corriendo en ambos nodos? (`systemctl status postgresql`).
2. ¿Hay conectividad de red al puerto 5432? (`nc -zv <IP> 5432`).
3. ¿Qué dice `pg_stat_replication` en el primario?
4. ¿Qué dice el log del standby sobre el `walreceiver`?

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
La Streaming Replication es lo que mantiene a VM2 con una copia casi idéntica y actualizada de los datos de VM1 en todo momento. Cuando ocurra un failover (Módulo 08, con Patroni/repmgr), el standby se "promueve" a primario y empieza a aceptar escrituras, sin haber perdido la telemetría reciente.

## 17. Documentación oficial
* [PostgreSQL Docs - High Availability](https://www.postgresql.org/docs/current/high-availability.html)
* [PostgreSQL Docs - Streaming Replication](https://www.postgresql.org/docs/current/warm-standby.html#STREAMING-REPLICATION)

## 18. Checklist
- [ ] Entiendo la diferencia entre primario y standby.
- [ ] Sé qué es el WAL y por qué es la base de la replicación.
- [ ] Sé usar `pg_basebackup` para clonar datos hacia un standby.
- [ ] Sé verificar el estado de la replicación con `pg_stat_replication`.

➡️ **[Ir a Redis](./redis.md)**
