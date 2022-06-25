-- Verify compinvent:transfer_units on pg

BEGIN;

SELECT EXISTS (
    SELECT enum_range(NULL::transfer_units)
);

-- Make sure ordering is sane

SELECT 'T/s'::transfer_units = 'T/s'::transfer_units;
SELECT 'T/s'::transfer_units < 'KT/s'::transfer_units;
SELECT 'T/s'::transfer_units < 'MT/s'::transfer_units;
SELECT 'T/s'::transfer_units < 'GT/s'::transfer_units;
SELECT 'T/s'::transfer_units < 'TT/s'::transfer_units;
SELECT 'T/s'::transfer_units < 'PT/s'::transfer_units;

SELECT 'KT/s'::transfer_units > 'T/s'::transfer_units;
SELECT 'KT/s'::transfer_units = 'KT/s'::transfer_units;
SELECT 'KT/s'::transfer_units < 'MT/s'::transfer_units;
SELECT 'KT/s'::transfer_units < 'GT/s'::transfer_units;
SELECT 'KT/s'::transfer_units < 'TT/s'::transfer_units;
SELECT 'KT/s'::transfer_units < 'PT/s'::transfer_units;

SELECT 'MT/s'::transfer_units > 'T/s'::transfer_units;
SELECT 'MT/s'::transfer_units > 'KT/s'::transfer_units;
SELECT 'MT/s'::transfer_units = 'MT/s'::transfer_units;
SELECT 'MT/s'::transfer_units < 'GT/s'::transfer_units;
SELECT 'MT/s'::transfer_units < 'TT/s'::transfer_units;
SELECT 'MT/s'::transfer_units < 'PT/s'::transfer_units;

SELECT 'GT/s'::transfer_units > 'T/s'::transfer_units;
SELECT 'GT/s'::transfer_units > 'KT/s'::transfer_units;
SELECT 'GT/s'::transfer_units > 'MT/s'::transfer_units;
SELECT 'GT/s'::transfer_units = 'GT/s'::transfer_units;
SELECT 'GT/s'::transfer_units < 'TT/s'::transfer_units;
SELECT 'GT/s'::transfer_units < 'PT/s'::transfer_units;

SELECT 'TT/s'::transfer_units > 'T/s'::transfer_units;
SELECT 'TT/s'::transfer_units > 'KT/s'::transfer_units;
SELECT 'TT/s'::transfer_units > 'MT/s'::transfer_units;
SELECT 'TT/s'::transfer_units > 'GT/s'::transfer_units;
SELECT 'TT/s'::transfer_units = 'TT/s'::transfer_units;
SELECT 'TT/s'::transfer_units < 'PT/s'::transfer_units;

SELECT 'PT/s'::transfer_units > 'T/s'::transfer_units;
SELECT 'PT/s'::transfer_units > 'KT/s'::transfer_units;
SELECT 'PT/s'::transfer_units > 'MT/s'::transfer_units;
SELECT 'PT/s'::transfer_units > 'GT/s'::transfer_units;
SELECT 'PT/s'::transfer_units > 'TT/s'::transfer_units;
SELECT 'PT/s'::transfer_units = 'PT/s'::transfer_units;

ROLLBACK;
