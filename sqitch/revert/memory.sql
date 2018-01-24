-- Revert meatPacker:memory from pg

BEGIN;

REVOKE SELECT ON SEQUENCE memory_memory_id_seq TO inventory_ro;
REVOKE USAGE ON SEQUENCE memory_memory_id_seq TO inventory_rw;

DROP TABLE memory;

DROP TYPE memory_types;

COMMIT;
