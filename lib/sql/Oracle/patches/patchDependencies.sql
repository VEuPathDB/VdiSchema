CREATE TABLE VDI_CONTROL_@SUFFIX@.dataset_dependency (
  dataset_id  VARCHAR2(32)   NOT NULL
, identifier        VARCHAR2(50) NOT NULL
, display_name VARCHAR2(100) 
, version VARCHAR2(50) 
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_@SUFFIX.dataset (dataset_id)
);

GRANT SELECT ON VDI_CONTROL_@SUFFIX@.dataset_dependency  TO gus_r;

GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_@SUFFIX@.dataset_dependency     TO vdi_w;
