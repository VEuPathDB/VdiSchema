CREATE TABLE VDI_DATASETS_&1..Study (
 USER_DATASET_ID     VARCHAR2(32),
 study_id            NUMBER(12) NOT NULL,
 stable_id                         VARCHAR2(200) NOT NULL,
 internal_abbrev              varchar2(75),
 modification_date            DATE NOT NULL,
 PRIMARY KEY (study_id),
 CONSTRAINT unique_stable_id UNIQUE (stable_id),
 FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_&1..Study TO vdi_w;
GRANT SELECT ON VDI_DATASETS_&1..Study TO gus_r;

CREATE SEQUENCE VDI_DATASETS_&1..Study_sq;
GRANT SELECT ON VDI_DATASETS_&1..Study_sq TO vdi_w;
GRANT SELECT ON VDI_DATASETS_&1..Study_sq TO gus_r;

CREATE INDEX VDI_DATASETS_&1..study_ix_1 ON VDI_DATASETS_&1..study (stable_id, internal_abbrev, study_id) TABLESPACE indx;

-----------------------------------------------------------

CREATE TABLE VDI_DATASETS_&1..EntityTypeGraph (
 entity_type_graph_id           NUMBER(12) NOT NULL,
 stable_id                    varchar2(255),
 study_id            NUMBER(12) NOT NULL,
 study_stable_id                varchar2(200),
 parent_stable_id             varchar2(255),
 internal_abbrev              VARCHAR2(50) NOT NULL,
  description                  VARCHAR2(4000),
 display_name                 VARCHAR2(200) NOT NULL,
 display_name_plural          VARCHAR2(200),
 has_attribute_collections    NUMBER(1),
 is_many_to_one_with_parent   NUMBER(1),
 cardinality                  NUMBER(38,0),
 FOREIGN KEY (study_id) REFERENCES VDI_DATASETS_&1..study,
  PRIMARY KEY (entity_type_graph_id)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_&1..EntityTypeGraph TO vdi_w;
GRANT SELECT ON VDI_DATASETS_&1..EntityTypeGraph TO gus_r;

CREATE SEQUENCE VDI_DATASETS_&1..EntityTypeGraph_sq;
GRANT SELECT ON VDI_DATASETS_&1..EntityTypeGraph_sq TO vdi_w;
GRANT SELECT ON VDI_DATASETS_&1..EntityTypeGraph_sq TO gus_r;

CREATE INDEX VDI_DATASETS_&1..entitytypegraph_ix_1 ON VDI_DATASETS_&1..entitytypegraph (study_id, stable_id, parent_stable_id, entity_type_graph_id) TABLESPACE indx;
CREATE INDEX VDI_DATASETS_&1..entitytypegraph_ix_2 ON VDI_DATASETS_&1..entitytypegraph (parent_stable_id, entity_type_graph_id) TABLESPACE indx;


exit;
