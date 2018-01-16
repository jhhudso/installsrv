-- Deploy meatPacker:transfer_units to pg

BEGIN;

create type transfer_units as enum (
      'T/s'
    , 'KT/s'
    , 'MT/s'
    , 'GT/s'
    , 'TT/s'
    , 'PT/s'
);

COMMIT;
