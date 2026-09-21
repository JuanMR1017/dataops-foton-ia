# 🌐 Módulo 03: Redes, IP Virtual y VRRP

## 1. ¿Qué es?
En el contexto de infraestructura, el estudio de redes abarca cómo los paquetes de datos viajan de un dispositivo a otro mediante direcciones IP, subredes y puertas de enlace (Gateways). El protocolo **VRRP** (*Virtual Router Redundancy Protocol*) permite agrupar varios routers o servidores bajo una única **IP Virtual (VIP)** compartida.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Nuestros sensores LoRaWAN envían datos constantemente hacia el servidor. Si la VM1 (nodo principal) llega a fallar, los sensores no pueden quedarse buscando una IP que ya no responde. Gracias a la IP Virtual y a VRRP, la VM2 asumirá instantáneamente esa misma dirección IP, logrando que los dispositivos IoT sigan enviando datos sin enterarse de que hubo un fallo.

## 3. Conceptos básicos
* **Dirección IP Estática:** Una dirección de red fija que no cambia, asignada a cada máquina virtual individualmente (VM1, VM2, VM3).
* **IP Virtual (VIP):** Una dirección IP flotante que no pertenece a una sola tarjeta de red física, sino que "viaja" dinámicamente al nodo que esté activo.
* **VRRP (Virtual Router Redundancy Protocol):** El protocolo estándar que usa Keepalived para comunicarse entre VM1 y VM2, determinando quién es el `MASTER` y quién es el `BACKUP`.
* **Gateway (Puerta de enlace):** La IP que permite salir de la red local hacia otras redes.
* **Máscara de subred:** Define qué parte de una IP identifica la red y cuál el host (ej. `/24`).

## 4. Sistema de archivos / Estructura
La configuración de red persistente vive en `/etc/netplan/*.yaml` (Ubuntu Server) o `/etc/network/interfaces` (Debian clásico). Una vez instalado, Keepalived guarda su configuración en `/etc/keepalived/keepalived.conf` — ese archivo es el que define la VIP y el rol VRRP de cada nodo (se detalla en el Módulo 08).

## 5. Usuarios y permisos
Modificar la configuración de red o de Keepalived requiere privilegios de `root`/`sudo`, porque implica levantar o mover interfaces y direcciones IP a nivel de kernel (`CAP_NET_ADMIN`).

## 6. Procesos
La pila de red corre como parte del kernel de Linux, gestionada por el demonio `systemd-networkd` o `NetworkManager` según la distro. Cuando Keepalived esté instalado (Módulo 08), correrá como un proceso propio (`keepalived`) que negocia el rol VRRP con el otro nodo.

## 7. Servicios
```bash
systemctl status systemd-networkd   # estado del servicio de red
systemctl restart networking        # reinicia la red (Debian)
netplan apply                       # aplica cambios de netplan (Ubuntu)
```

## 8. Puertos y protocolos clave en nuestra arquitectura
* **Puerto 1883 / 8883:** Utilizado por el Broker MQTT para la mensajería IoT.
* **Puerto 5432:** Utilizado para las conexiones y la replicación de PostgreSQL.
* **Puerto 6379:** Utilizado por Redis.
* **Puerto 8080 / 443:** Interfaz de ChirpStack y Grafana.
* **Protocolo IP 112 (VRRP) + multicast 224.0.0.18:** Usado por Keepalived para las notificaciones entre VM1 y VM2. Si un firewall bloquea este protocolo, el failover nunca ocurrirá.

## 9. Acceso / SSH
Un error de red mal aplicado puede dejarte sin acceso remoto a la máquina. Por eso, antes de cambiar una configuración de red por SSH, se recomienda aplicarla con un temporizador de reversión automática (ej. `netplan try`) o tener acceso a la consola de Proxmox como respaldo.

## 10. Logs
* `journalctl -u systemd-networkd -f`: eventos de la interfaz de red.
* `dmesg | grep eth`: mensajes del kernel sobre las tarjetas de red.
* `/var/log/syslog` (una vez instalado Keepalived): aquí aparecen las transiciones `MASTER`/`BACKUP` de VRRP.

## 11. Bash / Scripting
Un script simple para verificar si la VIP está activa en un nodo:
```bash
ip addr show eth0 | grep "192.168.1.100" && echo "VIP activa aquí" || echo "VIP en el otro nodo"
```

## 12. Comandos fundamentales
* `ip addr show`: Muestra las direcciones IP asignadas a cada interfaz.
* `ip route`: Muestra la tabla de enrutamiento y el gateway por defecto.
* `ping <IP>`: Verifica conectividad básica.
* `ss -tulnp`: Lista los puertos abiertos y qué proceso los usa.
* `tcpdump -i eth0 vrrp`: Captura en vivo los anuncios VRRP entre nodos.
* `traceroute <IP>`: Muestra la ruta que siguen los paquetes.

## 13. Prácticas
1. Configura una IP estática en una VM de prueba usando netplan.
2. Verifica la conectividad hacia las otras dos VMs con `ping`.
3. Revisa qué puertos están escuchando con `ss -tulnp`.

## 14. Errores frecuentes
* **Gateway mal configurado:** la VM se conecta a su propia red pero no sale a otras.
* **Máscara de subred incorrecta:** hace que la VM "vea" mal el tamaño de su red local.
* **Firewall bloqueando VRRP:** un firewall que solo permite TCP/UDP bloqueará el protocolo VRRP (IP 112) y el tráfico multicast, impidiendo el failover.

## 15. Troubleshooting
1. ¿Responde a nivel de red? (`ping IP_VM`).
2. Si responde, ¿me puedo conectar? (`ssh usuario@IP_VM`).
3. ¿La interfaz tiene la IP esperada? (`ip addr show`).
4. ¿Hay tráfico VRRP llegando? (`tcpdump -i eth0 vrrp`).

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
La red es el puente de la Alta Disponibilidad. Si la red interna del clúster Proxmox falla o se configura mal, Keepalived sufrirá de falsos positivos o escenarios de *split-brain* (cerebro dividido), donde ambas máquinas intenten responder por la misma IP al mismo tiempo.

## 17. Documentación oficial
* [Keepalived Official Documentation & VRRP overview](https://www.keepalived.org/documentation.html)
* [RFC 5798 - VRRP Version 3](https://www.rfc-editor.org/rfc/rfc5798)
* [Ubuntu Netplan Documentation](https://netplan.readthedocs.io/en/stable/)

## 18. Checklist
- [ ] Entiendo la diferencia entre una IP estática y una IP Virtual (VIP).
- [ ] Comprendo qué función cumple el protocolo VRRP en el clúster.
- [ ] Conozco los puertos principales que utilizarán nuestros servicios.
- [ ] Sé revisar la tabla de rutas y las interfaces con `ip`.
- [ ] Entiendo por qué un firewall mal configurado puede romper el failover.

➡️ **[Ir al Módulo 04 - Git y GitHub](../04-git-github/README.md)**
