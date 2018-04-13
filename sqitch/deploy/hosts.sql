-- Deploy meatPacker:hosts to pg

BEGIN;

-- XXX Add DDLs here.

CREATE TABLE hosts (hostname text, computer_id bigint references computers, ip inet, updated_at timestamptz);


COMMIT;
