-- Verify meatPacker:computers on pg

BEGIN;

SELECT computer_id, os, motherboard_model, motherboard_sn, barcode
  FROM computers
 WHERE FALSE;

-- Read-Only user can only select from this table
SELECT has_table_privilege('inventory_ro', 'computers', 'select');
SELECT has_sequence_privilege('inventory_ro', 'computers_computer_id_seq', 'select');
SELECT NOT has_table_privilege('inventory_ro', 'computers', 'insert');
SELECT NOT has_table_privilege('inventory_ro', 'computers', 'update');
SELECT NOT has_table_privilege('inventory_ro', 'computers', 'delete');
SELECT NOT has_sequence_privilege('inventory_ro', 'computers_computer_id_seq', 'usage');
SELECT NOT has_sequence_privilege('inventory_ro', 'computers_computer_id_seq', 'update');

-- Read-Write user can do many things
SELECT has_table_privilege('inventory_rw', 'computers', 'select, insert, update, delete');
SELECT has_sequence_privilege('inventory_rw', 'computers_computer_id_seq', 'usage');
SELECT NOT has_sequence_privilege('inventory_rw', 'computers_computer_id_seq', 'update');

ROLLBACK;
