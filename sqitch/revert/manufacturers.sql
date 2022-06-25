-- Revert compinvent:manufacturers from pg

BEGIN;

DROP TABLE manufacturers;

COMMIT;
