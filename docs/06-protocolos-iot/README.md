# 📡 Módulo 06: Protocolos IoT (MQTT y LoRaWAN)

Este módulo agrupa las dos tecnologías que permiten que los sensores de la quebrada La Picacha lleguen hasta nuestra base de datos. Cada una tiene su propio documento completo con los 18 puntos de la plantilla:

1. [MQTT y Mosquitto](./mqtt.md) — el protocolo de mensajería que reciben nuestros brokers.
2. [LoRaWAN y ChirpStack](./lorawan-chirpstack.md) — la red de radio de largo alcance y el servidor que la administra.

## Cómo encajan entre sí
```
[Sensor de calidad de agua] --LoRaWAN--> [Gateway físico] --UDP/MQTT--> [ChirpStack Gateway Bridge]
        --> [ChirpStack Network/Application Server] --MQTT--> [Mosquitto Broker] --> [Nuestra app / PostgreSQL]
```

➡️ Empieza por **[MQTT](./mqtt.md)**, ya que es el protocolo más simple y es la base para entender cómo ChirpStack entrega los datos.
