-- Verify meatPacker:computers on pg

BEGIN;

select computer_id, os, motherboard_model, motherboard_sn, barcode
  from computers
 where FALSE;

ROLLBACK;
