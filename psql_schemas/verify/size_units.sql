-- Verify meatPacker:size_units on pg
 BEGIN;

-- Does our enum exist?
 SELECT
    EXISTS(
        SELECT
            enum_range(
                NULL::size_units
            )
    );

-- Does the ordering make sense?
 -- Bytes are smallest
 SELECT
    'B'::size_units = 'B'::size_units;

SELECT
    'B'::size_units < 'KB'::size_units;

SELECT
    'B'::size_units < 'MB'::size_units;

SELECT
    'B'::size_units < 'GB'::size_units;

SELECT
    'B'::size_units < 'TB'::size_units;

SELECT
    'B'::size_units < 'PB'::size_units;

-- Kilo Bytes are the next smallest
 SELECT
    'KB'::size_units > 'B'::size_units;

SELECT
    'KB'::size_units = 'KB'::size_units;

SELECT
    'KB'::size_units < 'MB'::size_units;

SELECT
    'KB'::size_units < 'GB'::size_units;

SELECT
    'KB'::size_units < 'TB'::size_units;

SELECT
    'KB'::size_units < 'PB'::size_units;

-- Mega Bytes are the next smallest
 SELECT
    'MB'::size_units > 'B'::size_units;

SELECT
    'MB'::size_units > 'KB'::size_units;

SELECT
    'MB'::size_units = 'MB'::size_units;

SELECT
    'MB'::size_units < 'GB'::size_units;

SELECT
    'MB'::size_units < 'TB'::size_units;

SELECT
    'MB'::size_units < 'PB'::size_units;

-- Giga Bytes are the next smallest
 SELECT
    'GB'::size_units > 'B'::size_units;

SELECT
    'GB'::size_units > 'KB'::size_units;

SELECT
    'GB'::size_units > 'MB'::size_units;

SELECT
    'GB'::size_units = 'GB'::size_units;

SELECT
    'GB'::size_units < 'TB'::size_units;

SELECT
    'GB'::size_units < 'PB'::size_units;

-- Tera Bytes are the next smallest
 SELECT
    'TB'::size_units > 'B'::size_units;

SELECT
    'TB'::size_units > 'KB'::size_units;

SELECT
    'TB'::size_units > 'MB'::size_units;

SELECT
    'TB'::size_units > 'GB'::size_units;

SELECT
    'TB'::size_units = 'TB'::size_units;

SELECT
    'TB'::size_units < 'PB'::size_units;

-- Peta Bytes are the next smallest
 SELECT
    'PB'::size_units > 'B'::size_units;

SELECT
    'PB'::size_units > 'KB'::size_units;

SELECT
    'PB'::size_units > 'MB'::size_units;

SELECT
    'PB'::size_units > 'GB'::size_units;

SELECT
    'PB'::size_units > 'TB'::size_units;

SELECT
    'PB'::size_units = 'PB'::size_units;

ROLLBACK;
