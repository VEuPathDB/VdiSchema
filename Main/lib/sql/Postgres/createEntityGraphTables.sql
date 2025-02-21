CREATE TABLE VDI_DATASETS_:VAR1.Study (
  user_dataset_id   VARCHAR(32),
  stable_id         VARCHAR(200) NOT NULL,
  internal_abbrev   VARCHAR(75),
  modification_date DATE         NOT NULL,
  PRIMARY KEY (stable_id),
  UNIQUE (user_dataset_id),
  FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_:VAR1.Study TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.Study TO gus_r;

CREATE SEQUENCE VDI_DATASETS_:VAR1.Study_sq;
GRANT SELECT ON VDI_DATASETS_:VAR1.Study_sq TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.Study_sq TO gus_r;

CREATE INDEX study_ix_1 ON VDI_DATASETS_:VAR1.study(stable_id, internal_abbrev);

-----------------------------------------------------------

CREATE VIEW VDI_DATASETS_:VAR1.UserStudyDatasetId AS
SELECT 'EDAUD_' || user_dataset_id AS dataset_stable_id, stable_id AS study_stable_id
FROM VDI_DATASETS_:VAR1.study;

GRANT SELECT ON VDI_DATASETS_:VAR1.UserStudyDatasetId TO gus_r;

-----------------------------------------------------------
CREATE TABLE VDI_DATASETS_:VAR1.EntityTypeGraph (
  stable_id                  VARCHAR(255),
  study_stable_id            VARCHAR(200),
  parent_stable_id           VARCHAR(255),
  internal_abbrev            VARCHAR(50)  NOT NULL,
  description                VARCHAR(4000),
  display_name               VARCHAR(200) NOT NULL,
  display_name_plural        VARCHAR(200),
  has_attribute_collections  NUMERIC(1),
  is_many_to_one_with_parent NUMERIC(1),
  cardinality                NUMERIC(38, 0),
  FOREIGN KEY (study_stable_id) REFERENCES VDI_DATASETS_:VAR1.study(stable_id),
  PRIMARY KEY (stable_id, study_stable_id)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_:VAR1.EntityTypeGraph TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.EntityTypeGraph TO gus_r;

CREATE SEQUENCE VDI_DATASETS_:VAR1.EntityTypeGraph_sq;
GRANT SELECT ON VDI_DATASETS_:VAR1.EntityTypeGraph_sq TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.EntityTypeGraph_sq TO gus_r;

CREATE INDEX entitytypegraph_ix_1 ON VDI_DATASETS_:VAR1.entitytypegraph(study_stable_id, stable_id, parent_stable_id);
CREATE INDEX entitytypegraph_ix_2 ON VDI_DATASETS_:VAR1.entitytypegraph(parent_stable_id);



