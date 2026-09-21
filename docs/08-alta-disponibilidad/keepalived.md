# Keepalived

## 1. ¿Qué es?
Keepalived es el software que implementa VRRP (Módulo 03) en Linux: mantiene la IP Virtual (VIP) en el nodo `MASTER` y la mueve automáticamente al nodo `BACKUP` si el `MASTER` deja de responder.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Es la pieza que hace posible que, ante una caída de VM1, los sensores y gateways sigan enviando datos a "la misma IP de siempre" sin ninguna reconfiguración manual — VM2 simplemente la reclama.

## 3. Conceptos básicos
* **`vrrp_instance`:** El bloque de configuración que define un grupo VRRP (una VIP y sus reglas).
* **`state MASTER` / `state BACKUP`:** El rol inicial de cada nodo.
* **`priority`:** Un número que decide quién gana si ambos nodos están sanos (VM1 debe tener prioridad más alta que VM2).
* **`virtual_router_id`:** Identifica el grupo VRRP; debe ser el mismo en VM1 y VM2, y único en la red si hay otros clústeres VRRP.
* **`track_script`:** Un script personalizado que Keepalived ejecuta periódicamente para decidir si el nodo sigue "sano" (ej. verificar que PostgreSQL responde).

## 4. Sistema de archivos / Estructura
* `/etc/keepalived/keepalived.conf`: archivo único de configuración.
* `/etc/keepalived/scripts/`: convención común para guardar los `track_script` personalizados.

## 5. Usuarios y permisos
Keepalived necesita correr con privilegios para manipular interfaces de red (asignar/quitar la VIP), por lo que su proceso corre como `root`.

## 6. Procesos
El demonio `keepalived` corre de forma continua, enviando (si es MASTER) o escuchando (si es BACKUP) anuncios VRRP cada `advert_int` segundos por la red.

## 7. Servicios
```bash
systemctl status keepalived
systemctl restart keepalived
journalctl -u keepalived -f
```

## 8. Red
Usa el protocolo VRRP (IP 112) sobre multicast `224.0.0.18`. Es indispensable que el firewall de ambos nodos permita este tráfico entre sí.

## 9. Acceso / SSH
La configuración se edita por SSH en cada nodo (`/etc/keepalived/keepalived.conf` es distinto en VM1 y VM2: cambia el `state` y la `priority`).

## 10. Logs
Las transiciones de estado (`MASTER` ⇄ `BACKUP`) quedan registradas en `/var/log/syslog` o vía `journalctl -u keepalived`. Es el primer lugar a revisar tras un failover.

## 11. Bash / Scripting
Ejemplo de `track_script` que verifica que PostgreSQL esté vivo, para que Keepalived no reclame la VIP si la base de datos local está caída:
```bash
#!/bin/bash
# /etc/keepalived/scripts/check_postgres.sh
pg_isready -q
exit $?
```

## 12. Comandos fundamentales
* `ip addr show`: confirma en qué nodo está físicamente la VIP en este momento.
* `systemctl status keepalived`: estado del servicio.
* `journalctl -u keepalived -n 50`: últimas transiciones registradas.
* `tcpdump -i eth0 vrrp`: observa los anuncios VRRP en vivo.

## 13. Prácticas
1. Instala Keepalived en dos VMs de prueba (una `MASTER`, una `BACKUP`).
2. Confirma que la VIP aparece en la VM `MASTER` (`ip addr show`).
3. Detén el servicio Keepalived en la `MASTER` y verifica que la VIP aparece en la `BACKUP` en segundos.
4. Vuelve a levantar la `MASTER` y observa si recupera la VIP (según la prioridad configurada).

## 14. Errores frecuentes
* **`virtual_router_id` duplicado** en la misma red: interfiere con otro clúster VRRP.
* **Firewall bloqueando VRRP:** ambos nodos terminan creyendo que son `MASTER` (split-brain de red).
* **Contraseñas de autenticación VRRP distintas entre nodos:** Keepalived ignora los anuncios del otro nodo.
* **`track_script` mal escrito:** puede hacer que el nodo abandone el rol MASTER de forma constante e inestable ("flapping").

## 15. Troubleshooting
1. ¿El servicio está corriendo en ambos nodos? (`systemctl status keepalived`).
2. ¿Dónde está la VIP ahora mismo? (`ip addr show` en ambos nodos).
3. ¿Llegan anuncios VRRP? (`tcpdump -i eth0 vrrp`).
4. ¿Qué dice el log sobre transiciones de estado? (`journalctl -u keepalived`).

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Keepalived es el mecanismo de failover de **red**: resuelve "¿a qué IP le hablo?". No sabe si PostgreSQL o Redis están sanos por sí solo — por eso se combina con `track_script` y con Patroni/repmgr y Sentinel (que sí entienden el estado de las bases de datos) para que el failover completo sea coherente.

## 17. Documentación oficial
* [Keepalived Official Documentation](https://www.keepalived.org/documentation.html)
* [Keepalived GitHub - ejemplos de configuración](https://github.com/acassen/keepalived)

## 18. Checklist
- [ ] Sé configurar un `vrrp_instance` con `state`, `priority` y `virtual_ipaddress`.
- [ ] Entiendo la diferencia entre `MASTER` y `BACKUP`.
- [ ] Sé usar un `track_script` para condicionar el rol al estado de un servicio.
- [ ] Sé diagnosticar un split-brain revisando `ip addr show` en ambos nodos.

➡️ **[Ir a Patroni / repmgr](./patroni-repmgr.md)**
