-- Revert meatPacker:computers from pg

BEGIN;

drop table computers;

COMMIT;
