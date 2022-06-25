-- Deploy compinvent:transfer_units to pg

BEGIN;

CREATE TYPE transfer_units AS enum (
    'Hz',
    'T/s',  -- 1 transfer per second
    'KHz',
    'KT/s', -- 1,000 transfers per second
    'MHz',
    'MT/s', -- 1,000,000 transfers per second
    'GHz',
    'GT/s', -- 1,000,000,000 transfers per second
    'THz',
    'TT/s', -- 1,000,000,000,000 transfers per second
    'PT/s'  -- 1,000,000,000,000,000 transfers per second
);

COMMIT;
