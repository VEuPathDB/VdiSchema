ALTER TABLE VDI_CONTROL_@SUFFIX@.dataset_meta RENAME COLUMN description TO old_description;
ALTER TABLE  VDI_CONTROL_@SUFFIX@.dataset_meta ADD description clob;
UPDATE VDI_CONTROL_@SUFFIX@.dataset_meta SET description = old_description;
