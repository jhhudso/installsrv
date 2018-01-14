-- Verify meatPacker:size_units on pg

BEGIN;

-- Does our enum exist?
select exists (
    select enum_range(NULL::size_units)
);

-- Does the ordering make sense?

-- Bytes are smallest
select 'B' :: size_units = 'B'::size_units;
select 'B' :: size_units < 'KB'::size_units;
select 'B' :: size_units < 'MB'::size_units;
select 'B' :: size_units < 'GB'::size_units;
select 'B' :: size_units < 'TB'::size_units;
select 'B' :: size_units < 'PB'::size_units;

-- Kilo Bytes are the next smallest
select 'KB' :: size_units > 'B'::size_units;
select 'KB' :: size_units = 'KB'::size_units;
select 'KB' :: size_units < 'MB'::size_units;
select 'KB' :: size_units < 'GB'::size_units;
select 'KB' :: size_units < 'TB'::size_units;
select 'KB' :: size_units < 'PB'::size_units;

-- Mega Bytes are the next smallest
select 'MB' :: size_units > 'B'::size_units;
select 'MB' :: size_units > 'KB'::size_units;
select 'MB' :: size_units = 'MB'::size_units;
select 'MB' :: size_units < 'GB'::size_units;
select 'MB' :: size_units < 'TB'::size_units;
select 'MB' :: size_units < 'PB'::size_units;

-- Giga Bytes are the next smallest
select 'GB' :: size_units > 'B'::size_units;
select 'GB' :: size_units > 'KB'::size_units;
select 'GB' :: size_units > 'MB'::size_units;
select 'GB' :: size_units = 'GB'::size_units;
select 'GB' :: size_units < 'TB'::size_units;
select 'GB' :: size_units < 'PB'::size_units;

-- Tera Bytes are the next smallest
select 'TB' :: size_units > 'B'::size_units;
select 'TB' :: size_units > 'KB'::size_units;
select 'TB' :: size_units > 'MB'::size_units;
select 'TB' :: size_units > 'GB'::size_units;
select 'TB' :: size_units = 'TB'::size_units;
select 'TB' :: size_units < 'PB'::size_units;

-- Peta Bytes are the next smallest
select 'PB' :: size_units > 'B'::size_units;
select 'PB' :: size_units > 'KB'::size_units;
select 'PB' :: size_units > 'MB'::size_units;
select 'PB' :: size_units > 'GB'::size_units;
select 'PB' :: size_units > 'TB'::size_units;
select 'PB' :: size_units = 'PB'::size_units;

ROLLBACK;
