# 🐧 Módulo 02: Linux

## 1. ¿Qué es?
Es un sistema operativo de código abierto fundamental en el mundo de los servidores. A diferencia de los sistemas de escritorio tradicionales, en entornos de infraestructura interactuamos con él casi exclusivamente a través de la línea de comandos (CLI) o terminal, sin interfaz gráfica.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Porque las tres máquinas virtuales (VM1, VM2, VM3) de nuestro clúster en Proxmox ejecutarán una distribución de Linux (específicamente Debian o Ubuntu Server). Todos nuestros servicios (Keepalived, PostgreSQL, Redis, ChirpStack) están diseñados para correr de manera nativa, segura y estable sobre este sistema operativo.

## 3. Conceptos básicos
* **Kernel:** El núcleo del sistema que se comunica directamente con el hardware virtualizado (vCPU, RAM, Discos virtuales).
* **Distribución (Distro):** Una versión empaquetada de Linux. Usaremos distribuciones enfocadas en servidores.
* **Shell (Bash):** El programa que interpreta los comandos que escribimos en la terminal.

## 4. Sistema de archivos / Estructura
En Linux todo cuelga de la raíz `/`. Las carpetas más importantes para nosotros son:
* `/etc/`: Aquí viven los archivos de configuración (ej. la configuración de IP virtual de Keepalived).
* `/var/log/`: Donde se guardan los registros cuando un servicio falla.
* `/home/`: Las carpetas personales de los usuarios normales.

## 5. Usuarios y permisos
* **`root`:** El superusuario. Tiene control absoluto y puede destruir el sistema si se equivoca.
* **`sudo`:** Comando que permite a un usuario normal ejecutar tareas administrativas temporalmente de forma segura.
* **Permisos:** Definen quién puede leer, escribir o ejecutar un archivo en el servidor.

## 6. Procesos
Todo programa en ejecución es un proceso con un ID único (`PID`). Si el Broker MQTT se bloquea, identificamos su proceso y lo reiniciamos.

## 7. Servicios
En un entorno de Alta Disponibilidad, los programas deben arrancar solos si la máquina se reinicia. Linux usa un gestor llamado **`systemd`** para esto. Lo controlamos mediante el comando `systemctl`.

## 8. Red
Linux maneja las interfaces de red (tarjetas de red virtuales). En FOTON-IA la red es vital, porque Keepalived creará y moverá una IP Virtual (VIP) directamente sobre estas interfaces para gestionar el *failover*.

## 9. Acceso / SSH
*(Secure Shell)*. Es el protocolo que usaremos para conectarnos remotamente a VM1, VM2 y VM3 desde nuestros computadores personales de forma encriptada.

## 10. Logs
Si la VM2 no asume el rol cuando la VM1 se apaga, la respuesta está en los logs. Se revisan principalmente con el comando `journalctl`.

## 11. Bash / Scripting
Podemos escribir archivos de texto con listas de comandos (scripts `.sh`) para automatizar tareas repetitivas.

## 12. Comandos fundamentales
* `ls -la`: Lista todos los archivos (incluso ocultos) y sus permisos.
* `cd /ruta/`: Cambia de directorio.
* `nano archivo.conf`: Editor de texto rápido en la terminal.
* `apt update && apt upgrade`: Actualiza el sistema operativo.
* `htop`: Muestra el consumo de CPU y RAM en tiempo real.
* `systemctl status <servicio>`: Verifica si un servicio (ej. postgresql) está corriendo.
* `journalctl -xe`: Muestra los últimos errores registrados en el sistema.

## 13. Prácticas
1. Conéctate por SSH a una máquina virtual de prueba.
2. Actualiza los repositorios usando `apt update`.
3. Revisa el consumo de recursos usando `htop`.

## 14. Errores frecuentes
* **"Permission denied":** Olvidaste poner `sudo` antes de un comando administrativo.
* **Editar configuraciones equivocadas:** Modificar archivos en `/etc/` sin hacer una copia de seguridad (`cp`) primero.
* **Llenar el disco:** Dejar que los logs crezcan sin control.

## 15. Troubleshooting
Si un servidor de FOTON-IA no responde, la ruta lógica es:
1. ¿Responde a nivel de red? (`ping IP_VM`).
2. Si responde, ¿me puedo conectar? (`ssh usuario@IP_VM`).
3. ¿El servicio está caído? (`systemctl status <servicio>`).
4. ¿Qué dice el sistema? (`journalctl -u <servicio>`).

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Linux es el cimiento de nuestra arquitectura. Si el sistema operativo base falla (red inestable, firewall mal configurado, discos llenos), las herramientas de Alta Disponibilidad fallarán. Cada grupo es responsable de mantener "sano" el Linux de su máquina asignada.

## 17. Documentación oficial
* [Guía de Ubuntu Server](https://ubuntu.com/server/docs)
* [Documentación Oficial de Debian](https://www.debian.org/doc/)

## 18. Checklist
- [ ] Entiendo cómo navegar por el sistema de archivos (`cd`, `ls`).
- [ ] Entiendo la diferencia entre un usuario normal y `root`.
- [ ] Sé cómo iniciar, detener y revisar el estado de un servicio con `systemctl`.
- [ ] Entiendo cómo leer logs básicos para buscar errores.
