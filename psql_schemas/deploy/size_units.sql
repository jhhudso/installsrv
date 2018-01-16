-- Deploy meatPacker:size_units to pg

BEGIN;

create type size_units as enum (
      'B'
    , 'KB'
    , 'MB'
    , 'GB'
    , 'TB'
    , 'PB'
);

COMMIT;
