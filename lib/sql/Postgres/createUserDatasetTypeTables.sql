create table VDI_DATASETS_:VAR1.UD_GeneId (
USER_DATASET_ID          VARCHAR(32),
gene_SOURCE_ID                             VARCHAR(100),
FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE unique INDEX VDI_DATASETS_:VAR1.UD_GENEID_idx1 ON VDI_DATASETS_:VAR1.UD_geneid (user_dataset_id, gene_source_id) tablespace indx;

GRANT insert, select, update, delete ON VDI_DATASETS_:VAR1.UD_GeneId TO vdi_w;
GRANT select ON VDI_DATASETS_:VAR1.UD_GeneId TO gus_r;

----------------------------------------------------------------------------

create table VDI_DATASETS_:VAR1.UD_ProfileSet (
 profile_set_id  numeric(20),
 user_dataset_id varchar(32),
 name            varchar(200) not null,
 unit            varchar(4),
 foreign key (user_dataset_id) references VDI_CONTROL_:VAR1.DATASET(dataset_id),
 primary key (profile_set_id)
);

create index VDI_DATASETS_:VAR1.pset_idx1
  on VDI_DATASETS_:VAR1.UD_ProfileSet
     (profile_set_id, user_dataset_id, name, unit)
  tablespace indx;

create sequence VDI_DATASETS_:VAR1.UD_profileset_sq;

grant insert, select, update, delete on VDI_DATASETS_:VAR1.UD_ProfileSet to vdi_w;
grant select on VDI_DATASETS_:VAR1.UD_ProfileSet to gus_r;
grant select on VDI_DATASETS_:VAR1.UD_profileSet_sq to vdi_w;

----------------------------------------------------------------------------
create table VDI_DATASETS_:VAR1.UD_ProtocolAppNode (
PROTOCOL_APP_NODE_ID                  NUMERIC(10) not null,
TYPE_ID                               NUMERIC(10),
NAME                                  VARCHAR(200) not null,
DESCRIPTION                           VARCHAR(1000),
URI                                   VARCHAR(300),
profile_set_id                        NUMERIC(20),
SOURCE_ID                             VARCHAR(100),
SUBTYPE_ID                            NUMERIC(10),
TAXON_ID                              NUMERIC(10),
NODE_ORDER_NUM                        NUMERIC(10),
ISA_TYPE                              VARCHAR(50),
FOREIGN KEY (profile_set_id) REFERENCES VDI_DATASETS_:VAR1.UD_profileset,
PRIMARY KEY (protocol_app_node_id)
);

CREATE INDEX VDI_DATASETS_:VAR1.UD_PAN_idx1 ON VDI_DATASETS_:VAR1.UD_PROTOCOLAPPNODE (type_id) tablespace indx;
CREATE INDEX VDI_DATASETS_:VAR1.UD_PAN_idx2 ON VDI_DATASETS_:VAR1.UD_PROTOCOLAPPNODE (profile_set_id) tablespace indx;
CREATE INDEX VDI_DATASETS_:VAR1.UD_PAN_idx3 ON VDI_DATASETS_:VAR1.UD_PROTOCOLAPPNODE (subtype_id) tablespace indx;
CREATE INDEX VDI_DATASETS_:VAR1.UD_PAN_idx4 ON VDI_DATASETS_:VAR1.UD_PROTOCOLAPPNODE (taxon_id, protocol_app_node_id) tablespace indx;
CREATE INDEX VDI_DATASETS_:VAR1.ud_pan_idx5 on VDI_DATASETS_:VAR1.ud_ProtocolAppNode (protocol_app_node_id, profile_set_id, name);


create sequence VDI_DATASETS_:VAR1.UD_ProtocolAppNode_sq;

GRANT insert, select, update, delete ON VDI_DATASETS_:VAR1.UD_ProtocolAppNode TO vdi_w;
GRANT select ON VDI_DATASETS_:VAR1.UD_ProtocolAppNode TO gus_r;
GRANT select ON VDI_DATASETS_:VAR1.UD_ProtocolAppNode_sq TO vdi_w;

-----------------------------------------------------------------------------------------------------

create table VDI_DATASETS_:VAR1.UD_NaFeatureExpression (
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

CREATE INDEX VDI_DATASETS_:VAR1.UD_NFE_idx1 ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression (protocol_app_node_id, na_feature_id, value) tablespace indx;
CREATE INDEX VDI_DATASETS_:VAR1.UD_NFE_idx2 ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression (na_feature_id) tablespace indx;
CREATE unique INDEX VDI_DATASETS_:VAR1.UD_NFE_idx3 ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression (na_feature_id, protocol_app_node_id, value) tablespace indx;

create sequence VDI_DATASETS_:VAR1.UD_NaFeatureExpression_sq;

GRANT insert, select, update, delete ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression TO vdi_w;
GRANT select ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression TO gus_r;
GRANT select ON VDI_DATASETS_:VAR1.UD_NaFeatureExpression_sq TO vdi_w;

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

create table VDI_DATASETS_:VAR1.UD_Presenter (
  user_dataset_id varchar(32) not null,
  property_name varchar(200) not null,
  property_value varchar(200) not null,
  foreign key (user_dataset_id) references VDI_CONTROL_:VAR1.DATASET(dataset_id),
  unique(user_dataset_id, property_name)
);

grant insert, select, update, delete on VDI_DATASETS_:VAR1.UD_Presenter to vdi_w;
grant select on VDI_DATASETS_:VAR1.UD_Presenter to gus_r;


create table VDI_DATASETS_:VAR1.UD_Sample (
user_dataset_id                       VARCHAR(32) not null,
sample_id                             NUMERIC(10) not null,
name                                  VARCHAR(200) not null,
display_name                                  VARCHAR(200),
FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_:VAR1.DATASET(dataset_id),
PRIMARY KEY (sample_id),
UNIQUE (name)
);
create sequence VDI_DATASETS_:VAR1.UD_Sample_sq;

GRANT insert, select, update, delete ON VDI_DATASETS_:VAR1.UD_Sample TO vdi_w;
GRANT select ON VDI_DATASETS_:VAR1.UD_Sample TO gus_r;
GRANT select ON VDI_DATASETS_:VAR1.UD_Sample_sq TO vdi_w;
exit;
