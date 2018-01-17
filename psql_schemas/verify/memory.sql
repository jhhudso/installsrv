-- Verify meatPacker:memory on pg

BEGIN;

select exists (
    select enum_range(NULL::memory_types)
);

SELECT
    'DDR'::memory_types = 'DDR'::memory_types;

SELECT
    'DDR'::memory_types < 'DDR2'::memory_types;

SELECT
    'DDR'::memory_types < 'DDR3'::memory_types;

SELECT
    'DDR'::memory_types < 'DDR4'::memory_types;

SELECT
    'DDR2'::memory_types > 'DDR'::memory_types;

SELECT
    'DDR2'::memory_types = 'DDR2'::memory_types;

SELECT
    'DDR2'::memory_types < 'DDR3'::memory_types;

SELECT
    'DDR2'::memory_types < 'DDR4'::memory_types;

SELECT
    'DDR3'::memory_types > 'DDR'::memory_types;

SELECT
    'DDR3'::memory_types > 'DDR2'::memory_types;

SELECT
    'DDR3'::memory_types = 'DDR3'::memory_types;

SELECT
    'DDR3'::memory_types < 'DDR4'::memory_types;

SELECT
    'DDR4'::memory_types > 'DDR'::memory_types;

SELECT
    'DDR4'::memory_types > 'DDR2'::memory_types;

SELECT
    'DDR4'::memory_types > 'DDR3'::memory_types;

SELECT
    'DDR4'::memory_types = 'DDR4'::memory_types;

SELECT
    computer_id,
    model,
    speed,
    speed_unit,
    size,
    size_unit,
    type
FROM
    memory
WHERE
    FALSE;

ROLLBACK;
