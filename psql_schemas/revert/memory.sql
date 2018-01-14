-- Revert meatPacker:memory from pg

BEGIN;

drop table memory;

drop type memory_types;

COMMIT;
