-- Revert compinvent:computers from pg

BEGIN;

DROP VIEW v_computers;
DROP TABLE computers;
DROP FUNCTION delete_computers;

COMMIT;
