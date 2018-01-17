-- Revert meatPacker:memory from pg

BEGIN;

DROP TABLE memory;

DROP TYPE memory_types;

COMMIT;
