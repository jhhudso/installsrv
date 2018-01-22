-- Revert meatPacker:cpus from pg

BEGIN;

DROP TABLE cpus;

COMMIT;
