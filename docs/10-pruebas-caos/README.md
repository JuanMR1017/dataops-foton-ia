# 🔥 Módulo 10: Pruebas de Caos y Failover

Este módulo no sigue la plantilla de 18 puntos porque no documenta una tecnología: es el **runbook** que el equipo ejecuta para validar que toda la arquitectura de Alta Disponibilidad funciona de verdad, no solo en el papel.

## 1. Objetivo
Confirmar que, ante una falla real de VM1, el sistema:
1. Detecta la falla en segundos (no minutos).
2. Mueve la VIP a VM2 (Keepalived).
3. Promueve PostgreSQL a primario en VM2 (Patroni/repmgr).
4. Promueve Redis a master en VM2 (Sentinel, con voto de VM3).
5. ChirpStack y Mosquitto en VM2 empiezan a recibir tráfico sin reconfiguración manual.
6. Grafana refleja el evento (caída de VM1, VIP en VM2, sin pérdida de métricas nuevas).

## 2. Antes de empezar (checklist previo)
- [ ] Los tres nodos están sincronizados en hora (`timedatectl` / NTP).
- [ ] La replicación de PostgreSQL y Redis está sana (sin retraso) antes de iniciar la prueba.
- [ ] Se avisó al equipo que se va a interrumpir VM1 intencionalmente (para no confundirlo con una falla real).
- [ ] Grafana y los logs de cada herramienta están abiertos para observar el evento en vivo.

## 3. Escenario de prueba: caída simulada de VM1
```bash
# Opción suave: apagar solo el servicio, no la VM completa
ssh vm1 'sudo systemctl stop postgresql'

# Opción dura: apagar la VM completa desde Proxmox
qm stop <ID_VM1>
```

## 4. Qué observar y en qué orden
| Paso | Dónde mirar | Qué esperar |
| :--- | :--- | :--- |
| 1 | `journalctl -u keepalived` en VM2 | Transición a `MASTER` en segundos |
| 2 | `ip addr show` en VM2 | La VIP aparece en la interfaz |
| 3 | `patronictl list` o `repmgr cluster show` | VM2 pasa de `replica` a `leader`/`primary` |
| 4 | `redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster` | Apunta ahora a VM2 |
| 5 | `mosquitto_sub` contra la VIP | Sigue recibiendo mensajes sin cambios |
| 6 | Grafana | El dashboard refleja la caída y la recuperación |

## 5. Restauración y limpieza
1. Vuelve a levantar VM1 (`qm start <ID_VM1>` o el servicio detenido).
2. VM1 debe reincorporarse como **standby/replica**, no reclamar el rol de primario automáticamente (eso evita un split-brain al reiniciar).
3. Verifica en `patronictl list` / `repmgr cluster show` que VM1 quedó sincronizando correctamente contra el nuevo primario (VM2).
4. Documenta el resultado de la prueba (ver plantilla abajo).

## 6. Plantilla de registro de la prueba
```
Fecha: 
Tipo de falla simulada (servicio / VM completa):
Tiempo hasta que la VIP se movió:
Tiempo hasta que PostgreSQL se promovió:
Tiempo hasta que Redis se promovió:
¿Hubo pérdida de datos/mensajes? (sí/no, detalle):
¿VM1 se reincorporó correctamente como standby?:
Observaciones / mejoras a implementar:
```

## 7. Errores frecuentes en pruebas de caos
* **Probar sin haber verificado antes que la replicación estaba sana:** invalida la prueba, porque no sabes si el problema es el failover o la replicación previa.
* **No esperar suficiente tiempo entre pasos:** un failover completo (red + BD) puede tomar más de unos segundos; hay que dejar que todas las piezas terminen antes de sacar conclusiones.
* **Reiniciar VM1 antes de tiempo:** si VM1 vuelve mientras VM2 apenas se está promoviendo, puede generar un split-brain temporal.

➡️ Con este módulo se cierra la ruta de estudio. El siguiente paso es la implementación real descrita en los `README.md` de `vm1-principal/`, `vm2-standby/` y `vm3-supervision/`, y los archivos de configuración de referencia en `config/` dentro de cada carpeta de VM.
