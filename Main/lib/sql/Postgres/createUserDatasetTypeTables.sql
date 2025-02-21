CREATE TABLE VDI_DATASETS_:VAR1.UD_GeneId (
  user_dataset_id VARCHAR(32),
  gene_source_id  VARCHAR(100),
  FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE UNIQUE INDEX UD_GENEID_idx1 ON VDI_DATASETS_:VAR1.UD_geneid(user_dataset_id, gene_source_id);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_:VAR1.UD_GeneId TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_GeneId TO gus_r;

----------------------------------------------------------------------------

CREATE TABLE VDI_DATASETS_:VAR1.UD_ProfileSet (
  profile_set_id  NUMERIC(20),
  user_dataset_id VARCHAR(32),
  name            VARCHAR(200) NOT NULL,
  unit            VARCHAR(4),
  FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_:VAR1.DATASET(dataset_id),
  PRIMARY KEY (profile_set_id)
);

CREATE INDEX pset_idx1
  ON VDI_DATASETS_:VAR1.UD_ProfileSet
    (profile_set_id, user_dataset_id, name, unit)
;

CREATE SEQUENCE VDI_DATASETS_:VAR1.UD_profileset_sq;

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_:VAR1.UD_ProfileSet TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_ProfileSet TO gus_r;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_profileSet_sq TO vdi_w;

----------------------------------------------------------------------------
CREATE TABLE VDI_DATASETS_:VAR1.UD_ProtocolAppNode (
  protocol_app_node_id NUMERIC(10)  NOT NULL,
  type_id              NUMERIC(10),
  name                 VARCHAR(200) NOT NULL,
  description          VARCHAR(1000),
  URI                  VARCHAR(300),
  profile_set_id       NUMERIC(20),
  source_id            VARCHAR(100),
  subtype_id           NUMERIC(10),
  taxon_id             NUMERIC(10),
  node_order_num       NUMERIC(10),
  isa_type             VARCHAR(50),
  FOREIGN KEY (profile_set_id) REFERENCES VDI_DATASETS_:VAR1.UD_profileset,
  PRIMARY KEY (protocol_app_node_id)
);

CREATE INDEX UD_PAN_idx1 ON VDI_DATASETS_:VAR1.UD_PROTOCOLAPPNODE(type_id);
CREATE INDEX UD_PAN_idx2 ON VDI_DATASETS_:VAR1.UD_PROTOCOLAPPNODE(profile_set_id);
CREATE INDEX UD_PAN_idx3 ON VDI_DATASETS_:VAR1.UD_PROTOCOLAPPNODE(subtype_id);
CREATE INDEX UD_PAN_idx4 ON VDI_DATASETS_:VAR1.UD_PROTOCOLAPPNODE(taxon_id, protocol_app_node_id);
CREATE INDEX ud_pan_idx5 ON VDI_DATASETS_:VAR1.ud_ProtocolAppNode(protocol_app_node_id, profile_set_id, name);


CREATE SEQUENCE VDI_DATASETS_:VAR1.UD_ProtocolAppNode_sq;

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_:VAR1.UD_ProtocolAppNode TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_ProtocolAppNode TO gus_r;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_ProtocolAppNode_sq TO vdi_w;

-----------------------------------------------------------------------------------------------------

CREATE TABLE VDI_DATASETS_:VAR1.UD_NaFeatureExpression (
  na_feat_expression_id NUMERIC(12) NOT NULL,
  protocol_app_node_id  NUMERIC(10) NOT NULL,
  na_feature_id         NUMERIC(10) NOT NULL,
  value                 NUMERIC(38),
  confidence            NUMERIC(38),
  standard_error        NUMERIC(38),
  categorical_value     VARCHAR(100),
  percentile_channel1   NUMERIC(38),
  percentile_channel2   NUMERIC(38),
  FOREIGN KEY (protocol_app_node_id) REFERENCES VDI_DATASETS_:VAR1.ud_ProtocolAppNode,
  PRIMARY KEY (na_feat_expression_id)
);

CREATE INDEX UD_NFE_idx1 ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression(protocol_app_node_id, na_feature_id, value);
CREATE INDEX UD_NFE_idx2 ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression(na_feature_id);
CREATE UNIQUE INDEX UD_NFE_idx3 ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression(na_feature_id, protocol_app_node_id, value);

CREATE SEQUENCE VDI_DATASETS_:VAR1.UD_NaFeatureExpression_sq;

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression TO gus_r;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression_sq TO vdi_w;

--------------------------------------------------------------------------------
CREATE TABLE VDI_DATASETS_:VAR1.ud_NaFeatureDiffResult (
  na_feat_diff_res_id  NUMERIC(12),
  protocol_app_node_id NUMERIC(10),
  na_feature_id        NUMERIC(10),
  mean1                NUMERIC(38),
  sd1                  NUMERIC(38),
  mean2                NUMERIC(38),
  sd2                  NUMERIC(38),
  fdr                  NUMERIC(38),
  fold_change          NUMERIC(38),
  test_statistic       NUMERIC(38),
  p_value              NUMERIC(38),
  adj_p_value          NUMERIC(38),
  q_value              NUMERIC(38),
  confidence_up        NUMERIC(38),
  confidence_down      NUMERIC(38),
  confidence           NUMERIC(38),
  z_score              NUMERIC(12),
  is_significant       NUMERIC(1),
  FOREIGN KEY (protocol_app_node_id) REFERENCES VDI_DATASETS_:VAR1.ud_ProtocolAppNode,
  PRIMARY KEY (na_feat_diff_res_id)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_:VAR1.ud_NaFeatureDiffResult TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.ud_NaFeatureDiffResult TO gus_r;

CREATE SEQUENCE VDI_DATASETS_:VAR1.ud_NaFeatureDiffResult_sq;
GRANT SELECT ON VDI_DATASETS_:VAR1.ud_NaFeatureDiffResult_sq TO vdi_w;

--------------------------------------------------------------------------------
-- based on datasetPresenters
-- intended for summary statistics etc. created during installation
-- WDK also has access to display values from IRODS: name, summary, and description
-- These are editable by the user, so there is no consistent way to keep them here

CREATE TABLE VDI_DATASETS_:VAR1.UD_Presenter (
  user_dataset_id VARCHAR(32)  NOT NULL,
  property_name   VARCHAR(200) NOT NULL,
  property_value  VARCHAR(200) NOT NULL,
  FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_:VAR1.DATASET(dataset_id),
  UNIQUE (user_dataset_id, property_name)
);

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_:VAR1.UD_Presenter TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_Presenter TO gus_r;


CREATE TABLE VDI_DATASETS_:VAR1.UD_Sample (
  user_dataset_id VARCHAR(32)  NOT NULL,
  sample_id       NUMERIC(10)  NOT NULL,
  name            VARCHAR(200) NOT NULL,
  display_name    VARCHAR(200),
  FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_:VAR1.DATASET(dataset_id),
  PRIMARY KEY (sample_id),
  UNIQUE (name)
);

CREATE SEQUENCE VDI_DATASETS_:VAR1.UD_Sample_sq;

GRANT INSERT, SELECT, UPDATE, DELETE ON VDI_DATASETS_:VAR1.UD_Sample TO vdi_w;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_Sample TO gus_r;
GRANT SELECT ON VDI_DATASETS_:VAR1.UD_Sample_sq TO vdi_w;

