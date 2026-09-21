# 🐳 Módulo 05: Docker

## 1. ¿Qué es?
Docker es una plataforma de **contenedores**: empaqueta una aplicación junto con todo lo que necesita para correr (librerías, dependencias, configuración) en una unidad aislada y portable, sin necesitar una máquina virtual completa para cada servicio.

## 2. ¿Por qué lo necesitamos en FOTON-IA?
ChirpStack está compuesto por varios servicios pequeños (Network Server, Gateway Bridge, API) que son mucho más fáciles de instalar, actualizar y **replicar de forma idéntica en VM1 y VM2** usando contenedores, en lugar de instalar cada pieza manualmente en cada nodo y arriesgarnos a que queden configuradas de forma distinta.

## 3. Conceptos básicos
* **Imagen:** Una plantilla inmutable de un contenedor (ej. `postgres:16`).
* **Contenedor:** Una instancia en ejecución de una imagen.
* **Volumen:** Almacenamiento persistente que sobrevive aunque el contenedor se borre (crítico para no perder datos de PostgreSQL).
* **Red de Docker:** Permite que contenedores se comuniquen entre sí por nombre, sin exponer todo a la red física.
* **Docker Compose:** Herramienta para definir y levantar varios contenedores relacionados con un solo archivo `docker-compose.yml`.

## 4. Sistema de archivos / Estructura
* `/var/lib/docker/`: donde Docker guarda imágenes, contenedores y volúmenes por defecto.
* `Dockerfile`: receta para construir una imagen propia.
* `docker-compose.yml`: define qué contenedores, redes y volúmenes se levantan juntos.

## 5. Usuarios y permisos
Por defecto, solo `root` o usuarios del grupo `docker` pueden ejecutar comandos Docker (`sudo usermod -aG docker $USER`). Ojo: pertenecer al grupo `docker` equivale a tener privilegios de root, así que se asigna con cuidado.

## 6. Procesos
El demonio `dockerd` corre en segundo plano y es quien realmente gestiona los contenedores; el comando `docker` que escribes en la terminal es solo un cliente que le habla a ese demonio.

## 7. Servicios
```bash
systemctl status docker      # verifica que el demonio esté activo
systemctl enable docker      # que arranque solo al reiniciar la VM
docker compose up -d         # levanta los servicios definidos en docker-compose.yml
docker compose down          # los detiene y elimina (los volúmenes persisten)
```

## 8. Red
Docker crea redes virtuales internas (bridge) para que los contenedores se hablen por nombre (ej. `chirpstack` se conecta a `postgres:5432` sin necesitar la IP real). Los puertos se exponen al host explícitamente con `-p <host>:<contenedor>`.

## 9. Acceso / SSH
No se accede a Docker por SSH directamente; se administra por SSH a la VM que lo tiene instalado, y desde ahí se ejecutan los comandos `docker`. Para entrar dentro de un contenedor en ejecución: `docker exec -it <contenedor> bash`.

## 10. Logs
```bash
docker logs <contenedor>          # logs de un contenedor específico
docker logs -f <contenedor>       # en tiempo real
docker compose logs -f            # logs de todos los servicios del compose
```

## 11. Bash / Scripting
Un script de verificación rápida de salud de los contenedores del stack:
```bash
docker compose ps --filter "status=running"
```

## 12. Comandos fundamentales
* `docker ps`: contenedores en ejecución.
* `docker ps -a`: incluye los detenidos.
* `docker images`: imágenes descargadas localmente.
* `docker exec -it <contenedor> bash`: entra a la terminal de un contenedor.
* `docker inspect <contenedor>`: detalles completos (red, volúmenes, variables).
* `docker compose up -d` / `docker compose down`: levantar/bajar el stack completo.
* `docker system prune`: limpia imágenes y contenedores no usados (libera espacio).

## 13. Prácticas
1. Instala Docker en una VM de prueba.
2. Levanta un contenedor simple: `docker run -d -p 8080:80 nginx`.
3. Verifica que responde con `curl localhost:8080`.
4. Detén y elimina el contenedor con `docker stop` y `docker rm`.

## 14. Errores frecuentes
* **Perder datos al borrar un contenedor** por no haber definido un volumen persistente.
* **Conflicto de puertos:** dos servicios intentando usar el mismo puerto del host.
* **Olvidar reconstruir la imagen** (`docker compose build`) después de cambiar un `Dockerfile`.
* **No hay espacio en disco:** las imágenes y logs de contenedores pueden llenar `/var/lib/docker/` si nunca se limpian.

## 15. Troubleshooting
1. ¿El demonio está corriendo? (`systemctl status docker`).
2. ¿El contenedor está levantado? (`docker ps -a`).
3. ¿Qué dice su log? (`docker logs <contenedor>`).
4. ¿Puede alcanzar a otros contenedores? (`docker exec -it <contenedor> ping <otro-servicio>`).

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Al containerizar ChirpStack y sus dependencias, garantizamos que la VM2 pueda tener **exactamente la misma versión y configuración** que la VM1, lista para activarse en segundos si hay un failover, en lugar de depender de una instalación manual propensa a diferencias sutiles entre nodos.

## 17. Documentación oficial
* [Docker Docs](https://docs.docker.com/)
* [Docker Compose Docs](https://docs.docker.com/compose/)

## 18. Checklist
- [ ] Entiendo la diferencia entre imagen y contenedor.
- [ ] Sé levantar y bajar un stack con `docker compose`.
- [ ] Sé revisar logs de un contenedor para diagnosticar un problema.
- [ ] Entiendo por qué los volúmenes son necesarios para no perder datos.

➡️ **[Ir al Módulo 06 - Protocolos IoT](../06-protocolos-iot/README.md)**
