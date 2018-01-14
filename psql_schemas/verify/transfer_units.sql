-- Verify meatPacker:transfer_units on pg

BEGIN;

select exists (
    select enum_range(NULL::transfer_units)
);

-- Make sure ordering is sane

select 'T/s' :: transfer_units = 'T/s' :: transfer_units;
select 'T/s' :: transfer_units < 'KT/s' :: transfer_units;
select 'T/s' :: transfer_units < 'MT/s' :: transfer_units;
select 'T/s' :: transfer_units < 'GT/s' :: transfer_units;
select 'T/s' :: transfer_units < 'TT/s' :: transfer_units;
select 'T/s' :: transfer_units < 'PT/s' :: transfer_units;

select 'KT/s' :: transfer_units > 'T/s' :: transfer_units;
select 'KT/s' :: transfer_units = 'KT/s' :: transfer_units;
select 'KT/s' :: transfer_units < 'MT/s' :: transfer_units;
select 'KT/s' :: transfer_units < 'GT/s' :: transfer_units;
select 'KT/s' :: transfer_units < 'TT/s' :: transfer_units;
select 'KT/s' :: transfer_units < 'PT/s' :: transfer_units;

select 'MT/s' :: transfer_units > 'T/s' :: transfer_units;
select 'MT/s' :: transfer_units > 'KT/s' :: transfer_units;
select 'MT/s' :: transfer_units = 'MT/s' :: transfer_units;
select 'MT/s' :: transfer_units < 'GT/s' :: transfer_units;
select 'MT/s' :: transfer_units < 'TT/s' :: transfer_units;
select 'MT/s' :: transfer_units < 'PT/s' :: transfer_units;

select 'GT/s' :: transfer_units > 'T/s' :: transfer_units;
select 'GT/s' :: transfer_units > 'KT/s' :: transfer_units;
select 'GT/s' :: transfer_units > 'MT/s' :: transfer_units;
select 'GT/s' :: transfer_units = 'GT/s' :: transfer_units;
select 'GT/s' :: transfer_units < 'TT/s' :: transfer_units;
select 'GT/s' :: transfer_units < 'PT/s' :: transfer_units;

select 'TT/s' :: transfer_units > 'T/s' :: transfer_units;
select 'TT/s' :: transfer_units > 'KT/s' :: transfer_units;
select 'TT/s' :: transfer_units > 'MT/s' :: transfer_units;
select 'TT/s' :: transfer_units > 'GT/s' :: transfer_units;
select 'TT/s' :: transfer_units = 'TT/s' :: transfer_units;
select 'TT/s' :: transfer_units < 'PT/s' :: transfer_units;

select 'PT/s' :: transfer_units > 'T/s' :: transfer_units;
select 'PT/s' :: transfer_units > 'KT/s' :: transfer_units;
select 'PT/s' :: transfer_units > 'MT/s' :: transfer_units;
select 'PT/s' :: transfer_units > 'GT/s' :: transfer_units;
select 'PT/s' :: transfer_units > 'TT/s' :: transfer_units;
select 'PT/s' :: transfer_units = 'PT/s' :: transfer_units;

ROLLBACK;
