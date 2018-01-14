-- Deploy meatPacker:memory to pg
-- requires: size_units
-- requires: transfer_units
-- requires: computers

BEGIN;

create type memory_types as enum (
      'DDR'
    , 'DDR2'
    , 'DDR3'
    , 'DDR4'
);

create table memory (
      computer_id bigint references computers
    , model text null
    , mem_speed bigint not null
    , speed_unit transfer_units not null
    , mem_size bigint not null
    , size_unit size_units not null
    , mem_type memory_types not null
);

COMMIT;
