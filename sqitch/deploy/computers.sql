-- Deploy compinvent:computers to pg

BEGIN;

CREATE TABLE computers (    
    computer_id bigserial PRIMARY KEY,
    system_manufacturer int REFERENCES manufacturers(manufacturer_id) NULL,
    system_product_name text NULL,
    system_version text NULL,
    system_sn text NULL,
    baseboard_manufacturer int REFERENCES manufacturers(manufacturer_id) NULL,
    baseboard_product_name text NULL,
    baseboard_version text NULL,
    baseboard_sn text NULL,
    baseboard_asset_tag text NULL,
    chassis_manufacturer int REFERENCES manufacturers(manufacturer_id) NULL,
    chassis_type text NULL,
    chassis_version text NULL,
    chassis_sn text NULL,
    chassis_asset_tag text NULL,
    os text NULL,
    barcode bigint UNIQUE
);

CREATE VIEW v_computers AS 
   SELECT c.computer_id,
    (SELECT name FROM manufacturers WHERE manufacturer_id = system_manufacturer) AS system_manufacturer,
    c.system_product_name,
    c.system_version,
    c.system_sn,
    (SELECT name FROM manufacturers WHERE manufacturer_id = baseboard_manufacturer) AS baseboard_manufacturer,
    c.baseboard_product_name,
    c.baseboard_version,
    c.baseboard_sn,
    c.baseboard_asset_tag,
    (SELECT name FROM manufacturers WHERE manufacturer_id = chassis_manufacturer) AS chassis_manufacturer,
    c.chassis_type,
    c.chassis_version,
    c.chassis_sn,
    c.chassis_asset_tag,
    c.os,
    c.barcode
   FROM computers c;

CREATE OR REPLACE rule insert_v_computers as ON INSERT TO v_computers DO INSTEAD (
    select add_manufacturer(NEW.system_manufacturer);
    select add_manufacturer(NEW.baseboard_manufacturer);
    select add_manufacturer(NEW.chassis_manufacturer);
    insert into computers (system_manufacturer,
                            system_product_name,
                            system_version,
                            system_sn,
                            baseboard_manufacturer,
                            baseboard_product_name,
                            baseboard_version,
                            baseboard_sn,
                            baseboard_asset_tag,
                            chassis_manufacturer,
                            chassis_type,
                            chassis_version,
                            chassis_sn,
                            chassis_asset_tag,
                            os,
                            barcode) values (      
        (SELECT manufacturer_id FROM manufacturers WHERE NEW.system_manufacturer = name),
        NEW.system_product_name,
        NEW.system_version,
        NEW.system_sn,
        (SELECT manufacturer_id FROM manufacturers WHERE NEW.baseboard_manufacturer = name),
        NEW.baseboard_product_name,
        NEW.baseboard_version,
        NEW.baseboard_sn,
        NEW.baseboard_asset_tag,
        (SELECT manufacturer_id FROM manufacturers WHERE NEW.chassis_manufacturer = name),
        NEW.chassis_type,
        NEW.chassis_version,
        NEW.chassis_sn,
        NEW.chassis_asset_tag,
        NEW.os,
        NEW.barcode      
    )
    RETURNING computers.computer_id,
    	      (SELECT name AS system_manufacturer FROM manufacturers WHERE manufacturer_id = computers.system_manufacturer),
	      computers.system_product_name,
	      computers.system_version,
              computers.system_sn,
	      (SELECT name AS baseboard_manufacturer FROM manufacturers WHERE manufacturer_id = computers.baseboard_manufacturer),
   	      computers.baseboard_product_name,
              computers.baseboard_version,
              computers.baseboard_sn,
              computers.baseboard_asset_tag,
	      (SELECT name AS chassis_manufacturer FROM manufacturers WHERE manufacturer_id = computers.chassis_manufacturer),
	      computers.chassis_type,
              computers.chassis_version,
              computers.chassis_sn,
              computers.chassis_asset_tag,
              computers.os,
              computers.barcode;
);

