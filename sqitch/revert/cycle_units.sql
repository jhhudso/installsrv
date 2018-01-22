-- Revert meatPacker:cycle_units from pg

BEGIN;

DROP TYPE cycle_units;

COMMIT;
