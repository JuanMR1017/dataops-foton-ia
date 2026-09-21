# 🛡️ Módulo 08: Alta Disponibilidad (Keepalived y Quórum)

Este es el módulo que amarra todo lo anterior en una arquitectura de failover automático. Tres piezas trabajan juntas:

1. [Keepalived](./keepalived.md) — mueve la IP Virtual (VIP) entre VM1 y VM2.
2. [Patroni / repmgr](./patroni-repmgr.md) — decide automáticamente cuándo promover el standby de PostgreSQL a primario.
3. [Redis Sentinel](./redis-sentinel.md) — decide automáticamente cuándo promover la réplica de Redis a master.

## Por qué se necesitan las tres a la vez
Keepalived mueve la IP, pero **no sabe nada de bases de datos**. Patroni/repmgr y Sentinel saben de bases de datos, pero **no mueven IPs**. Sin las tres coordinadas, podrías terminar con la IP en VM2 pero la base de datos aún promoviéndose en VM1 (o viceversa) — justo el tipo de inconsistencia que el nodo testigo (VM3) ayuda a prevenir, actuando como voto de quórum imparcial para las tres herramientas.

➡️ Empieza por **[Keepalived](./keepalived.md)**.
