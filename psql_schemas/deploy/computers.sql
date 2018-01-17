-- Deploy meatPacker:computers to pg

BEGIN;

CREATE TABLE computers (    
    computer_id bigserial PRIMARY KEY,
    motherboard_model text NOT NULL,    
    motherboard_sn text NULL,
    os text NULL,
    barcode bigint UNIQUE
);

COMMIT;
