-- Deploy meatPacker:cpus to pg
-- requires: cycle_units
-- requires: computers

BEGIN;

CREATE TABLE cpus (
    cpu_id serial,
    computer_id bigint REFERENCES computers,
    model text NOT NULL,
    cores int NOT NULL,
    threads_per_core int NOT NULL,
    speed bigint NOT NULL,
    speed_unit cycle_units NOT NULL
);

-- Read-Only user can select
GRANT SELECT ON cpus TO inventory_ro;
GRANT SELECT on SEQUENCE cpus_cpu_id_seq TO inventory_ro;

-- Read-Write user can insert/update/delete
GRANT SELECT,INSERT,UPDATE,DELETE ON cpus TO inventory_rw;
GRANT USAGE on SEQUENCE cpus_cpu_id_seq TO inventory_rw;

COMMIT;
