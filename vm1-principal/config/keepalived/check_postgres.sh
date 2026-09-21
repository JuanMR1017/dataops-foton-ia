#!/bin/bash
# Verifica que PostgreSQL local esté respondiendo antes de reclamar/mantener la VIP.
# Instalar en /etc/keepalived/scripts/check_postgres.sh (ejecutable: chmod +x) en VM1 y VM2.
pg_isready -q -h 127.0.0.1 -p 5432
exit $?
