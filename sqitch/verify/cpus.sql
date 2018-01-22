-- Verify meatPacker:cpus on pg

BEGIN;

SELECT computer_id, model, cores, threads_per_core, speed, speed_unit
  FROM cpus
 WHERE FALSE;

-- Read-Only user can only select from this table
SELECT has_table_privilege('inventory_ro', 'cpus', 'select');
SELECT NOT has_table_privilege('inventory_ro', 'cpus', 'insert');
SELECT NOT has_table_privilege('inventory_ro', 'cpus', 'update');
SELECT NOT has_table_privilege('inventory_ro', 'cpus', 'delete');

-- Read-Write user can do many things
SELECT has_table_privilege('inventory_rw', 'cpus', 'select, insert, update, delete');


ROLLBACK;
