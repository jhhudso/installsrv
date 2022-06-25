-- Deploy compinvent:cycle_units to pg

BEGIN;

CREATE TYPE cycle_units AS enum (
    'Hz',  -- 1 hertz (cycles per second)
    'KHz', -- 1,000,000 hertz
    'MHz', -- 1,000,000,000 hertz
    'GHz', -- 1,000,000,000,000 herz
    'THz', -- 1,000,000,000,000,000 hertz
    'PHz'  -- 1,000,000,000,000,000,000 hertz
);

COMMIT;
