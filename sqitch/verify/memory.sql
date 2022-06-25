-- Verify compinvent:memory on pg

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
    memory_id,
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

-- Read-Only user can only select from this table
SELECT has_table_privilege('inventory_ro', 'memory', 'select');
SELECT has_sequence_privilege('inventory_ro', 'memory_memory_id_seq', 'select');
SELECT NOT has_table_privilege('inventory_ro', 'memory', 'insert');
SELECT NOT has_table_privilege('inventory_ro', 'memory', 'update');
SELECT NOT has_table_privilege('inventory_ro', 'memory', 'delete');

-- Read-Write user can do many things
SELECT has_table_privilege('inventory_rw', 'memory', 'select, insert, update, delete');
SELECT has_sequence_privilege('inventory_rw', 'memory_memory_id_seq', 'usage');
SELECT NOT has_sequence_privilege('inventory_rw', 'memory_memory_id_seq', 'update');

ROLLBACK;
