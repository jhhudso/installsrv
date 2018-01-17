-- Verify meatPacker:cpus on pg

BEGIN;

SELECT computer_id, model, cores, threads_per_core, speed, speed_unit
  FROM cpus
 WHERE FALSE;

ROLLBACK;
