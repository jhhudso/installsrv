-- Revert meatPacker:computers from pg

BEGIN;

DROP VIEW v_computers;
DROP TABLE computers;

COMMIT;
