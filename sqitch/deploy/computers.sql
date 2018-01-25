-- Deploy meatPacker:computers to pg

BEGIN;

CREATE TABLE computers (    
    computer_id bigserial PRIMARY KEY,
    baseboard_model text NOT NULL,    
    baseboard_sn text NULL,
    baseboard_product_name text NULL,
    baseboard_manufacturer text NULL,
    chassis_manufacturer text NULL,
    chassis_type text NULL,
    chassis_version text NULL,
    chassis_sn text NULL,
    chassis_asset_tag text NULL,
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
