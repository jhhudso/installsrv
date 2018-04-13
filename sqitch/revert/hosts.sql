-- Revert meatPacker:hosts from pg

BEGIN;

-- XXX Add DDLs here.
DROP TABLE hosts;


COMMIT;
