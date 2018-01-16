-- Revert meatPacker:size_units from pg

BEGIN;

drop type size_units;

COMMIT;
