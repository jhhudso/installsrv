-- Verify compinvent:hosts on pg

BEGIN;

-- XXX Add verifications here.
SELECT hostname, computer_id, ip, updated_at FROM hosts WHERE FALSE;


ROLLBACK;
