# Redis Sentinel

## 1. ¿Qué es?
Redis Sentinel es un sistema de monitoreo y failover automático para Redis: un grupo de procesos Sentinel vigila constantemente al master y a las réplicas, y si detectan (por consenso, no un solo Sentinel) que el master cayó, promueven automáticamente una réplica.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Redis por sí mismo (Módulo 07) no decide failovers — solo replica datos. Sentinel es el "cerebro" que decide cuándo la réplica de VM2 debe convertirse en el nuevo master si el de VM1 deja de responder.

## 3. Conceptos básicos
* **Sentinel:** Un proceso independiente (no es el mismo proceso que Redis) que monitorea uno o más grupos master-replica.
* **Quórum:** Número mínimo de Sentinels que deben coincidir en que el master está caído antes de actuar. En FOTON-IA se corre un Sentinel en cada VM (3 en total) para tener un quórum impar.
* **Elección de líder Sentinel:** Entre los Sentinels que detectan la caída, se elige a uno para ejecutar el failover real.
* **Cliente "sentinel-aware":** Una aplicación que, en lugar de conectarse directamente a una IP fija de Redis, le pregunta a Sentinel "¿quién es el master ahora?" antes de cada conexión.

## 4. Sistema de archivos / Estructura
* `/etc/redis/sentinel.conf`: configuración de qué master vigilar y con qué quórum.
* Sentinel reescribe este archivo automáticamente cada vez que ocurre un failover, para recordar quién es el nuevo master tras un reinicio.

## 5. Usuarios y permisos
Si el master de Redis tiene contraseña (`requirepass`), Sentinel necesita conocerla (`sentinel auth-pass`) para poder monitorearlo y ejecutar comandos administrativos sobre él.

## 6. Procesos
Cada nodo corre su propio proceso `redis-sentinel` (o `redis-server --sentinel`), independiente del proceso `redis-server` normal que sirve los datos.

## 7. Servicios
```bash
systemctl status redis-sentinel
systemctl restart redis-sentinel
```

## 8. Red
* **Puerto 26379:** puerto por defecto en el que escucha Sentinel (distinto del 6379 de Redis).
* Los tres Sentinels deben poder comunicarse entre sí y con el master/réplicas de Redis.

## 9. Acceso / SSH
Se administra por SSH en cada nodo. Para consultar el estado desde la terminal se usa `redis-cli` apuntando al puerto de Sentinel: `redis-cli -p 26379`.

## 10. Logs
* Ruta definida por `logfile` en `sentinel.conf`.
* `journalctl -u redis-sentinel -f`: muestra las elecciones de failover en tiempo real.

## 11. Bash / Scripting
Preguntarle a un Sentinel quién es el master actual:
```bash
redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
```

## 12. Comandos fundamentales
* `SENTINEL masters`: lista los grupos master monitoreados.
* `SENTINEL get-master-addr-by-name <nombre>`: IP y puerto del master actual.
* `SENTINEL replicas <nombre>`: lista las réplicas conocidas.
* `SENTINEL failover <nombre>`: fuerza un failover manual (para pruebas controladas).

## 13. Prácticas
1. Levanta 3 Sentinels (uno por VM de prueba) apuntando al mismo grupo master-replica de Redis.
2. Consulta el master actual con `SENTINEL get-master-addr-by-name`.
3. Detén el proceso `redis-server` del master y observa en los logs de Sentinel cómo se dispara la elección y el failover.
4. Vuelve a consultar `get-master-addr-by-name` y confirma que apunta al nuevo master.

## 14. Errores frecuentes
* **Solo 2 Sentinels configurados:** un quórum par puede generar empates que retrasan o impiden el failover — de nuevo, la razón de tener un tercer nodo (VM3).
* **`sentinel auth-pass` no configurado** cuando el master tiene contraseña: Sentinel no puede monitorear correctamente.
* **Clientes que no son "sentinel-aware":** siguen conectándose a la IP vieja del master caído y fallan silenciosamente hasta que se reconfiguran.

## 15. Troubleshooting
1. ¿Los tres Sentinels están corriendo? (`systemctl status redis-sentinel` en cada VM).
2. ¿Coinciden en quién es el master? (`SENTINEL get-master-addr-by-name` en cada uno).
3. ¿Qué dice el log sobre la última elección? (`journalctl -u redis-sentinel`).
4. ¿El nuevo master acepta escrituras? (`redis-cli -h <nueva-ip> SET test 1`).

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Redis Sentinel corre en las tres VMs (incluyendo VM3, el nodo testigo) precisamente para tener un quórum impar de 3 votos y decidir sin ambigüedad si la réplica de VM2 debe promoverse. Junto con Patroni/repmgr (PostgreSQL) y Keepalived (red), completa el trío de piezas que hacen posible un failover totalmente automático.

## 17. Documentación oficial
* [Redis Docs - Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/)

## 18. Checklist
- [ ] Entiendo qué hace Sentinel que Redis por sí solo no hace.
- [ ] Entiendo por qué se necesita un quórum impar de Sentinels.
- [ ] Sé consultar quién es el master actual con `SENTINEL get-master-addr-by-name`.
- [ ] Entiendo por qué un cliente debe ser "sentinel-aware" para sobrevivir a un failover.

➡️ **[Ir al Módulo 09 - Observabilidad](../09-observabilidad/README.md)**
