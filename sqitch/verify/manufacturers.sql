-- Verify meatPacker:manufacturers on pg

BEGIN;

SELECT
    manufacturer_id,
    name
FROM
    manufacturers
WHERE
    FALSE;

-- Read-Only user can only select from this table
SELECT has_table_privilege('inventory_ro', 'manufacturers', 'select');
SELECT has_sequence_privilege('inventory_ro', 'manufacturers_manufacturer_id_seq', 'select');
SELECT NOT has_table_privilege('inventory_ro', 'manufacturers', 'insert');
SELECT NOT has_table_privilege('inventory_ro', 'manufacturers', 'update');
SELECT NOT has_table_privilege('inventory_ro', 'manufacturers', 'delete');
SELECT NOT has_sequence_privilege('inventory_ro', 'manufacturers_manufacturer_id_seq', 'usage');
SELECT NOT has_sequence_privilege('inventory_ro', 'manufacturers_manufacturer_id_seq', 'update');

-- Read-Write user can do many things
SELECT has_table_privilege('inventory_rw', 'manufacturers', 'select, insert, update, delete');
SELECT has_sequence_privilege('inventory_rw', 'manufacturers_manufacturer_id_seq', 'usage');
SELECT NOT has_sequence_privilege('inventory_rw', 'manufacturers_manufacturer_id_seq', 'update');

ROLLBACK;
