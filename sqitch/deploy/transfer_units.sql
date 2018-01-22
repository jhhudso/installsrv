-- Deploy meatPacker:transfer_units to pg

BEGIN;

CREATE TYPE transfer_units AS enum (
    'T/s',  -- 1 transfer per second
    'KT/s', -- 1,000 transfers per second
    'MT/s', -- 1,000,000 transfers per second
    'GT/s', -- 1,000,000,000 transfers per second
    'TT/s', -- 1,000,000,000,000 transfers per second
    'PT/s'  -- 1,000,000,000,000,000 transfers per second
);

COMMIT;
