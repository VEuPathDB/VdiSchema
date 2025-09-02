-- This file is parameterized by a LIFECYCLE_CAMPUS suffix (eg qa_n) to append to 'VDI_CONTROL_' in order to form the target VDI control schema.  The macro :VAR1. is filled in with that value.

CREATE TABLE VDI_CONTROL_:VAR1.dataset (
  dataset_id   VARCHAR(32) PRIMARY KEY NOT NULL,
  owner        NUMERIC(20)             NOT NULL,
  type_name    VARCHAR(64)             NOT NULL,
  type_version VARCHAR(64)             NOT NULL,
  is_deleted   NUMERIC(1) DEFAULT 0    NOT NULL,
  is_public    NUMERIC(1) DEFAULT 0    NOT NULL,
  accessibility VARCHAR(30)            NOT NULL CHECK (file_type IN ('public', 'protected', 'private')),
  days_for_approval NUMERIC(20) DEFAULT 0 NOT NULL,                
  creation_date DATE                   NOT NULL            
);


CREATE TABLE VDI_CONTROL_:VAR1.dataset_meta (
  dataset_id        VARCHAR(32) PRIMARY KEY NOT NULL,
  name              VARCHAR(1024)           NOT NULL,
  summary           VARCHAR(4000),
  description       TEXT,
  program_name      VARCHAR(300),
  project_name      VARCHAR(300),  -- eg PRISM
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
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
  dataset_id VARCHAR(32)             NOT NULL,
  project_id VARCHAR(64)             NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id),
  PRIMARY KEY (dataset_id, project_id)
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
  external_id  VARCHAR(30) NOT NULL,
  type       VARCHAR(30) NOT NULL CHECK (type IN ('PubMed', 'DOI')),
  citation   VARCHAR(2000),
  is_primary    NUMBER       DEFAULT 0   NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id),
  PRIMARY KEY (dataset_id, external_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_hyperlink (
  dataset_id     VARCHAR(32)  NOT NULL,
  url            VARCHAR(200) NOT NULL,
  description    VARCHAR(4000),
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id),
  PRIMARY KEY (dataset_id, url)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_contact (
  dataset_id  VARCHAR(32)  NOT NULL,
  is_primary  NUMERIC(1)   NOT NULL,
  first_name  VARCHAR(255) NOT NULL,
  middle_name VARCHAR(255),
  last_name   VARCHAR(255) NOT NULL,
  email       VARCHAR(4000),
  affiliation VARCHAR(4000),
 -- city        VARCHAR(200),
 -- state       VARCHAR(200),
  country     VARCHAR(200),
 -- address     VARCHAR(1000),
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE INDEX VDI_CONTROL_:VAR1.idx_dataset_contact ON dataset_contact(dataset_id);


CREATE TABLE VDI_CONTROL_:VAR1.dataset_organism (
    dataset_id VARCHAR(255) NOT NULL,
    organism_type VARCHAR(50) NOT NULL CHECK (organism_type IN ('experimental', 'host')),
    species VARCHAR(500) NOT NULL,
    strain VARCHAR(500) NOT NULL,
  FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE INDEX VDI_CONTROL_:VAR1.idx_dataset_organism ON dataset_organism(dataset_id);


CREATE TABLE VDI_CONTROL_:VAR1.dataset_funding_award (
    dataset_id VARCHAR(255) NOT NULL,
    agency VARCHAR(500) NOT NULL,
    award_number VARCHAR(255) NOT NULL,
    UNIQUE (dataset_id, agency, award_number),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE INDEX VDI_CONTROL_:VAR1.idx_dataset_fa ON dataset_funding_award(dataset_id);


CREATE TABLE VDI_CONTROL_:VAR1.dataset_characteristics (
    dataset_id VARCHAR(255) NOT NULL,
    study_design TEXT,
    study_type VARCHAR(500),
    participant_ages VARCHAR(500),
    sample_year_start SMALLINT,
    sample_year_end SMALLINT,
    CONSTRAINT valid_year_range CHECK (
        (sample_year_start IS NULL AND sample_year_end IS NULL) OR 
        (sample_year_start IS NOT NULL AND sample_year_end IS NOT NULL AND sample_year_start <= sample_year_end)
    ),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE INDEX VDI_CONTROL_:VAR1.idx_dataset_characteristics ON dataset_characteristics(dataset_id);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_country (
    dataset_id INTEGER NOT NULL,
    country VARCHAR(255) NOT NULL,
    PRIMARY KEY (dataset_id, country),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_species (
    dataset_id INTEGER NOT NULL,
    species VARCHAR(500) NOT NULL,
    PRIMARY KEY (dataset_id, species),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_disease (
    dataset_id INTEGER NOT NULL,
    disease VARCHAR(500) NOT NULL,
    PRIMARY KEY (dataset_id, disease),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_associated_factor (
    dataset_id INTEGER NOT NULL,
    factor VARCHAR(500) NOT NULL,
    PRIMARY KEY (dataset_id, factor),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_sample_type (
    dataset_id INTEGER NOT NULL,
    type VARCHAR(500) NOT NULL,
    PRIMARY KEY (dataset_id, type),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_doi (
    dataset_id VARCHAR(255) NOT NULL,
    doi VARCHAR(500) NOT NULL,
    description TEXT,
    PRIMARY KEY (dataset_id, doi),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_bioproject_id (
    dataset_id VARCHAR(255) NOT NULL,
    bioproject_id VARCHAR(255) NOT NULL,
    description TEXT,
    PRIMARY KEY (dataset_id, bioproject_id),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_:VAR1.dataset_link (
    dataset_id VARCHAR(255) NOT NULL,
    dataset_uri VARCHAR(2048) NOT NULL,
    shares_records BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (dataset_id, dataset_uri),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:VAR1.dataset(dataset_id)
    );

CREATE INDEX idx_linked_datasets_dataset ON linked_datasets(dataset_id);

-- convenience view showing datasets visible to a user that are fully installed, and not deleted
-- application code should use this view to find datasets a user can use
CREATE VIEW VDI_CONTROL_:VAR1.AvailableUserDatasets AS
SELECT v.dataset_id AS user_dataset_id
  , v.user_id
  , o.is_owner
  , d.type_name AS type
  , d.is_public
  , o.accessibility
  , o.is_public
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
       SELECT dataset_id, owner AS user_id, 1 AS is_owner, accessibility, is_public
       FROM VDI_CONTROL_:VAR1.dataset
       UNION
       SELECT x.dataset_id, x.user_id, 0 AS is_owner, 'private' as accessibility, 0 as is_public
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
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_properties TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_publication TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_hyperlink TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_organism TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_contact TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_funding_award TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_characteristics TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_country TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_species TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_disease TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_associated_factor TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_sample_type TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_doi TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_bioproject_id TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.dataset_link TO gus_r;
GRANT SELECT ON VDI_CONTROL_:VAR1.AvailableUserDatasets TO gus_r;

GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.sync_control TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_install_message TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_install_activity TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_dependency TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_visibility TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_project TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_meta TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_properties TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_publication TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_hyperlink TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_organism TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_contact TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_funding_award TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_characteristics TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_country TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_species TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_disease TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_associated_factor TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_sample_type TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_doi TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_bioproject_id TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_:VAR1.dataset_link TO vdi_w;



