# LoRaWAN y ChirpStack

## 1. ¿Qué es?
LoRaWAN es un protocolo de red de largo alcance y bajo consumo (LPWAN), ideal para sensores remotos como los que monitorean la quebrada La Picacha, ya que pueden transmitir kilómetros con muy poca batería. ChirpStack es la plataforma open-source que administra esa red: recibe las señales de los gateways físicos y las convierte en datos utilizables.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Los sensores de calidad de agua no están cerca de un router WiFi ni tienen cable de red — están en un entorno remoto. LoRaWAN nos permite recibir su telemetría a distancia, y ChirpStack se encarga de todo el trabajo pesado de decodificar, autenticar y enrutar esos mensajes hacia nuestro sistema.

## 3. Conceptos básicos
* **Gateway:** El dispositivo físico que recibe las señales de radio LoRa de los sensores y las reenvía por IP hacia ChirpStack.
* **Uplink / Downlink:** Uplink es el dato que el sensor envía hacia el servidor; downlink es un comando que el servidor envía de vuelta al sensor.
* **Device Profile:** Define cómo se comporta un tipo de sensor (frecuencia, tasa de datos, clase A/B/C).
* **Join Server / Network Server / Application Server:** Los tres componentes lógicos de ChirpStack — autentican el dispositivo, gestionan la red de radio, y entregan los datos ya decodificados a la aplicación.
* **Spreading Factor (SF):** Un parámetro de radio que equilibra alcance contra velocidad de transmisión.

## 4. Sistema de archivos / Estructura
En una instalación con Docker (ver Módulo 05), la configuración de ChirpStack vive en archivos `.toml` montados como volúmenes (ej. `chirpstack.toml`, `chirpstack-gateway-bridge.toml`), en lugar de rutas fijas del sistema operativo.

## 5. Usuarios y permisos
ChirpStack tiene su propio panel web con roles de usuario (admin de organización, admin de aplicación, solo lectura) para controlar quién puede crear dispositivos o ver telemetría.

## 6. Procesos
ChirpStack corre como varios procesos/contenedores independientes: `chirpstack` (network + application server) y `chirpstack-gateway-bridge` (traduce el protocolo UDP del gateway físico a MQTT interno).

## 7. Servicios
```bash
docker compose ps                       # ver qué componentes de ChirpStack están activos
docker compose restart chirpstack       # reiniciar solo el network server
docker compose logs -f chirpstack-gateway-bridge
```

## 8. Red
* **Puerto UDP 1700:** el Gateway Bridge escucha aquí las señales que llegan del gateway físico (protocolo Semtech UDP).
* **Puerto 8080:** interfaz web y API REST de ChirpStack.
* ChirpStack se comunica internamente con Mosquitto (puerto 1883) para publicar los datos ya decodificados.

## 9. Acceso / SSH
El panel de administración de ChirpStack se accede vía navegador web (HTTP/HTTPS) apuntando a la VIP del clúster; la administración de los contenedores subyacentes se hace por SSH a la VM que los aloja.

## 10. Logs
```bash
docker logs -f chirpstack
docker logs -f chirpstack-gateway-bridge
```
Ahí se ven los "joins" de dispositivos nuevos, errores de decodificación y problemas de conectividad con los gateways físicos.

## 11. Bash / Scripting
Verificar que el Gateway Bridge está recibiendo tráfico UDP del gateway físico:
```bash
sudo tcpdump -i eth0 udp port 1700 -c 10
```

## 12. Comandos fundamentales
* `docker compose logs -f chirpstack`: monitorea eventos del network server.
* `docker compose restart chirpstack-gateway-bridge`: reinicia el puente si un gateway dejó de reportar.
* `mosquitto_sub -t "application/+/device/+/event/up"`: escucha en vivo los mensajes que ChirpStack publica hacia MQTT.

## 13. Prácticas
1. Levanta el stack de ChirpStack con Docker Compose en un entorno de prueba.
2. Registra un gateway y un dispositivo de prueba en el panel web.
3. Simula un uplink (o conecta un dispositivo real) y verifica que el mensaje llega a Mosquitto con `mosquitto_sub`.

## 14. Errores frecuentes
* **Gateway aparece "never seen" en el panel:** problema de red UDP entre el gateway físico y el puerto 1700, o EUI del gateway mal configurado.
* **Dispositivo no logra hacer "join":** claves de seguridad (AppKey/NwkKey) mal copiadas.
* **Datos no llegan a la aplicación:** integración MQTT de ChirpStack mal configurada o Mosquitto caído.

## 15. Troubleshooting
1. ¿El gateway físico tiene conectividad a Internet/VPN? (ping desde el gateway).
2. ¿Llega tráfico UDP al puerto 1700? (`tcpdump`).
3. ¿El Network Server está corriendo? (`docker compose ps`).
4. ¿La integración MQTT está activa? (revisar en el panel de la aplicación en ChirpStack).

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
ChirpStack corre activo en VM1 y en modo pasivo (contenedores detenidos o en espera) en VM2, ambos apuntando a la misma base de datos replicada. Como los gateways físicos siempre envían su tráfico UDP a la IP Virtual, un failover de VM1 a VM2 es transparente para ellos: solo cambia qué servidor procesa los mensajes, no la dirección a la que apuntan.

## 17. Documentación oficial
* [ChirpStack Official Docs](https://www.chirpstack.io/docs/)
* [LoRa Alliance - especificación LoRaWAN](https://lora-alliance.org/resource_hub/lorawan-specification-v1-1/)

## 18. Checklist
- [ ] Entiendo el camino que sigue un dato desde el sensor hasta la aplicación.
- [ ] Sé qué es un Device Profile y para qué sirve.
- [ ] Sé revisar los logs de ChirpStack para diagnosticar un gateway que no reporta.
- [ ] Entiendo por qué el failover de ChirpStack es transparente para los gateways físicos.

➡️ **[Ir al Módulo 07 - Bases de Datos](../07-bases-datos/README.md)**
