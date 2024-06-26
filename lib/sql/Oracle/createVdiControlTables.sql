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
, description VARCHAR2(4000)
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

-- convenience view showing datasets visible to a user that are fully installed, and not deleted
-- application code should use this view to find datasets a user can use
CREATE VIEW VDI_CONTROL_&1..AvailableUserDatasets AS
SELECT
    v.dataset_id as user_dataset_id,
    v.user_id,
    d.is_public,
    d.type_name as type,
    m.name,
    m.description,
    p.project_id
FROM
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
    (SELECT dataset_id, user_id
     FROM VDI_CONTROL_&1..dataset_visibility
     UNION
     SELECT dataset_id, NULL as user_id
     FROM VDI_CONTROL_&1..dataset d
     WHERE d.is_public = 1
    ) v
    WHERE v.dataset_id = i.dataset_id
    and v.dataset_id = d.dataset_id
    and v.dataset_id = m.dataset_id
    and v.dataset_id = p.dataset_id
    and d.is_deleted = 0;

GRANT SELECT ON VDI_CONTROL_&1..dataset                 TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..sync_control            TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_install_message TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_install_activity TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_visibility      TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_project         TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..dataset_meta            TO gus_r;
GRANT SELECT ON VDI_CONTROL_&1..AvailableUserDatasets   TO gus_r;

GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset                 TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..sync_control            TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_install_message TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_install_activity TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_visibility      TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_project         TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_&1..dataset_meta            TO vdi_w;


GRANT REFERENCES ON VDI_CONTROL_&1..dataset TO VDI_DATASETS_&1;
GRANT CREATE SESSION, CREATE TABLE, CREATE ANY TABLE, CREATE VIEW, CREATE ANY INDEX, CREATE SEQUENCE TO VDI_DATASETS_&1;

exit;
