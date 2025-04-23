ALTER TABLE VDI_CONTROL_@SUFFIX@.dataset ADD COLUMN accessibility varchar(30);
ALTER TABLE VDI_CONTROL_@SUFFIX@.dataset ADD COLUMN days_for_approval number;
ALTER TABLE VDI_CONTROL_@SUFFIX@.dataset ADD COLUMN creation_date DATE;

CREATE TABLE VDI_CONTROL_@SUFFIX@.dataset_characteristics (
  dataset_id      VARCHAR2(32)   PRIMARY KEY NOT NULL
, study_design    VARCHAR2(30)   
, disease         VARCHAR2(30)
, sample_type     VARCHAR2(30)
, country         VARCHAR2(40)
, years           VARCHAR2(400)
, ages            VARCHAR2(30)
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_@SUFFIX@.dataset (dataset_id)
);

GRANT SELECT ON VDI_CONTROL_@SUFFIX@.dataset_characteristics   TO gus_r;

GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_@SUFFIX@.dataset_characteristics     TO vdi_w;
