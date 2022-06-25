-- Revert compinvent:size_units from pg

BEGIN;

DROP TYPE size_units;

COMMIT;
