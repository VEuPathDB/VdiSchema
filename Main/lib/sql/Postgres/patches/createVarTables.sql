-- Used by the WDK UserDataset record and site search
CREATE TABLE VDI_DATASETS_@SUFFIX@.Variable
(
    stable_id character varying(255) NOT NULL,
    study_stable_id character varying(255) NOT NULL, 
    entity_stable_id character varying(255) NOT NULL,
    dataset_id character varying(255) NOT NULL,
    definition text,
    display_name text,
    data_shape text,
    data_type text,
    display_range_max text,
    display_range_min text,
    provider_label text,
    hidden text,
  FOREIGN KEY (dataset_id) REFERENCES VDI_DATASETS_@SUFFIX@.study(user_dataset_id),
  FOREIGN KEY (study_stable_id, entity_stable_id) REFERENCES VDI_DATASETS_@SUFFIX@.entitytypegraph(study_stable_id, stable_id),
  PRIMARY KEY (dataset_id, entity_stable_id, stable_id)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_@SUFFIX@.Variable TO vdi_w;
GRANT SELECT ON VDI_DATASETS_@SUFFIX@.Variable TO gus_r;

----------------------------------------------------------------------

-- Used by the WDK UserDataset record and site search
CREATE TABLE VDI_DATASETS_@SUFFIX@.VariableCategoricalValue
(
    stable_id text NOT NULL,
    study_stable_id character varying(255) NOT NULL, 
    entity_stable_id text NOT NULL,
    dataset_id text NOT NULL,
    value text NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_DATASETS_@SUFFIX@.study(user_dataset_id),
  FOREIGN KEY (study_stable_id, entity_stable_id) REFERENCES VDI_DATASETS_@SUFFIX@.entitytypegraph(study_stable_id, stable_id)
);

CREATE INDEX vcv_ix_1 ON VDI_DATASETS_@SUFFIX@.VariableCategoricalValue(dataset_id, entity_stable_id, stable_id);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_@SUFFIX@.VariableCategoricalValue TO vdi_w;
GRANT SELECT ON VDI_DATASETS_@SUFFIX@.VariableCategoricalValue TO gus_r;

CREATE TABLE VDI_DATASETS_@SUFFIX@.Variable
(
    stable_id character varying(255) NOT NULL,
    study_stable_id character varying(255) NOT NULL, 
    entity_stable_id character varying(255) NOT NULL,
    dataset_id character varying(255) NOT NULL,
    definition text,
    display_name text,
    data_shape text,
    data_type text,
    display_range_max text,
    display_range_min text,
    provider_label text,
    hidden text,
  FOREIGN KEY (dataset_id) REFERENCES VDI_DATASETS_@SUFFIX@.study(user_dataset_id),
  FOREIGN KEY (study_stable_id, entity_stable_id) REFERENCES VDI_DATASETS_@SUFFIX@.entitytypegraph(study_stable_id, stable_id),
  PRIMARY KEY (dataset_id, entity_stable_id, stable_id)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_@SUFFIX@.Variable TO vdi_w;
GRANT SELECT ON VDI_DATASETS_@SUFFIX@.Variable TO gus_r;
