-- Verify meatPacker:cycle_units on pg

BEGIN;

-- Hz are the smallest, PHz are the biggest we know of today
SELECT 'Hz'::cycle_units = 'Hz'::cycle_units;
SELECT 'Hz'::cycle_units < 'KHz'::cycle_units;
SELECT 'Hz'::cycle_units < 'MHz'::cycle_units;
SELECT 'Hz'::cycle_units < 'GHz'::cycle_units;
SELECT 'Hz'::cycle_units < 'THz'::cycle_units;
SELECT 'Hz'::cycle_units < 'PHz'::cycle_units;

-- KHz are 1,000Hz
SELECT 'KHz'::cycle_units > 'Hz'::cycle_units;
SELECT 'KHz'::cycle_units = 'KHz'::cycle_units;
SELECT 'KHz'::cycle_units < 'MHz'::cycle_units;
SELECT 'KHz'::cycle_units < 'GHz'::cycle_units;
SELECT 'KHz'::cycle_units < 'THz'::cycle_units;
SELECT 'KHz'::cycle_units < 'PHz'::cycle_units;

-- MHz are 1,000,000Hz
SELECT 'MHz'::cycle_units > 'Hz'::cycle_units;
SELECT 'MHz'::cycle_units > 'KHz'::cycle_units;
SELECT 'MHz'::cycle_units = 'MHz'::cycle_units;
SELECT 'MHz'::cycle_units < 'GHz'::cycle_units;
SELECT 'MHz'::cycle_units < 'THz'::cycle_units;

-- GHz are 1,000,000,000Hz
SELECT 'GHz'::cycle_units > 'Hz'::cycle_units;
SELECT 'GHz'::cycle_units > 'KHz'::cycle_units;
SELECT 'GHz'::cycle_units > 'MHz'::cycle_units;
SELECT 'GHz'::cycle_units = 'GHz'::cycle_units;
SELECT 'GHz'::cycle_units < 'THz'::cycle_units;
SELECT 'GHz'::cycle_units < 'PHz'::cycle_units;

-- THz are 1,000,000,000,000Hz
SELECT 'THz'::cycle_units > 'Hz'::cycle_units;
SELECT 'THz'::cycle_units > 'KHz'::cycle_units;
SELECT 'THz'::cycle_units > 'MHz'::cycle_units;
SELECT 'THz'::cycle_units > 'GHz'::cycle_units;
SELECT 'THz'::cycle_units = 'THz'::cycle_units;
SELECT 'THz'::cycle_units < 'PHz'::cycle_units;

-- PHz are 1,000,000,000,000,000Hz
SELECT 'PHz'::cycle_units > 'Hz'::cycle_units;
SELECT 'PHz'::cycle_units > 'KHz'::cycle_units;
SELECT 'PHz'::cycle_units > 'MHz'::cycle_units;
SELECT 'PHz'::cycle_units > 'GHz'::cycle_units;
SELECT 'PHz'::cycle_units > 'THz'::cycle_units;
SELECT 'PHz'::cycle_units = 'PHz'::cycle_units;

ROLLBACK;
