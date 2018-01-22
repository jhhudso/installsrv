-- Deploy meatPacker:size_units to pg

BEGIN;

CREATE TYPE size_units AS enum (
    'B',   -- 1 byte
    'KB',  -- 1000 bytes
    'KiB', -- 1024 bytes
    'MB',  -- 1000000 bytes
    'MiB', -- 1048576 bytes
    'GB',  -- 1000000000 bytes
    'GiB', -- 1073741824 bytes
    'TB',  -- 1000000000000 bytes
    'TiB', -- 1099511627776 bytes
    'PB',  -- 1000000000000000 bytes
    'PiB'  -- 1125899906842624 bytes
);

COMMIT;
