-- Revert meatPacker:transfer_units from pg

BEGIN;

DROP TYPE transfer_units;

COMMIT;
