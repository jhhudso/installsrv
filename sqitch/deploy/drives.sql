-- Deploy meatPacker:drives to pg
-- requires: size_units
-- requires: computers

BEGIN;

CREATE TYPE drive_types AS enum (
    'Unknown',
    'HDD',
    'SSD',
    'NVME',
    'ROM'
);

CREATE TABLE drives (
    drive_id bigserial PRIMARY KEY,
    computer_id bigint NOT NULL REFERENCES computers,
    model text NULL,
    size bigint NOT NULL,
    size_unit size_units NOT NULL,
    type drive_types NOT NULL,
    sn text NULL,
    rpm int NULL
);

-- Read-Only user can select
GRANT SELECT ON drives TO inventory_ro;
GRANT SELECT ON SEQUENCE drives_drive_id_seq TO inventory_ro;

-- Read-Write user can insert/update/delete
GRANT SELECT,INSERT,UPDATE,DELETE ON drives TO inventory_rw;
GRANT USAGE ON SEQUENCE drives_drive_id_seq TO inventory_rw;

COMMIT;
