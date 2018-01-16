-- Revert meatPacker:drives from pg

BEGIN;

drop table drives;

drop type drive_types;

COMMIT;
