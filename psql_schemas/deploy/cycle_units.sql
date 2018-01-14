-- Deploy meatPacker:cycle_units to pg

BEGIN;

create type cycle_units as enum (
      'Hz'
    , 'KHz'
    , 'MHz'
    , 'GHz'
    , 'THz'
    , 'PHz'
);

COMMIT;
