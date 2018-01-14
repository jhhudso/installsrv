-- Verify meatPacker:drives on pg

BEGIN;

-- Check for drive_types enum first
select exists (
    select enum_range(NULL::drive_types)
);

-- Spinning rust is the lowest possible state
select 'HDD' :: drive_types = 'HDD' :: drive_types;
select 'HDD' :: drive_types < 'SSD' :: drive_types;
select 'HDD' :: drive_types < 'NVME' :: drive_types;

-- Solid state drives are nice
select 'SSD' :: drive_types > 'HDD' :: drive_types;
select 'SSD' :: drive_types = 'SSD' :: drive_types;
select 'SSD' :: drive_types < 'NVME' :: drive_types;

-- NVME is the bees knees today
select 'NVME' :: drive_types > 'HDD' :: drive_types;
select 'NVME' :: drive_types > 'SSD' :: drive_types;
select 'NVME' :: drive_types = 'NVME' :: drive_types;

--Check that the required columns are a part of the table
select computer_id, model, drive_size, size_unit, drive_type, sn
  from drives
 where FALSE;

ROLLBACK;
