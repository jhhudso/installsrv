-- Verify meatPacker:computers on pg

BEGIN;

SELECT computer_id, os, motherboard_model, motherboard_sn, barcode
  FROM computers
 WHERE FALSE;

ROLLBACK;
