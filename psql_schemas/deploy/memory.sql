-- Deploy meatPacker:memory to pg
-- requires: size_units
-- requires: transfer_units
-- requires: computers

BEGIN;

CREATE TYPE memory_types AS enum (
    'DDR',
    'DDR2',
    'DDR3',
    'DDR4'
);

CREATE TABLE memory (
    computer_id bigint REFERENCES computers,
    model text NULL,
    speed bigint NOT NULL,
    speed_unit transfer_units NOT NULL,
    size bigint NOT NULL,
    size_unit size_units NOT NULL,
    type memory_types NOT NULL
);

COMMIT;
