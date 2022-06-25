-- Revert compinvent:drives from pg

BEGIN;

REVOKE SELECT ON SEQUENCE drives_drive_id_seq FROM inventory_ro;
REVOKE USAGE ON SEQUENCE drives_drive_id_seq FROM inventory_rw;

DROP TABLE drives;

DROP TYPE drive_types;

COMMIT;
