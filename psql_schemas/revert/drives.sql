-- Revert meatPacker:drives from pg

BEGIN;

DROP TABLE drives;

DROP TYPE drive_types;

COMMIT;
