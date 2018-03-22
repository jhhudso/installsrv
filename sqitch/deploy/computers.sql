-- Deploy meatPacker:computers to pg

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

CREATE rule insert_v_computers AS ON INSERT TO v_computers DO INSTEAD (
    insert into manufacturers (name) values (NEW.system_manufacturer) on conflict do nothing;
    insert into manufacturers (name) values (NEW.baseboard_manufacturer) on conflict do nothing;
    insert into manufacturers (name) values (NEW.chassis_manufacturer) on conflict do nothing;
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
);

CREATE rule update_v_computers AS ON UPDATE TO v_computers DO INSTEAD (
    insert into manufacturers(name) values (NEW.system_manufacturer) on conflict do nothing;
    insert into manufacturers(name) values (NEW.baseboard_manufacturer) on conflict do nothing;
    insert into manufacturers(name) values (NEW.chassis_manufacturer) on conflict do nothing;
    update computers SET (system_manufacturer,
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
                            barcode) = (      
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
    ) WHERE computer_id = OLD.computer_id;
);


-- Read-Only user can select
GRANT SELECT ON computers TO inventory_ro;
GRANT SELECT ON SEQUENCE computers_computer_id_seq TO inventory_ro;

-- Read-Write user can insert/update/delete and manipulate the sequence
GRANT SELECT,INSERT,UPDATE,DELETE ON computers TO inventory_rw;
GRANT USAGE ON SEQUENCE computers_computer_id_seq TO inventory_rw;

COMMIT;
