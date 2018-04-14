-- Deploy meatPacker:memory to pg
-- requires: size_units
-- requires: transfer_units
-- requires: computers

BEGIN;

CREATE TYPE memory_types AS enum (
    'RAM',
    'Unknown',
    'DDR',
    'DDR2',
    'DDR3',
    'DDR4'
);

CREATE TABLE memory (
    memory_id bigserial PRIMARY KEY,
    computer_id bigint NOT NULL REFERENCES computers,
    model text NULL,
    speed bigint NULL,
    speed_unit transfer_units NULL,
    size bigint NULL,
    size_unit size_units NULL,
    type memory_types NULL,   
    form_factor text NULL,
    locator text NULL,
    manufacturer text NULL,
    sn text NULL,
    part_number text NULL,
    rank text NULL 
);

-- Read-Only user can select
GRANT SELECT ON memory TO inventory_ro;
GRANT SELECT ON memory_memory_id_seq TO inventory_ro;

-- Read-Write user can insert/update/delete
GRANT SELECT,INSERT,UPDATE,DELETE ON memory TO inventory_rw;
GRANT USAGE ON memory_memory_id_seq TO inventory_rw;

COMMIT;
