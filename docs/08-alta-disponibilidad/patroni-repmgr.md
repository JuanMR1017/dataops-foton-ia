# Patroni / repmgr (Failover automático de PostgreSQL)

## 1. ¿Qué es?
Son herramientas de orquestación para PostgreSQL que automatizan lo que en el Módulo 07 se hizo manualmente: detectar que el primario cayó y **promover** el standby a primario sin intervención humana. Patroni usa un almacén de configuración distribuido (ej. etcd) para el consenso; repmgr usa su propio demonio (`repmgrd`) con votación entre nodos.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
La replicación por sí sola (Módulo 07) mantiene los datos sincronizados, pero **alguien tiene que decidir** cuándo el standby debe dejar de ser solo-lectura y aceptar escrituras. Sin esta pieza, un operador humano tendría que promover la base de datos manualmente cada vez que VM1 falle — lo que rompe el objetivo de "Alta Disponibilidad automática".

## 3. Conceptos básicos
* **Failover:** La promoción automática de un standby a primario cuando el primario original falla.
* **Switchover:** Una promoción planeada (para mantenimiento), no por una falla.
* **Quórum:** El número mínimo de nodos que deben estar de acuerdo para tomar una decisión — por eso VM3 existe: con solo VM1 y VM2, un empate 1-1 es imposible de resolver; con VM3 como tercer voto, siempre hay mayoría.
* **DCS (Distributed Configuration Store):** El almacén (ej. etcd) donde Patroni guarda de forma consistente quién es el líder actual.
* **Fencing / STONITH:** Mecanismos para asegurarse de que el primario "caído" realmente deje de aceptar escrituras antes de promover al standby (evita que ambos acepten escrituras a la vez).

## 4. Sistema de archivos / Estructura
* Patroni: `/etc/patroni/patroni.yml` (config por nodo) + el DCS externo (etcd suele guardar sus datos en `/var/lib/etcd/`).
* repmgr: `/etc/repmgr.conf` por nodo, y una tabla de metadatos propia dentro de la base de datos (`repmgr.nodes`, etc.).

## 5. Usuarios y permisos
Ambas herramientas necesitan un usuario de PostgreSQL con privilegios de superusuario o de replicación para poder promover/degradar el rol de un nodo (`ALTER SYSTEM`, `pg_promote()`).

## 6. Procesos
* Patroni corre como un demonio (`patroni`) por nodo, que a su vez controla el proceso de PostgreSQL (lo arranca, detiene o reconfigura según lo que decida el líder del clúster).
* repmgr corre `repmgrd` como demonio de monitoreo en cada nodo.

## 7. Servicios
```bash
# Patroni
systemctl status patroni
patronictl -c /etc/patroni/patroni.yml list

# repmgr
systemctl status repmgrd
repmgr cluster show
```

## 8. Red
Patroni expone una API REST (por defecto puerto 8008) para consultar el estado del clúster y para que un balanceador identifique al líder. repmgr no expone puerto propio adicional; usa la conexión normal de PostgreSQL (5432) entre nodos.

## 9. Acceso / SSH
La administración se hace por SSH a cada nodo, pero el estado del **clúster completo** se consulta con las herramientas de línea de comandos (`patronictl`, `repmgr cluster show`) desde cualquier nodo con acceso a la configuración compartida.

## 10. Logs
* Patroni: `journalctl -u patroni -f` — muestra elecciones de líder y transiciones de estado.
* repmgr: `/var/log/repmgr/repmgrd.log`.

## 11. Bash / Scripting
Consultar quién es el líder actual del clúster (ejemplo con Patroni):
```bash
patronictl -c /etc/patroni/patroni.yml list
```
Forzar un switchover planeado (mantenimiento, no una emergencia):
```bash
patronictl -c /etc/patroni/patroni.yml switchover
```

## 12. Comandos fundamentales
* `patronictl list`: muestra el rol y estado de cada nodo del clúster.
* `patronictl switchover`: promueve manualmente a otro nodo (mantenimiento planeado).
* `repmgr cluster show`: equivalente en repmgr.
* `repmgr node check`: valida la salud de replicación de un nodo.

## 13. Prácticas
1. Instala Patroni (o repmgr) en un laboratorio de 3 nodos.
2. Verifica con `patronictl list` quién es el líder actual.
3. Apaga el servicio de PostgreSQL en el líder y observa cómo el clúster elige un nuevo líder automáticamente.
4. Confirma en los logs qué pasos siguió la herramienta para decidir el failover.

## 14. Errores frecuentes
* **DCS (etcd) caído o inaccesible:** Patroni no puede tomar decisiones de liderazgo con seguridad y puede bloquear el clúster para evitar un split-brain.
* **Solo 2 nodos configurados para el quórum:** un empate deja al clúster sin poder decidir — por eso el nodo testigo (VM3) es obligatorio.
* **Reloj desincronizado entre nodos:** puede afectar los tiempos de espera (`timeouts`) usados para declarar un nodo como caído.

## 15. Troubleshooting
1. ¿El DCS (etcd) está sano y accesible desde los 3 nodos? (para Patroni).
2. ¿Qué dice `patronictl list` / `repmgr cluster show` sobre el estado actual?
3. ¿Los logs muestran una elección de líder reciente? ¿Por qué se disparó?
4. ¿La replicación de streaming (Módulo 07) estaba sana antes del failover?

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Esta es la pieza que **decide** el failover de la base de datos; Keepalived es la pieza que **ejecuta** el cambio de IP. En un evento real: VM1 falla → Patroni/repmgr detecta la caída con el voto de VM3 → promueve a VM2 como nuevo primario → el `track_script` de Keepalived en VM2 detecta que su PostgreSQL local ya es primario y reclama la VIP.

## 17. Documentación oficial
* [Patroni Official Documentation](https://patroni.readthedocs.io/)
* [repmgr Official Documentation](https://www.repmgr.org/docs/current/index.html)

## 18. Checklist
- [ ] Entiendo la diferencia entre failover y switchover.
- [ ] Entiendo por qué se necesita un tercer nodo (quórum impar) para decidir sin ambigüedad.
- [ ] Sé consultar el estado del clúster con `patronictl` o `repmgr cluster show`.
- [ ] Entiendo cómo esta herramienta se coordina con Keepalived durante un failover real.

➡️ **[Ir a Redis Sentinel](./redis-sentinel.md)**
