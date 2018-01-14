-- Verify meatPacker:memory on pg

BEGIN;

select exists (
    select enum_range(NULL::memory_types)
);

select 'DDR' :: memory_types = 'DDR' :: memory_types;
select 'DDR' :: memory_types < 'DDR2' :: memory_types;
select 'DDR' :: memory_types < 'DDR3' :: memory_types;
select 'DDR' :: memory_types < 'DDR4' :: memory_types;

select 'DDR2' :: memory_types > 'DDR' :: memory_types;
select 'DDR2' :: memory_types = 'DDR2' :: memory_types;
select 'DDR2' :: memory_types < 'DDR3' :: memory_types;
select 'DDR2' :: memory_types < 'DDR4' :: memory_types;

select 'DDR3' :: memory_types > 'DDR' :: memory_types;
select 'DDR3' :: memory_types > 'DDR2' :: memory_types;
select 'DDR3' :: memory_types = 'DDR3' :: memory_types;
select 'DDR3' :: memory_types < 'DDR4' :: memory_types;

select 'DDR4' :: memory_types > 'DDR' :: memory_types;
select 'DDR4' :: memory_types > 'DDR2' :: memory_types;
select 'DDR4' :: memory_types > 'DDR3' :: memory_types;
select 'DDR4' :: memory_types = 'DDR4' :: memory_types;

select computer_id, model, mem_speed, speed_unit, mem_size, size_unit, mem_type
  from memory
 where FALSE;

ROLLBACK;
