# 🌿 Módulo 04: Git y GitHub

## 1. ¿Qué es?
Git es un sistema de control de versiones distribuido: guarda un historial completo de cambios de un proyecto y permite que varias personas trabajen en paralelo sin sobrescribirse. GitHub es la plataforma donde alojamos ese historial en la nube y colaboramos (issues, pull requests, revisión de código).

## 2. ¿Por qué lo necesitamos en FOTON-IA?
Este mismo repositorio es la prueba: varios grupos documentan y, más adelante, escriben configuraciones y scripts en paralelo (VM1, VM2, VM3). Sin Git, sería imposible combinar el trabajo de todos sin pisarse los cambios o perder versiones anteriores de un `keepalived.conf` que funcionaba.

## 3. Conceptos básicos
* **Repositorio (repo):** La carpeta del proyecto con todo su historial de cambios.
* **Commit:** Una "fotografía" guardada de los cambios, con un mensaje descriptivo.
* **Branch (rama):** Una línea de desarrollo independiente (ej. `feature/vm2-keepalived`) que no afecta a `main` hasta que se combina.
* **Pull Request (PR):** Una propuesta de combinar una rama con otra, que el equipo revisa antes de aceptar.
* **Merge:** La acción de combinar los cambios de una rama en otra.
* **Clone / Remote:** Copiar un repositorio de GitHub a tu computador, manteniendo el enlace ("remoto") con la versión en la nube.

## 4. Sistema de archivos / Estructura
Git guarda todo su historial en una carpeta oculta `.git/` dentro del repositorio. El archivo `.gitignore` en la raíz define qué archivos **no** deben subirse nunca (ej. contraseñas, archivos temporales, `node_modules/`).

## 5. Usuarios y permisos
En GitHub, el dueño del repositorio (u organización) define roles: `Read`, `Write`, `Admin`. En FOTON-IA, cada grupo tiene permiso de `Write` para crear ramas y PRs, pero **nadie hace `push` directo a `main`**: todo cambio pasa por PR y revisión.

## 6. Procesos
Git no corre como un servicio en segundo plano; es una herramienta que se ejecuta bajo demanda desde la terminal (`git <comando>`) cada vez que guardas o sincronizas cambios.

## 7. Servicios
No aplica un `systemctl` para Git en sí. Lo más cercano es el "hook" (`.git/hooks/`), scripts opcionales que se disparan automáticamente antes o después de un commit/push (ej. para validar formato antes de subir).

## 8. Red
Git se comunica con GitHub por HTTPS (puerto 443) o SSH (puerto 22), dependiendo de cómo configures el remoto (`https://github.com/...` vs `git@github.com:...`).

## 9. Acceso / SSH
Para no escribir usuario y contraseña en cada `push`, se recomienda configurar una **llave SSH** (`ssh-keygen`) asociada a tu cuenta de GitHub, o un **Personal Access Token** si usas HTTPS.

## 10. Logs
* `git log`: historial de commits.
* `git log --oneline --graph --all`: historial visual con ramas.
* `git reflog`: historial de movimientos locales (útil para recuperar un commit "perdido").

## 11. Bash / Scripting
Flujo típico de trabajo para un integrante del semillero:
```bash
git checkout main
git pull origin main
git checkout -b feature/vm2-inventario
# ... se editan archivos ...
git add .
git commit -m "docs(vm2): agregar inventario de herramientas"
git push origin feature/vm2-inventario
# luego se abre el Pull Request en GitHub
```

## 12. Comandos fundamentales
* `git clone <url>`: descarga un repositorio existente.
* `git status`: muestra qué archivos cambiaron.
* `git add <archivo>`: prepara un archivo para el commit.
* `git commit -m "mensaje"`: guarda los cambios preparados.
* `git pull`: trae los cambios más recientes del remoto.
* `git push`: sube tus commits al remoto.
* `git branch`: lista o crea ramas.
* `git diff`: muestra los cambios línea por línea antes de confirmarlos.

## 13. Prácticas
1. Clona este repositorio en tu computador.
2. Crea una rama con tu nombre: `git checkout -b practica/tu-nombre`.
3. Crea un archivo de prueba, haz commit y súbelo con `git push`.
4. Abre un Pull Request en GitHub (no hace falta que se combine, es solo práctica).

## 14. Errores frecuentes
* **Hacer `push` directo a `main`:** rompe el flujo de revisión del equipo.
* **Mensajes de commit vacíos o poco claros** (ej. "cambios"): dificulta rastrear qué pasó.
* **Conflictos de merge sin resolver correctamente:** aceptar un conflicto sin leerlo puede borrar el trabajo de un compañero.
* **Subir archivos sensibles** (contraseñas, IPs internas) sin usar `.gitignore`.

## 15. Troubleshooting
1. `git status` — ¿qué está pasando ahora mismo?
2. `git log --oneline -5` — ¿cuáles fueron los últimos commits?
3. Si hay conflicto: abrir el archivo, buscar las marcas `<<<<<<<`, `=======`, `>>>>>>>`, decidir qué conservar, y hacer `git add` + `git commit`.
4. Si algo salió muy mal: `git reflog` para encontrar el commit anterior y volver con `git reset --hard <hash>` (con cuidado, esto descarta cambios).

## 16. Aplicación en FOTON-IA (Alta Disponibilidad)
Git no participa en el failover en tiempo real, pero es la base de la **trazabilidad**: cada cambio a `keepalived.conf`, `postgresql.conf` o cualquier script de failover queda versionado. Si una configuración nueva rompe la Alta Disponibilidad, el equipo puede revertir (`git revert`) a la última versión conocida como estable.

## 17. Documentación oficial
* [Pro Git Book (gratis, en español)](https://git-scm.com/book/es/v2)
* [GitHub Docs](https://docs.github.com/es)

## 18. Checklist
- [ ] Sé clonar un repositorio y crear una rama propia.
- [ ] Entiendo la diferencia entre `commit`, `push` y `pull`.
- [ ] Sé abrir un Pull Request en GitHub.
- [ ] Entiendo por qué nunca se hace `push` directo a `main`.

➡️ **[Ir al Módulo 05 - Docker](../05-docker/README.md)**
