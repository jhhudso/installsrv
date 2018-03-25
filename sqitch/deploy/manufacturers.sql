-- Deploy meatPacker:manufacturers to pg

BEGIN;

CREATE TABLE manufacturers (
    manufacturer_id serial PRIMARY KEY,
    name text UNIQUE NOT NULL
);

CREATE OR REPLACE FUNCTION add_manufacturer(name text) RETURNS void AS $$
begin
    if name <> null then
        insert into manufacturers (name) values (name);
    end if;
END;
$$ LANGUAGE plpgsql;

-- Read-Only user can select
GRANT SELECT ON manufacturers TO inventory_ro;
GRANT SELECT ON SEQUENCE manufacturers_manufacturer_id_seq TO inventory_ro;

-- Read-Write user can insert/update/delete and manipulate the sequence
GRANT SELECT,INSERT,UPDATE,DELETE ON manufacturers TO inventory_rw;
GRANT USAGE ON SEQUENCE manufacturers_manufacturer_id_seq TO inventory_rw;

COMMIT;
