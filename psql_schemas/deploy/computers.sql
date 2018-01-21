-- Deploy meatPacker:computers to pg

BEGIN;

CREATE TABLE computers (    
    computer_id bigserial PRIMARY KEY,
    motherboard_model text NOT NULL,    
    motherboard_sn text NULL,
    os text NULL,
    barcode bigint UNIQUE
);

-- Read-Only user can select
GRANT SELECT ON computers TO inventory_ro;
GRANT SELECT ON SEQUENCE computers_computer_id_seq TO inventory_ro;

-- Read-Write user can insert/update/delete and manipulate the sequence
GRANT SELECT,INSERT,UPDATE,DELETE ON computers TO inventory_rw;
GRANT USAGE ON SEQUENCE computers_computer_id_seq TO inventory_rw;

COMMIT;
