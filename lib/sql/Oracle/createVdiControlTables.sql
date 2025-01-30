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
, is_deleted   NUMBER       DEFAULT 0   NOT NULL
, is_public    NUMBER       DEFAULT 0   NOT NULL
);


CREATE TABLE VDI_CONTROL_&1..dataset_meta (
  dataset_id  VARCHAR2(32)   PRIMARY KEY NOT NULL
, name        VARCHAR2(1024) NOT NULL
, short_name        VARCHAR2(300)
, short_attribution VARCHAR2(300)
, category VARCHAR2(100)
, summary VARCHAR2(4000)
, description CLOB
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

CREATE TABLE VDI_CONTROL_&1..dataset_publication (
  dataset_id  VARCHAR2(32)   NOT NULL
, pubmed_id        VARCHAR2(30) NOT NULL
, citation        VARCHAR2(2000) 
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_hyperlink (
  dataset_id  VARCHAR2(32)   NOT NULL
, url        VARCHAR2(200) NOT NULL
, text        VARCHAR2(300) NOT NULL
, description        VARCHAR2(4000)
, is_publication  number
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_organism (
  dataset_id  VARCHAR2(32)   NOT NULL
, organism_abbrev    varchar(20) NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_&1..dataset_contact (
  dataset_id  VARCHAR2(32)   NOT NULL
, is_primary  NUMBER NOT NULL
, name        VARCHAR2(300) NOT NULL
, email        VARCHAR2(4000)
, affiliation  VARCHAR2(4000)
, city        VARCHAR2(200)
, state        VARCHAR2(200)
, country        VARCHAR2(200)
, address        VARCHAR2(1000)
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_&1..dataset (dataset_id)
);

-- convenience view showing datasets visible to a user that are fully installed, and not deleted
-- application code should use this view to find datasets a user can use
CREATE VIEW VDI_CONTROL_&1..AvailableUserDatasets AS
SELECT
    v.dataset_id as user_dataset_id,
    v.user_id,
    o.is_owner,
    d.type_name as type,
    d.is_public,
    m.name,
    m.description,
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
    (select dataset_id, owner as user_id, 1 as is_owner
    from VDI_CONTROL_&1..dataset
    union 
    select x.dataset_id, x.user_id, 0 as is_owner
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
GRANT SELECT ON VDI_CONTROL_&1..dataset_visibility      TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_project         TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_meta            TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_publication     TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_hyperlink       TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_organism        TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_contact         TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..AvailableUserDatasets   TO gus_r;

GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset                 TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..sync_control            TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_install_message TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_install_activity TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_visibility      TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_project         TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_meta            TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_publication     TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_hyperlink       TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_organism        TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_contact         TO vdi_w;

GRANT REFERENCES ON VDI_CONTROL_&1..dataset TO VDI_DATASETS_&1;
GRANT CREATE SESSION, CREATE TABLE, CREATE ANY TABLE, CREATE VIEW, CREATE ANY INDEX, CREATE SEQUENCE TO VDI_DATASETS_&1;

exit;

