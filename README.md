# 🚀 Semillero DataOps — Proyecto FOTON-IA
## Arquitectura de Alta Disponibilidad (Fase 1: Estudio y Herramientas)

¡Bienvenidos al repositorio oficial del equipo de Infraestructura y DataOps para el proyecto FOTON-IA! 

Este proyecto busca diseñar e implementar una arquitectura de Alta Disponibilidad (HA) sobre Proxmox VE para el sistema de monitoreo inteligente de aguas residuales en la quebrada la Picacha.

---

### 📌 Sobre este Repositorio
Este repositorio **no es solo para guardar código**. Es una guía de aprendizaje estructurada. 
Antes de tocar los servidores, cada integrante debe comprender qué tecnologías usamos, cómo funcionan y qué rol cumplen en la arquitectura.

### 🏗️ Arquitectura y Equipos
El clúster tiene tres nodos. El semillero se divide en tres grupos:

| Directorio | Rol del Nodo | Responsabilidad |
| :--- | :--- | :--- |
| [📁 `vm1-principal/`](./vm1-principal/) | **Activo** | Ingesta de datos, bases de datos maestras y servicios activos. |
| [📁 `vm2-standby/`](./vm2-standby/) | **Respaldo** | Replicación en tiempo real y asunción de carga ante fallos (Failover). |
| [📁 `vm3-supervision/`](./vm3-supervision/) | **Testigo** | Observabilidad, coordinación de quórum y prevención de *split-brain*. |

---

### 📚 ¿Por dónde empezar?
Si eres un estudiante nuevo en el semillero, no te saltes pasos. Ve directamente a nuestra guía de inicio para ver tu ruta de estudio:

➡️ **[Comenzar aquí: Ruta de Aprendizaje](./docs/00-inicio/README.md)**
