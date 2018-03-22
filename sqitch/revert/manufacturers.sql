-- Revert meatPacker:manufacturers from pg

BEGIN;

DROP TABLE manufacturers;

COMMIT;
