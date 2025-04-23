-- This file is parameterized by a LIFECYCLE_CAMPUS suffix (eg qa_n) to append to 'VDI_CONTROL_' in order to form the target VDI control schema.  The macro :VAR1. is filled in with that value.

CREATE TABLE VDI_CONTROL_:VAR1.dataset (
  dataset_id   VARCHAR(32) PRIMARY KEY NOT NULL,
  owner        NUMERIC(20)             NOT NULL,
  type_name    VARCHAR(64)             NOT NULL,
  type_version VARCHAR(64)             NOT NULL,
  is_deleted   NUMERIC(1) DEFAULT 0    NOT NULL,
  is_public    NUMERIC(1) DEFAULT 0    NOT NULL
, accessibility VARCHAR(30)            NOT NULL
, days_for_approval NUMERIC(20)                  
, creation_date DATE                   NOT NULL            
);


CREATE TABLE VDI_CONTROL_:VAR1.dataset_meta (
  dataset_id        VARCHAR(32) PRIMARY KEY NOT NULL,
  name              VARCHAR(1024)           NOT NULL,
  short_name        VARCHAR(300),
  short_attribution VARCHAR(300),
  category          VARCHAR(100),
  summary           VARCHAR(4000),
  description       TEXT,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1dataset_characteristics (
  dataset_id      VARCHAR(32)   PRIMARY KEY NOT NULL
, study_design    VARCHAR(30)   
, disease         VARCHAR(30)
, sample_type     VARCHAR(30)
, country         VARCHAR(40)
, years           VARCHAR(400)
, ages            VARCHAR(30)
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset (dataset_id)
);


CREATE TABLE VDI_CONTROL_:VAR1.sync_control (
  dataset_id         VARCHAR(32) PRIMARY KEY  NOT NULL,
  shares_update_time TIMESTAMP WITH TIME ZONE NOT NULL,
  data_update_time   TIMESTAMP WITH TIME ZONE NOT NULL,
  meta_update_time   TIMESTAMP WITH TIME ZONE NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_install_message (
  dataset_id   VARCHAR(32)              NOT NULL,
  install_type VARCHAR(64)              NOT NULL,
  status       VARCHAR(64)              NOT NULL,
  message      TEXT,
  updated      TIMESTAMP WITH TIME ZONE NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id),
  PRIMARY KEY (dataset_id, install_type)
);

-- mapping of dataset_id to user_id, including owners and accepted share offers
CREATE TABLE VDI_CONTROL_:VAR1.dataset_visibility (
  dataset_id VARCHAR(32) NOT NULL,
  user_id    NUMERIC(30) NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id),
  PRIMARY KEY (user_id, dataset_id) -- user_id comes first because it is common query
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_project (
  dataset_id VARCHAR(32) PRIMARY KEY NOT NULL,
  project_id VARCHAR(64)             NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

-- Install process heartbeats.  Used to track active installs and locate
-- installs that were interrupted mid-process and left in a broken state.
CREATE TABLE VDI_CONTROL_:VAR1.dataset_install_activity (
  dataset_id   VARCHAR(32)              NOT NULL,
  install_type VARCHAR(64)              NOT NULL,
  last_update  TIMESTAMP WITH TIME ZONE NOT NULL,
  FOREIGN KEY (dataset_id, install_type) REFERENCES VDI_CONTROL_:VAR1.dataset_install_message(dataset_id, install_type),
  PRIMARY KEY (dataset_id, install_type)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_dependency (
  dataset_id   VARCHAR(32) NOT NULL,
  identifier   VARCHAR(50) NOT NULL,
  display_name VARCHAR(100),
  version      VARCHAR(50),
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_publication (
  dataset_id VARCHAR(32) NOT NULL,
  pubmed_id  VARCHAR(30) NOT NULL,
  citation   VARCHAR(2000),
  is_primary    NUMBER       DEFAULT 0   NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_hyperlink (
  dataset_id     VARCHAR(32)  NOT NULL,
  url            VARCHAR(200) NOT NULL,
  text           VARCHAR(300) NOT NULL,
  description    VARCHAR(4000),
  is_publication NUMERIC(1),
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_organism (
  dataset_id      VARCHAR(32)  NOT NULL,
  organism_abbrev VARCHAR(200) NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_contact (
  dataset_id  VARCHAR(32)  NOT NULL,
  is_primary  NUMERIC(1)   NOT NULL,
  name        VARCHAR(300) NOT NULL,
  email       VARCHAR(4000),
  affiliation VARCHAR(4000),
  city        VARCHAR(200),
  state       VARCHAR(200),
  country     VARCHAR(200),
  address     VARCHAR(1000),
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

-- convenience view showing datasets visible to a user that are fully installed, and not deleted
-- application code should use this view to find datasets a user can use
CREATE VIEW VDI_CONTROL_:VAR1.AvailableUserDatasets AS
SELECT v.dataset_id AS user_dataset_id
  , v.user_id
  , o.is_owner
  , d.type_name AS type
  , d.is_public
  , m.accessibility
  , m.creation_date
  , m.name
  , m.description
  , m.summary
  , m.short_name
  , m.short_attribution
  , m.category
  , p.project_id
FROM VDI_CONTROL_:VAR1.dataset_visibility v
   , VDI_CONTROL_:VAR1.dataset d
   , VDI_CONTROL_:VAR1.dataset_meta m
   , VDI_CONTROL_:VAR1.dataset_project p
   , (
       SELECT dataset_id
       FROM VDI_CONTROL_:VAR1.dataset_install_message
       WHERE install_type = 'meta'
         AND status = 'complete'
       INTERSECT
       SELECT dataset_id
       FROM VDI_CONTROL_:VAR1.dataset_install_message
       WHERE install_type = 'data'
         AND status = 'complete'
     ) i
   , (
       SELECT dataset_id, owner AS user_id, 1 AS is_owner
       FROM VDI_CONTROL_:VAR1.dataset
       UNION
       SELECT x.dataset_id, x.user_id, 0 AS is_owner
       FROM (
              SELECT dataset_id, user_id
              FROM VDI_CONTROL_:VAR1.dataset_visibility
              EXCEPT
              -- minus
              SELECT dataset_id, owner AS user_id
              FROM VDI_CONTROL_:VAR1.dataset
            ) x
     ) o
WHERE d.dataset_id = i.dataset_id
  AND v.user_id = o.user_id
  AND d.dataset_id = v.dataset_id
  AND d.dataset_id = m.dataset_id
  AND d.dataset_id = p.dataset_id
  AND d.dataset_id = o.dataset_id
  AND d.is_deleted = 0;


GRANT SELECT ON VDI_CONTROL_:VAR1.dataset TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.sync_control TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_install_message TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_install_activity TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_dependency TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_visibility TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_project TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_meta TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_accessibility TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_publication TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_hyperlink TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_organism TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_contact TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.AvailableUserDatasets TO gus_r;

GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.sync_control TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_install_message TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_install_activity TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_dependency TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_visibility TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_project TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_meta TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_accessibility TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_publication TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_hyperlink TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_organism TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_contact TO vdi_w;



