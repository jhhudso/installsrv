-- Deploy meatPacker:computers to pg

BEGIN;

create table computers (
      computer_id bigserial primary key
    , os text null
    , motherboard_model text not null
    , motherboard_sn text null
    , barcode bigint unique
);

COMMIT;
