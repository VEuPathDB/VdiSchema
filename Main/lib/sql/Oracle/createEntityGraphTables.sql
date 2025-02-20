CREATE TABLE VDI_DATASETS_&1..Study (
 USER_DATASET_ID     VARCHAR2(32),
  stable_id                         VARCHAR2(200) NOT NULL,
 internal_abbrev              varchar2(75),
 modification_date            DATE NOT NULL,
 PRIMARY KEY (stable_id),
 UNIQUE(user_dataset_id),
  FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_&1..Study TO vdi_w;
GRANT SELECT ON VDI_DATASETS_&1..Study TO gus_r;

CREATE SEQUENCE VDI_DATASETS_&1..Study_sq;
GRANT SELECT ON VDI_DATASETS_&1..Study_sq TO vdi_w;
GRANT SELECT ON VDI_DATASETS_&1..Study_sq TO gus_r;

CREATE INDEX VDI_DATASETS_&1..study_ix_1 ON VDI_DATASETS_&1..study (stable_id, internal_abbrev) TABLESPACE indx;

-----------------------------------------------------------

CREATE VIEW  VDI_DATASETS_&1..UserStudyDatasetId as
SELECT 'EDAUD_' || user_dataset_id as dataset_stable_id, stable_id as study_stable_id
FROM VDI_DATASETS_&1..study;

GRANT SELECT ON VDI_DATASETS_&1..UserStudyDatasetId TO gus_r;

-----------------------------------------------------------
CREATE TABLE VDI_DATASETS_&1..EntityTypeGraph (
 stable_id                    varchar2(255),
 study_stable_id                varchar2(200),
 parent_stable_id             varchar2(255),
 internal_abbrev              VARCHAR2(50) NOT NULL,
  description                  VARCHAR2(4000),
 display_name                 VARCHAR2(200) NOT NULL,
 display_name_plural          VARCHAR2(200),
 has_attribute_collections    NUMBER(1),
 is_many_to_one_with_parent   NUMBER(1),
 cardinality                  NUMBER(38,0),
 FOREIGN KEY (study_stable_id) REFERENCES VDI_DATASETS_&1..study(stable_id),
  PRIMARY KEY (stable_id, study_stable_id)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_&1..EntityTypeGraph TO vdi_w;
GRANT SELECT ON VDI_DATASETS_&1..EntityTypeGraph TO gus_r;

CREATE SEQUENCE VDI_DATASETS_&1..EntityTypeGraph_sq;
GRANT SELECT ON VDI_DATASETS_&1..EntityTypeGraph_sq TO vdi_w;
GRANT SELECT ON VDI_DATASETS_&1..EntityTypeGraph_sq TO gus_r;

CREATE INDEX VDI_DATASETS_&1..entitytypegraph_ix_1 ON VDI_DATASETS_&1..entitytypegraph (study_stable_id, stable_id, parent_stable_id) TABLESPACE indx;
CREATE INDEX VDI_DATASETS_&1..entitytypegraph_ix_2 ON VDI_DATASETS_&1..entitytypegraph (parent_stable_id) TABLESPACE indx;


exit;
