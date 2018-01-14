-- Deploy meatPacker:cpus to pg
-- requires: cycle_units
-- requires: computers

BEGIN;

create table cpus (
      computer_id bigint references computers
    , model text not null
    , core_count int not null
    , threads_per_core int not null
    , speed bigint not null
    , speed_unit cycle_units not null
);

COMMIT;
