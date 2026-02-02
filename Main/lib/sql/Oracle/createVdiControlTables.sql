-- This file is parameterized by a LIFECYCLE_CAMPUS suffix (eg qa_n) to append to 'VDI_CONTROL_' in order to form the target VDI control schema.  The macro &1. is filled in with that value.

-- In Oracle, that schema must be first created by DBA
--   CREATE USER &1.
--   IDENTIFIED BY "<password>"
--   QUOTA UNLIMITED ON users;

CREATE TABLE VDI_CONTROL_&1..dataset (
  dataset_id   VARCHAR2(32)     PRIMARY KEY NOT NULL
, owner        NUMBER                   NOT NULL
, type_name    VARCHAR2(64)             NOT NULL
, type_version VARCHAR2(64)             NOT NULL
, category      VARCHAR2(64)             NOT NULL
, deleted_status NUMBER DEFAULT 0    NOT NULL -- 0 = Not Deleted; 1 = Deleted and Uninstalled; 2 = Deleted but not yet Uninstalled
, is_deleted   NUMBER       DEFAULT 0   NOT NULL
, is_public    NUMBER       DEFAULT 0   NOT NULL
, accessibility VARCHAR2(30)            NOT NULL
, days_for_approval NUMBER  DEFAULT 0   NOT NULL           
, creation_date DATE                    NOT NULL            
);


