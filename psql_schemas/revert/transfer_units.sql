-- Revert meatPacker:transfer_units from pg

BEGIN;

drop type transfer_units;

COMMIT;
