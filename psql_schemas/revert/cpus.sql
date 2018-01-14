-- Revert meatPacker:cpus from pg

BEGIN;

drop table cpus;

COMMIT;
