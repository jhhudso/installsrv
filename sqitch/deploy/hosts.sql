-- Deploy compinvent:hosts to pg

BEGIN;

-- XXX Add DDLs here.

CREATE TABLE hosts (host_id bigserial PRIMARY KEY, fqdn text, hostname text NOT NULL, computer_id bigint references computers NOT NULL, ip inet, updated_at timestamptz default now());

-- Read-Only user can select
GRANT SELECT ON hosts TO inventory_ro;
GRANT SELECT ON SEQUENCE hosts_host_id_seq TO inventory_ro;

-- Read-Write user can insert/update/delete and manipulate the sequence
GRANT SELECT,INSERT,UPDATE,DELETE ON hosts TO inventory_rw;
GRANT USAGE ON SEQUENCE hosts_host_id_seq TO inventory_rw;

COMMIT;
