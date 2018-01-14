-- Revert meatPacker:cycle_units from pg

BEGIN;

drop type cycle_units;

COMMIT;
