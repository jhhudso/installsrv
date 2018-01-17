-- Deploy meatPacker:drives to pg
-- requires: size_units
-- requires: computers

BEGIN;

CREATE TYPE drive_types AS enum (
    'HDD',
    'SSD',
    'NVME'
);

CREATE TABLE drives (
    computer_id bigint REFERENCES computers,
    model text NOT NULL,
    size text NOT NULL,
    size_unit size_units NOT NULL,
    type drive_types NOT NULL,
    sn text NOT NULL,
    rpm int NULL
);

COMMIT;
