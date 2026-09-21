#!/bin/bash
# Ejecutar en VM2 para clonar la base de datos de VM1 y dejarla como standby.
# Ver documentación: docs/07-bases-datos/postgresql.md
# AJUSTAR: IP_VM1 y la ruta de datos según la versión de PostgreSQL instalada.

set -e
IP_VM1="192.168.1.10"
PGDATA="/var/lib/postgresql/16/main"

echo "Deteniendo PostgreSQL local en VM2..."
sudo systemctl stop postgresql

echo "Respaldando y vaciando el directorio de datos actual..."
sudo mv "$PGDATA" "${PGDATA}.bak.$(date +%s)"

echo "Clonando datos desde VM1 (PRIMARY)..."
sudo -u postgres pg_basebackup -h "$IP_VM1" -D "$PGDATA" -U repl_user -P -R -X stream

echo "Arrancando PostgreSQL en modo standby..."
sudo systemctl start postgresql

echo "Verificando modo standby (debe imprimir 't'):"
sudo -u postgres psql -c "SELECT pg_is_in_recovery();"
