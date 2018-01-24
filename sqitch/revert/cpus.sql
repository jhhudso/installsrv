-- Revert meatPacker:cpus from pg

BEGIN;

REVOKE SELECT ON SEQUENCE cpus_cpu_id_seq TO inventory_ro;
REVOKE USAGE ON SEQUENCE cpus_cpu_id_seq TO inventory_rw;

DROP TABLE cpus;

COMMIT;
