-- Deploy meatPacker:drives to pg
-- requires: size_units
-- requires: computers

BEGIN;

create type drive_types as enum (
      'HDD'
    , 'SSD'
    , 'NVME'
);

create table drives (
      computer_id bigint references computers
    , model text not null
    , drive_size text not null
    , size_unit size_units not null
    , rpm int null
    , drive_type drive_types not null
    , sn text not null
);

COMMIT;
