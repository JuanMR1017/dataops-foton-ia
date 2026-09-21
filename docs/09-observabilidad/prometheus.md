# Prometheus

## 1. ¿Qué es?
Prometheus es un sistema de monitoreo de series de tiempo: cada cierto intervalo, "hace scraping" (consulta) a los servicios configurados para recolectar métricas numéricas (uso de CPU, memoria, estado de replicación, etc.) y las guarda con marca de tiempo.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Es la única forma de responder, sin adivinar, preguntas como "¿VM1 está sobrecargada?", "¿la replicación de PostgreSQL tiene retraso?" o "¿cuánto tiempo estuvo la VIP en VM2 la última vez que falló VM1?".

## 3. Conceptos básicos
* **Exporter:** Un pequeño servicio que traduce las métricas internas de una herramienta (Linux, PostgreSQL, Redis) a un formato que Prometheus entiende (ej. `node_exporter`, `postgres_exporter`, `redis_exporter`).
* **Scrape:** El acto de Prometheus consultando periódicamente (`scrape_interval`) un exporter.
* **Target:** Cada endpoint que Prometheus consulta.
* **PromQL:** El lenguaje de consultas para analizar las métricas guardadas.
* **Alerting Rule:** Una condición (ej. "CPU > 90% por 5 minutos") que dispara una alerta.

## 4. Sistema de archivos / Estructura
* `/etc/prometheus/prometheus.yml`: archivo principal, define los `targets` a monitorear.
* `/etc/prometheus/rules/`: reglas de alertas.
* `/var/lib/prometheus/`: base de datos de series de tiempo local.

## 5. Usuarios y permisos
Prometheus corre como su propio usuario de sistema (`prometheus`), sin privilegios especiales, ya que solo hace peticiones HTTP de solo lectura a los exporters.

## 6. Procesos
El proceso `prometheus` corre de forma continua, ejecutando el ciclo de scraping según el `scrape_interval` configurado (típicamente cada 15-30 segundos).

## 7. Servicios
```bash
systemctl status prometheus
systemctl restart prometheus
promtool check config /etc/prometheus/prometheus.yml   # valida la sintaxis antes de reiniciar
```

## 8. Red
* **Puerto 9090:** interfaz web y API de Prometheus.
* **Puerto 9100:** `node_exporter` (métricas de sistema operativo) en cada VM.
* **Puerto 9187:** `postgres_exporter`. **Puerto 9121:** `redis_exporter`.

## 9. Acceso / SSH
La interfaz web se accede por navegador (idealmente detrás de la VIP o solo desde la red interna); la configuración se edita por SSH a VM3.

## 10. Logs
`journalctl -u prometheus -f` — errores de scraping (targets caídos) aparecen aquí y también son visibles en la pestaña "Targets" de la interfaz web.

## 11. Bash / Scripting
Verificar rápidamente si un exporter responde antes de agregarlo a `prometheus.yml`:
```bash
curl http://<IP_VM1>:9100/metrics | head -20
```

## 12. Comandos fundamentales
* `promtool check config <archivo>`: valida la configuración.
* `curl localhost:9090/api/v1/targets`: lista el estado de todos los targets vía API.
* Consulta PromQL de ejemplo: `up{job="node_exporter"}` (1 = activo, 0 = caído).

## 13. Prácticas
1. Instala `node_exporter` en una VM de prueba y confirma que expone métricas en el puerto 9100.
2. Configura Prometheus para hacerle scraping.
3. En la interfaz web (puerto 9090), ve a "Targets" y confirma que aparece en estado "UP".
4. Ejecuta la consulta PromQL `up` y observa el resultado.

## 14. Errores frecuentes
* **Target en estado "DOWN":** el exporter no está corriendo, o un firewall bloquea el puerto.
* **`scrape_interval` demasiado agresivo:** puede sobrecargar VMs con recursos limitados.
* **Olvidar recargar la configuración** tras editar `prometheus.yml` (`systemctl reload prometheus` o reinicio).

## 15. Troubleshooting
1. ¿El exporter responde directamente? (`curl http://IP:PUERTO/metrics`).
2. ¿Prometheus lo ve como "UP" en la pestaña Targets?
3. ¿Hay un firewall entre VM3 y el nodo monitoreado?
4. ¿`promtool check config` no reporta errores de sintaxis?

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Prometheus corre en VM3 (el nodo neutral) precisamente porque necesita observar a VM1 y VM2 sin depender de cuál esté activa. Métricas como `pg_replication_lag` o `up{job="node_exporter"}` permiten detectar un problema de replicación o una caída **antes** de que se convierta en un failover, y confirmar después de un failover que todo quedó saludable.

## 17. Documentación oficial
* [Prometheus Official Docs](https://prometheus.io/docs/introduction/overview/)
* [Node Exporter](https://github.com/prometheus/node_exporter)

## 18. Checklist
- [ ] Entiendo qué es un exporter y por qué Prometheus no lee las métricas directamente.
- [ ] Sé agregar un nuevo target a `prometheus.yml`.
- [ ] Sé verificar el estado de un target en la interfaz web.
- [ ] Sé escribir una consulta PromQL básica.

➡️ **[Ir a Grafana](./grafana.md)**
