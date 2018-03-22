-- Deploy meatPacker:manufacturers to pg

BEGIN;

CREATE TABLE manufacturers (
    manufacturer_id serial PRIMARY KEY,
    name text UNIQUE NOT NULL
);

-- Read-Only user can select
GRANT SELECT ON manufacturers TO inventory_ro;
GRANT SELECT ON SEQUENCE manufacturers_manufacturer_id_seq TO inventory_ro;

-- Read-Write user can insert/update/delete and manipulate the sequence
GRANT SELECT,INSERT,UPDATE,DELETE ON manufacturers TO inventory_rw;
GRANT USAGE ON SEQUENCE manufacturers_manufacturer_id_seq TO inventory_rw;

COMMIT;
