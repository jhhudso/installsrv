-- Verify meatPacker:drives on pg

BEGIN;

-- Check for drive_types enum first
SELECT EXISTS (
    SELECT enum_range(NULL::drive_types)
);

-- Spinning rust is the lowest possible state
SELECT 'Unknown' :: drive_types = 'Unknown' :: drive_types;
SELECT 'Unknown' :: drive_types < 'HDD' :: drive_types;
SELECT 'Unknown' :: drive_types < 'SSD' :: drive_types;
SELECT 'Unknown' :: drive_types < 'NVME' :: drive_types;

-- Spinning rust is the lowest possible state
SELECT 'HDD' :: drive_types > 'Unknown' :: drive_types;
SELECT 'HDD' :: drive_types = 'HDD' :: drive_types;
SELECT 'HDD' :: drive_types < 'SSD' :: drive_types;
SELECT 'HDD' :: drive_types < 'NVME' :: drive_types;

-- Solid state drives are nice
SELECT 'SSD' :: drive_types > 'Unknown' :: drive_types;
SELECT 'SSD' :: drive_types > 'HDD' :: drive_types;
SELECT 'SSD' :: drive_types = 'SSD' :: drive_types;
SELECT 'SSD' :: drive_types < 'NVME' :: drive_types;

-- NVME is the bees knees today
SELECT 'NVME' :: drive_types > 'Unknown' :: drive_types;
SELECT 'NVME' :: drive_types > 'HDD' :: drive_types;
SELECT 'NVME' :: drive_types > 'SSD' :: drive_types;
SELECT 'NVME' :: drive_types = 'NVME' :: drive_types;

--Check that the required columns are a part of the table
SELECT drive_id, computer_id, model, size, size_unit, type, sn
  FROM drives
 WHERE FALSE;

-- Read-Only user can only select from this table
SELECT has_table_privilege('inventory_ro', 'drives', 'select');
SELECT has_sequence_privilege('inventory_ro', 'drives_drive_id_seq', 'select');
SELECT NOT has_table_privilege('inventory_ro', 'drives', 'insert');
SELECT NOT has_table_privilege('inventory_ro', 'drives', 'update');
SELECT NOT has_table_privilege('inventory_ro', 'drives', 'delete');

-- Read-Write user can do many things
SELECT has_table_privilege('inventory_rw', 'drives', 'select, insert, update, delete');
SELECT has_sequence_privilege('inventory_rw', 'drives_drive_id_seq', 'usage');
SELECT NOT has_sequence_privilege('inventory_rw', 'drives_drive_id_seq', 'update');

ROLLBACK;
