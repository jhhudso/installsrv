-- Verify meatPacker:cpus on pg

BEGIN;

select computer_id, model, core_count, threads_per_core, speed, speed_unit
  from cpus
 where FALSE;

ROLLBACK;
