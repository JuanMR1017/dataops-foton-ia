# MQTT y Mosquitto

## 1. ¿Qué es?
MQTT (*Message Queuing Telemetry Transport*) es un protocolo de mensajería ligero, tipo **publicador/suscriptor**, diseñado para dispositivos con poca energía y redes inestables — exactamente el perfil de un sensor IoT en campo. Mosquitto es el software (broker) que implementa este protocolo y que instalaremos en nuestros nodos.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
ChirpStack traduce los datos que llegan por LoRaWAN y los publica como mensajes MQTT. Nuestro broker Mosquitto es el punto central donde esos mensajes de telemetría (nivel de contaminación, caudal, etc.) quedan disponibles para que otros servicios los consuman y los guarden en PostgreSQL.

## 3. Conceptos básicos
* **Broker:** El servidor central que recibe y redistribuye mensajes (Mosquitto).
* **Topic (tema):** Una ruta jerárquica tipo `foton/vm1/sensor1/nivel_agua` a la que se publican y suscriben mensajes.
* **Publicador / Suscriptor:** Quien envía datos a un topic, y quien los recibe, respectivamente — no se conocen entre sí directamente.
* **QoS (Quality of Service):** Nivel de garantía de entrega (0 = a lo sumo una vez, 1 = al menos una vez, 2 = exactamente una vez).
* **Last Will and Testament (LWT):** Un mensaje que el broker publica automáticamente si un cliente se desconecta abruptamente — muy útil para detectar sensores o servicios caídos.
* **Retained message:** El broker guarda el último mensaje de un topic y lo entrega inmediatamente a cualquier nuevo suscriptor.

## 4. Sistema de archivos / Estructura
* `/etc/mosquitto/mosquitto.conf`: archivo principal de configuración.
* `/etc/mosquitto/conf.d/`: configuraciones adicionales modulares.
* `/etc/mosquitto/passwd`: archivo de usuarios y contraseñas cifradas.
* `/var/lib/mosquitto/`: persistencia de mensajes retenidos y sesiones.

## 5. Usuarios y permisos
Mosquitto puede correr sin autenticación (solo para pruebas locales) o con usuarios definidos vía `mosquitto_passwd`. En FOTON-IA se debe exigir usuario/contraseña y, opcionalmente, listas de control de acceso (ACL) para que un sensor solo pueda publicar en su propio topic.

## 6. Procesos
El broker corre como el proceso `mosquitto`, escuchando conexiones TCP entrantes de forma continua y manteniendo en memoria la tabla de suscripciones activas.

## 7. Servicios
```bash
systemctl status mosquitto
systemctl restart mosquitto
systemctl enable mosquitto   # arranque automático
```

## 8. Red
* **Puerto 1883:** MQTT sin cifrar.
* **Puerto 8883:** MQTT sobre TLS/SSL (recomendado si el broker se expone fuera de la red interna).
* **Puerto 9001** (opcional): MQTT sobre WebSockets, útil para dashboards web.

## 9. Acceso / SSH
La administración del broker se hace por SSH a la VM que lo aloja, editando `mosquitto.conf` y reiniciando el servicio. Para pruebas de publicación/suscripción se usan los clientes de línea de comandos `mosquitto_pub` / `mosquitto_sub` desde cualquier máquina con red hacia el broker.

## 10. Logs
* `/var/log/mosquitto/mosquitto.log`: conexiones, desconexiones y errores.
* `journalctl -u mosquitto -f`: en tiempo real vía systemd.

## 11. Bash / Scripting
Probar que el broker recibe y entrega mensajes correctamente:
```bash
# Terminal 1: suscribirse
mosquitto_sub -h localhost -t "foton/vm1/#" -u usuario -P contraseña

# Terminal 2: publicar un mensaje de prueba
mosquitto_pub -h localhost -t "foton/vm1/sensor1/nivel_agua" -m "12.4" -u usuario -P contraseña
```

## 12. Comandos fundamentales
* `mosquitto_pub`: publica un mensaje.
* `mosquitto_sub`: se suscribe y escucha mensajes.
* `mosquitto_passwd -c /etc/mosquitto/passwd usuario`: crea un archivo de usuarios.
* `systemctl status mosquitto`: verifica el estado del servicio.
* `ss -tulnp | grep 1883`: confirma que el puerto está escuchando.

## 13. Prácticas
1. Instala Mosquitto en una VM de prueba.
2. Crea un usuario con `mosquitto_passwd`.
3. Abre dos terminales: una suscrita a un topic, otra publicando mensajes, y verifica que lleguen.

## 14. Errores frecuentes
* **Conexión rechazada (`Connection Refused: not authorised`):** credenciales incorrectas o usuario no creado.
* **Mensajes no aparecen en el suscriptor:** el topic del publicador no coincide exactamente con el patrón de suscripción.
* **Puerto 1883 no accesible:** firewall bloqueando la conexión entre nodos.

## 15. Troubleshooting
1. ¿El servicio está corriendo? (`systemctl status mosquitto`).
2. ¿El puerto está escuchando? (`ss -tulnp | grep 1883`).
3. ¿Las credenciales son correctas? (probar con `mosquitto_pub`/`sub` manualmente).
4. ¿Qué dice el log? (`tail -f /var/log/mosquitto/mosquitto.log`).

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Mosquitto corre en modo activo en VM1 y en modo pasivo en VM2. Gracias a la IP Virtual de Keepalived, ChirpStack y los sensores siempre publican hacia la misma dirección, sin importar cuál de los dos brokers está realmente activo en ese momento. El **LWT** también puede usarse para que el sistema de monitoreo detecte si el broker principal se cayó antes de que ocurra el failover completo.

## 17. Documentación oficial
* [Mosquitto Official Docs](https://mosquitto.org/documentation/)
* [MQTT.org - Especificación del protocolo](https://mqtt.org/mqtt-specification/)

## 18. Checklist
- [ ] Entiendo el modelo publicador/suscriptor y qué es un topic.
- [ ] Sé instalar y configurar autenticación básica en Mosquitto.
- [ ] Sé publicar y suscribirme a un topic desde la terminal.
- [ ] Entiendo qué rol cumple el LWT para detectar desconexiones.

➡️ **[Ir a LoRaWAN y ChirpStack](./lorawan-chirpstack.md)**
