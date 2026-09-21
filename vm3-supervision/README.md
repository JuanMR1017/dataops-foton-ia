# 👁️ VM3 - Nodo Testigo y Supervisión

Este documento define las herramientas que operarán en esta máquina virtual y los conocimientos que el **Grupo 3** debe adquirir. Este es el "cerebro" lógico del clúster: no maneja tráfico IoT directo, pero decide qué nodo está activo y monitorea la salud del sistema.

## 🛠️ 1. Herramientas y Servicios Asignados
Estas son las tecnologías de observabilidad y consenso.

| Servicio | Función en el Nodo | Documentación Oficial Verificada |
| :--- | :--- | :--- |
| **Prometheus** | Recolección de métricas del clúster (Series de tiempo). | [Prometheus Docs](https://prometheus.io/docs/introduction/overview/) |
| **Grafana** | Visualización de dashboards de monitoreo. | [Grafana Docs](https://grafana.com/docs/) |
| **Redis Sentinel** | Monitoreo del quórum de Redis para *failover* automático. | [Redis Docs (Buscar Sentinel)](https://redis.io/docs/latest/) |
| **Patroni** | Observación y quórum para *failover* de PostgreSQL. | [Patroni Docs](https://patroni.readthedocs.io/) |

## 🧠 2. Conocimientos Específicos Requeridos
Para administrar este nodo con éxito, el grupo debe enfocarse en estudiar:

* **Observabilidad Básica:** Entender cómo extraer métricas de otras máquinas (usando agentes como *Node Exporter*) y graficarlas.
* **Algoritmos de Consenso (Quórum):** Comprender por qué se necesita un tercer voto impar (2 de 3) para evitar un escenario de "cerebro dividido" (*Split-Brain*).
* **Automatización de Failover:** Estudiar cómo herramientas como Sentinel o Patroni promueven automáticamente una base de datos de respaldo (VM2) a principal (VM1) sin intervención humana.

## 🚀 3. Próximos Pasos
Los archivos de configuración de referencia para esta fase ya están disponibles en [`config/`](./config/):

| Herramienta | Archivo |
| :--- | :--- |
| Prometheus | [`config/prometheus/prometheus.yml`](./config/prometheus/prometheus.yml) |
| Grafana (datasource) | [`config/grafana/datasource-prometheus.yml`](./config/grafana/datasource-prometheus.yml) |
| Redis Sentinel (3er voto) | [`config/redis-sentinel/sentinel.conf`](./config/redis-sentinel/sentinel.conf) |
| etcd (quórum de Patroni) | [`config/patroni/README.md`](./config/patroni/README.md) |

⚠️ Todos estos archivos son puntos de partida educativos: antes de aplicarlos, **ajusta las IPs marcadas con `AJUSTAR`** a los valores reales del clúster Proxmox. Una vez desplegado, sigue el [Módulo 10 - Pruebas de Caos y Failover](../docs/10-pruebas-caos/README.md) para validar que el quórum de esta VM funciona correctamente.
