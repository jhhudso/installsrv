-- Revert compinvent:memory from pg

BEGIN;

REVOKE SELECT ON SEQUENCE memory_memory_id_seq FROM inventory_ro;
REVOKE USAGE ON SEQUENCE memory_memory_id_seq FROM inventory_rw;

DROP TABLE memory;

DROP TYPE memory_types;

COMMIT;
