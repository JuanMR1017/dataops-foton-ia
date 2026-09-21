# Grafana

## 1. ¿Qué es?
Grafana es una plataforma de visualización que se conecta a fuentes de datos como Prometheus y las convierte en dashboards gráficos (líneas, gauges, tablas) fáciles de interpretar de un vistazo.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Las métricas crudas de Prometheus son difíciles de leer directamente. Grafana nos da un panel único donde ver, por ejemplo, el estado de los tres nodos, el retraso de replicación y el historial de niveles de agua, todo en una sola pantalla.

## 3. Conceptos básicos
* **Data Source:** La fuente de datos que Grafana consulta (en FOTON-IA, principalmente Prometheus).
* **Dashboard:** Una colección de paneles (gráficas) organizados en una vista.
* **Panel:** Una visualización individual (una gráfica de línea, un gauge, una tabla).
* **Alerting:** Grafana también puede disparar notificaciones (email, Slack) cuando un panel cruza un umbral.
* **Provisioning:** Definir data sources y dashboards como archivos de configuración versionables, en lugar de crearlos manualmente por la interfaz web cada vez.

## 4. Sistema de archivos / Estructura
* `/etc/grafana/grafana.ini`: configuración general del servidor.
* `/etc/grafana/provisioning/datasources/`: archivos YAML para definir data sources automáticamente.
* `/etc/grafana/provisioning/dashboards/`: define qué dashboards cargar al iniciar.
* `/var/lib/grafana/grafana.db`: base de datos interna (usuarios, dashboards guardados manualmente).

## 5. Usuarios y permisos
Grafana tiene su propio sistema de usuarios con roles (`Admin`, `Editor`, `Viewer`). Se recomienda cambiar la contraseña de administrador por defecto (`admin`/`admin`) inmediatamente tras la instalación.

## 6. Procesos
El proceso `grafana-server` corre de forma continua, sirviendo la interfaz web y consultando las data sources bajo demanda cuando alguien abre un dashboard.

## 7. Servicios
```bash
systemctl status grafana-server
systemctl restart grafana-server
```

## 8. Red
* **Puerto 3000:** interfaz web por defecto.
* Grafana necesita poder alcanzar por red al puerto 9090 de Prometheus (si están en la misma VM3, es tráfico local).

## 9. Acceso / SSH
La interfaz web se accede por navegador; la configuración avanzada (provisioning) se edita por SSH a VM3.

## 10. Logs
`/var/log/grafana/grafana.log` o `journalctl -u grafana-server -f` — útil para depurar errores de conexión a la data source o fallos de autenticación.

## 11. Bash / Scripting
Ejemplo mínimo de un archivo de provisioning para agregar Prometheus como data source automáticamente:
```yaml
# /etc/grafana/provisioning/datasources/prometheus.yml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
    access: proxy
    isDefault: true
```

## 12. Comandos fundamentales
* `systemctl status grafana-server`: estado del servicio.
* `curl -s http://localhost:3000/api/health`: verifica que la API responde.
* Dentro de la interfaz: *Connections → Data sources → Test* valida la conexión a Prometheus.

## 13. Prácticas
1. Instala Grafana en VM3 (o una VM de prueba) junto a Prometheus.
2. Agrega Prometheus como data source (manual o vía provisioning).
3. Crea un panel simple que grafique la métrica `up{job="node_exporter"}`.
4. Guarda el dashboard y compártelo con el equipo.

## 14. Errores frecuentes
* **Dejar la contraseña por defecto `admin`/`admin`:** riesgo de seguridad evidente.
* **Data source mal configurada** (URL incorrecta): los paneles muestran "No Data".
* **Dashboards creados manualmente y no versionados:** se pierden si se reinstala Grafana; por eso se recomienda usar *provisioning*.

## 15. Troubleshooting
1. ¿El servicio está corriendo? (`systemctl status grafana-server`).
2. ¿La API responde? (`curl localhost:3000/api/health`).
3. ¿La data source pasa el test de conexión en la interfaz?
4. ¿Prometheus mismo tiene los datos esperados? (probar la consulta directamente en Prometheus antes de culpar a Grafana).

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Grafana es la ventana humana hacia todo lo que las demás herramientas de este proyecto hacen automáticamente. Un dashboard bien diseñado permite ver en segundos si la VIP está en VM1 o VM2, si la replicación está al día, y confirmar visualmente que un failover ocurrió limpio — sin tener que revisar logs de cinco herramientas distintas una por una.

## 17. Documentación oficial
* [Grafana Official Docs](https://grafana.com/docs/grafana/latest/)
* [Grafana Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/)

## 18. Checklist
- [ ] Sé conectar Grafana a Prometheus como data source.
- [ ] Sé crear un panel básico a partir de una métrica.
- [ ] Entiendo qué es el provisioning y por qué es preferible a configurar todo manualmente.
- [ ] Cambié la contraseña de administrador por defecto.

➡️ **[Ir al Módulo 10 - Pruebas de Caos y Failover](../10-pruebas-caos/README.md)**
