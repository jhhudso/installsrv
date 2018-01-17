-- Verify meatPacker:drives on pg

BEGIN;

-- Check for drive_types enum first
SELECT EXISTS (
    SELECT enum_range(NULL::drive_types)
);

-- Spinning rust is the lowest possible state
SELECT 'HDD' :: drive_types = 'HDD' :: drive_types;
SELECT 'HDD' :: drive_types < 'SSD' :: drive_types;
SELECT 'HDD' :: drive_types < 'NVME' :: drive_types;

-- Solid state drives are nice
SELECT 'SSD' :: drive_types > 'HDD' :: drive_types;
SELECT 'SSD' :: drive_types = 'SSD' :: drive_types;
SELECT 'SSD' :: drive_types < 'NVME' :: drive_types;

-- NVME is the bees knees today
SELECT 'NVME' :: drive_types > 'HDD' :: drive_types;
SELECT 'NVME' :: drive_types > 'SSD' :: drive_types;
SELECT 'NVME' :: drive_types = 'NVME' :: drive_types;

--Check that the required columns are a part of the table
SELECT computer_id, model, size, size_unit, type, sn
  FROM drives
 WHERE FALSE;

ROLLBACK;
