-- Revert meatPacker:computers from pg

BEGIN;

DROP TABLE computers;

COMMIT;
