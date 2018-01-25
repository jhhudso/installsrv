-- Verify meatPacker:computers on pg

BEGIN;

SELECT
    computer_id,
    system_manufacturer,
    system_product_name,
    system_version,
    system_sn,
    baseboard_manufacturer,
    baseboard_product_name,
    baseboard_version,
    baseboard_sn,
    baseboard_asset_tag,
    chassis_manufacturer,
    chassis_type,
    chassis_version,
    chassis_sn,
    chassis_asset_tag,
    os,
    barcode
FROM
    computers
WHERE
    FALSE;

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
