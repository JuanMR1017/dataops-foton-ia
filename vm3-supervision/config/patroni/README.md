# etcd en VM3 (nodo testigo del DCS de Patroni)

VM3 aloja el tercer nodo del clúster `etcd` que usa Patroni para el consenso de liderazgo
(junto con las instancias de etcd en VM1 y VM2). Esto le da al clúster un quórum impar de 3,
consistente con el rol de VM3 como testigo en el resto de la arquitectura (Redis Sentinel también
corre aquí por la misma razón).

Instalación de referencia: https://etcd.io/docs/latest/install/
