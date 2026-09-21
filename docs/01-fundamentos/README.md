# 🧱 Módulo 01: Fundamentos Generales

Antes de interactuar con servidores, contenedores o bases de datos, es crucial entender el ecosistema en el que vamos a trabajar. Este módulo asegura que todo el semillero hable el mismo idioma.

## 1. El Modelo Cliente-Servidor
Toda nuestra arquitectura en **FOTON-IA** se basa en este modelo. 
* **Servidor:** Una computadora (nuestras máquinas virtuales en Proxmox) diseñada para procesar solicitudes, almacenar datos y estar encendida 24/7.
* **Cliente:** Cualquier dispositivo (un sensor IoT en la quebrada, o tu navegador web abriendo Grafana) que solicita recursos.

## 2. Entornos de Texto (CLI) vs. Gráficos (GUI)
En infraestructura profesional y Alta Disponibilidad, **no usamos interfaces gráficas**. Todo se administra mediante la Interfaz de Línea de Comandos (CLI). ¿Por qué?
* Consume menos recursos de RAM y CPU.
* Es más segura (menos software = menos vulnerabilidades).
* Permite automatizar tareas mediante scripts.

## 3. ¿Qué es la Virtualización?
FOTON-IA no corre directamente sobre el hardware físico tradicional. Utilizamos **Proxmox VE**, un hipervisor que nos permite dividir un servidor potente en múltiples "Servidores Virtuales" (VM1, VM2, VM3). 

## 4. El concepto de "Alta Disponibilidad" (HA)
En FOTON-IA diseñamos el sistema asumiendo que **los servidores van a fallar**. La Alta Disponibilidad es el conjunto de tecnologías (Keepalived, Replicación, Quórum) que permiten que un servidor de respaldo asuma el trabajo en segundos si el principal se apaga, evitando la pérdida de telemetría.

---
### 🏁 Checklist de nivelación
- [ ] Entiendo la diferencia entre cliente y servidor.
- [ ] Comprendo por qué administramos todo por consola (CLI).
- [ ] Entiendo qué es la Alta Disponibilidad.

➡️ **[Ir al Módulo 02 - Linux](../02-linux/README.md)**