CREATE TABLE VDI_CONTROL_&1..dataset_meta (
  dataset_id  VARCHAR2(32)   PRIMARY KEY NOT NULL
, name        VARCHAR2(1024) NOT NULL
, short_name        VARCHAR2(300)
, short_attribution VARCHAR2(300)
, summary VARCHAR2(4000)
, description CLOB
, program_name      VARCHAR2(300)
, project_name      VARCHAR2(300)  -- eg PRISM
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..sync_control (
  dataset_id         VARCHAR2(32)     PRIMARY KEY NOT NULL
, shares_update_time TIMESTAMP WITH TIME ZONE NOT NULL
, data_update_time   TIMESTAMP WITH TIME ZONE NOT NULL
, meta_update_time   TIMESTAMP WITH TIME ZONE NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_install_message (
  dataset_id   VARCHAR2(32) NOT NULL
, install_type VARCHAR2(64) NOT NULL
, status       VARCHAR2(64) NOT NULL
, message      CLOB
, updated      TIMESTAMP WITH TIME ZONE NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
, PRIMARY KEY (dataset_id, install_type)
);

-- mapping of dataset_id to user_id, including owners and accepted share offers
CREATE TABLE VDI_CONTROL_&1..dataset_visibility (
  dataset_id VARCHAR2(32) NOT NULL
, user_id    NUMBER   NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
, PRIMARY KEY (user_id, dataset_id)  -- user_id comes first because it is common query
);

CREATE TABLE VDI_CONTROL_&1..dataset_project (
  dataset_id VARCHAR2(32)     PRIMARY KEY NOT NULL
, project_id VARCHAR2(64) NOT NULL
, project_display_name VARCHAR2(64) NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

-- Install process heartbeats.  Used to track active installs and locate
-- installs that were interrupted mid-process and left in a broken state.
CREATE TABLE VDI_CONTROL_&1..dataset_install_activity (
  dataset_id   VARCHAR2(32) NOT NULL
, install_type VARCHAR2(64) NOT NULL
, last_update  TIMESTAMP WITH TIME ZONE NOT NULL
, FOREIGN KEY (dataset_id, install_type) REFERENCES VDI_CONTROL_&1..dataset_install_message (dataset_id, install_type)
, PRIMARY KEY (dataset_id, install_type)
);

CREATE TABLE VDI_CONTROL_&1..dataset_dependency (
  dataset_id  VARCHAR2(32)   NOT NULL
, identifier        VARCHAR2(50) NOT NULL
, display_name VARCHAR2(100) 
, version VARCHAR2(50) 
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_publication (
  dataset_id  VARCHAR2(32)   NOT NULL
, external_id        VARCHAR2(30) NOT NULL
, type         VARCHAR2(30) 
, citation         VARCHAR2(4000) 
, is_primary    NUMBER       DEFAULT 0  NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_hyperlink (
  dataset_id  VARCHAR2(32)   NOT NULL
, url        VARCHAR2(200) NOT NULL
, description        VARCHAR2(4000)
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_contact (
  dataset_id  VARCHAR2(32)   NOT NULL
, is_primary  NUMBER NOT NULL
, first_name        VARCHAR2(300) NOT NULL
, middle_name        VARCHAR2(300) NOT NULL
, last_name        VARCHAR2(300) NOT NULL
, email        VARCHAR2(4000)
, affiliation  VARCHAR2(4000)
, country        VARCHAR2(200)
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE INDEX idx_dataset_contact ON VDI_CONTROL_&1..dataset_contact(dataset_id);

CREATE TABLE VDI_CONTROL_&1..dataset_organism (
  dataset_id  VARCHAR2(32)   NOT NULL
, organism_type    VARCHAR2(50) NOT NULL
, species    VARCHAR2(500) NOT NULL
, strain    VARCHAR2(500) NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_funding_award (
    dataset_id VARCHAR2(255) NOT NULL,
    agency VARCHAR2(500) NOT NULL,
    award_number VARCHAR2(255) NOT NULL,
    UNIQUE (dataset_id, agency, award_number),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

CREATE INDEX idx_dataset_fa ON VDI_CONTROL_&1..dataset_funding_award(dataset_id);


CREATE TABLE VDI_CONTROL_&1..dataset_characteristics (
    dataset_id VARCHAR2(32) PRIMARY KEY NOT NULL,
    study_design CLOB,
    study_type VARCHAR2(500),
    participant_ages VARCHAR2(500),
    sample_year_start NUMBER(5),
    sample_year_end NUMBER(5),
    CONSTRAINT valid_year_range CHECK (
        (sample_year_start IS NULL AND sample_year_end IS NULL) OR
        (sample_year_start IS NOT NULL AND sample_year_end IS NOT NULL AND sample_year_start <= sample_year_end)
    ),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_country (
    dataset_id VARCHAR2(32) NOT NULL,
    country VARCHAR2(255) NOT NULL,
    PRIMARY KEY (dataset_id, country),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_species (
    dataset_id VARCHAR2(32) NOT NULL,
    species VARCHAR2(500) NOT NULL,
    PRIMARY KEY (dataset_id, species),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_disease (
    dataset_id VARCHAR2(32) NOT NULL,
    disease VARCHAR2(500) NOT NULL,
    PRIMARY KEY (dataset_id, disease),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_associated_factor (
    dataset_id VARCHAR2(32) NOT NULL,
    factor VARCHAR2(500) NOT NULL,
    PRIMARY KEY (dataset_id, factor),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_sample_type (
    dataset_id VARCHAR2(32) NOT NULL,
    type VARCHAR2(500) NOT NULL,
    PRIMARY KEY (dataset_id, type),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_doi (
    dataset_id VARCHAR2(32) NOT NULL,
    doi VARCHAR2(500) NOT NULL,
    description CLOB,
    PRIMARY KEY (dataset_id, doi),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_bioproject_id (
    dataset_id VARCHAR2(32) NOT NULL,
    bioproject_id VARCHAR2(255) NOT NULL,
    description CLOB,
    PRIMARY KEY (dataset_id, bioproject_id),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_link (
    dataset_id VARCHAR2(32) NOT NULL,
    linked_dataset_id VARCHAR2(500) NOT NULL,
    linked_dataset_type VARCHAR2(5) NOT NULL,  -- VDI or WDK
    shares_records NUMBER(1) DEFAULT 0 NOT NULL,
    PRIMARY KEY (dataset_id, linked_dataset_id),
    FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset(dataset_id)
    );

CREATE INDEX idx_dataset_link ON VDI_CONTROL_&1..dataset_link(dataset_id);

-- convenience view showing datasets visible to a user that are fully installed, and not deleted
-- application code should use this view to find datasets a user can use
CREATE VIEW VDI_CONTROL_&1..AvailableUserDatasets AS
SELECT
    v.dataset_id as user_dataset_id,
    v.user_id,
    o.is_owner,
    d.type_name as type,
    o.accessibility,
    o.is_public,
    d.creation_date,
    m.name,
    m.description,
    m.summary,
    m.short_name,
    m.short_attribution,
    m.category,
    p.project_id
FROM
    VDI_CONTROL_&1..dataset_visibility v,
    VDI_CONTROL_&1..dataset d,
    VDI_CONTROL_&1..dataset_meta m,
    VDI_CONTROL_&1..dataset_project p,
    (SELECT dataset_id
     FROM VDI_CONTROL_&1..dataset_install_message
     WHERE install_type = 'meta'
     AND status = 'complete'
     INTERSECT
     SELECT dataset_id
     FROM VDI_CONTROL_&1..dataset_install_message
     WHERE install_type = 'data'
     AND status = 'complete'
    ) i,
    (select dataset_id, owner as user_id, 1 as is_owner, accessibility, is_public
    from VDI_CONTROL_&1..dataset
    union 
    select x.dataset_id, x.user_id, 0 as is_owner, 'private' as accessibility, 0 as is_public
    from (select dataset_id, user_id 
          from VDI_CONTROL_&1..dataset_visibility
          minus
          select dataset_id, owner as user_id
          from VDI_CONTROL_&1..dataset) x
    ) o
    WHERE d.dataset_id = i.dataset_id
    and v.user_id = o.user_id
    and d.dataset_id = v.dataset_id
    and d.dataset_id = m.dataset_id
    and d.dataset_id = p.dataset_id
    and d.dataset_id = o.dataset_id
    and d.is_deleted = 0;


GRANT SELECT ON VDI_CONTROL_&1..dataset                 TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..sync_control            TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_install_message TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_install_activity TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_dependency      TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_visibility      TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_project         TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_meta            TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_properties      TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_publication     TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_hyperlink       TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_organism        TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_contact         TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..AvailableUserDatasets   TO gus_r;

GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset                 TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..sync_control            TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_install_message TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_install_activity TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_dependency      TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_visibility      TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_project         TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_meta            TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_properties      TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_publication     TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_hyperlink       TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_organism        TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_contact         TO vdi_w;

GRANT REFERENCES ON VDI_CONTROL_&1..dataset TO VDI_DATASETS_&1;
GRANT CREATE SESSION, CREATE TABLE, CREATE ANY TABLE, CREATE VIEW, CREATE ANY INDEX, CREATE SEQUENCE TO VDI_DATASETS_&1;

exit;