CREATE or replace rule update_v_computers AS ON UPDATE TO v_computers DO INSTEAD (
    insert into manufacturers(name) values (NEW.system_manufacturer) on conflict do nothing;
    insert into manufacturers(name) values (NEW.baseboard_manufacturer) on conflict do nothing;
    insert into manufacturers(name) values (NEW.chassis_manufacturer) on conflict do nothing;
    update computers SET system_manufacturer = COALESCE((SELECT manufacturer_id FROM manufacturers WHERE NEW.system_manufacturer = name), system_manufacturer),
                         system_version = COALESCE(NEW.system_version, OLD.system_version),
                         system_sn = COALESCE(NEW.system_sn, OLD.system_sn),
                         baseboard_manufacturer = COALESCE((SELECT manufacturer_id FROM manufacturers WHERE NEW.baseboard_manufacturer = name), baseboard_manufacturer),
                         baseboard_product_name = COALESCE(NEW.baseboard_product_name, OLD.baseboard_product_name),
                         baseboard_version = COALESCE(NEW.baseboard_version, OLD.baseboard_version),
                         baseboard_sn = COALESCE(NEW.baseboard_sn, OLD.baseboard_sn),
                         baseboard_asset_tag = COALESCE(NEW.baseboard_asset_tag, OLD.baseboard_asset_tag),
                         chassis_manufacturer = COALESCE((SELECT manufacturer_id FROM manufacturers WHERE NEW.chassis_manufacturer = name), chassis_manufacturer),
                         chassis_type = COALESCE(NEW.chassis_type, OLD.chassis_type),
                         chassis_version = COALESCE(NEW.chassis_version, OLD.chassis_version),
                         chassis_sn = COALESCE(NEW.chassis_sn, OLD.chassis_sn),
                         chassis_asset_tag = COALESCE(NEW.chassis_asset_tag, OLD.chassis_asset_tag),
                         os = COALESCE(NEW.os, OLD.os),
                         barcode = COALESCE(NEW.barcode, barcode)
    WHERE computer_id = OLD.computer_id AND
          (OLD.system_manufacturer <> NEW.system_manufacturer OR
           OLD.system_version <> NEW.system_version OR
           OLD.system_sn <> NEW.system_sn OR
           OLD.baseboard_manufacturer <> NEW.baseboard_manufacturer OR
           OLD.baseboard_product_name <> NEW.baseboard_product_name OR
           OLD.baseboard_version <> NEW.baseboard_version OR
           OLD.baseboard_asset_tag <> NEW.baseboard_asset_tag OR
           OLD.chassis_manufacturer <> NEW.chassis_manufacturer OR
           OLD.chassis_type <> NEW.chassis_type OR
           OLD.chassis_version <> NEW.chassis_version OR
           OLD.chassis_sn <> NEW.chassis_sn OR
           OLD.chassis_asset_tag <> NEW.chassis_asset_tag OR
           OLD.os <> NEW.os OR
           OLD.barcode <> NEW.barcode)
);

CREATE OR REPLACE FUNCTION delete_computers(id bigint) RETURNS void AS $$
DECLARE
    old_c computers%ROWTYPE;

BEGIN
  BEGIN
        SELECT system_manufacturer, baseboard_manufacturer, chassis_manufacturer FROM computers INTO old_c WHERE computer_id=id;

        DELETE FROM computers
        WHERE computer_id = id;
  END;

  BEGIN
    DELETE FROM manufacturers
     WHERE manufacturer_id = old_c.system_manufacturer OR
           manufacturer_id = old_c.baseboard_manufacturer OR
           manufacturer_id = old_c.chassis_manufacturer;
    EXCEPTION
        WHEN foreign_key_violation THEN --
END;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE RULE delete_v_computers AS ON DELETE TO v_computers
    DO INSTEAD (SELECT delete_computers(OLD.computer_id));

-- Read-Only user can select
GRANT SELECT ON computers TO inventory_ro;
GRANT SELECT ON v_computers TO inventory_ro;
GRANT SELECT ON SEQUENCE computers_computer_id_seq TO inventory_ro;

-- Read-Write user can insert/update/delete and manipulate the sequence
GRANT SELECT,INSERT,UPDATE,DELETE ON computers TO inventory_rw;
GRANT SELECT,INSERT,UPDATE,DELETE ON v_computers TO inventory_rw;
GRANT USAGE ON SEQUENCE computers_computer_id_seq TO inventory_rw;

COMMIT;
