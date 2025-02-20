ALTER TABLE VDI_CONTROL_@SUFFIX@.dataset_meta RENAME COLUMN description TO old_description;
ALTER TABLE  VDI_CONTROL_@SUFFIX@.dataset_meta ADD description clob;
UPDATE VDI_CONTROL_@SUFFIX@.dataset_meta SET description = old_description;
ALTER TABLE  VDI_CONTROL_@SUFFIX@.dataset_meta ADD summary varchar2(4000);
ALTER TABLE  VDI_CONTROL_@SUFFIX@.dataset_meta ADD category varchar2(100);
ALTER TABLE  VDI_CONTROL_@SUFFIX@.dataset_meta ADD short_name varchar2(300);
ALTER TABLE  VDI_CONTROL_@SUFFIX@.dataset_meta ADD short_attribution varchar2(300);

CREATE TABLE VDI_CONTROL_@SUFFIX@.dataset_publication (
  dataset_id  VARCHAR2(32)   NOT NULL
, pubmed_id        VARCHAR2(30) NOT NULL
, citation        VARCHAR2(2000) 
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_@SUFFIX@.dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_@SUFFIX@.dataset_hyperlink (
  dataset_id  VARCHAR2(32)   NOT NULL
, url        VARCHAR2(200) NOT NULL
, text        VARCHAR2(300) NOT NULL
, description        VARCHAR2(4000)
, is_publication        number
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_@SUFFIX@.dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_@SUFFIX@.dataset_organism (
  dataset_id  VARCHAR2(32)   NOT NULL
, organism_abbrev varchar(200) NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_@SUFFIX@.dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_@SUFFIX@.dataset_contact (
  dataset_id  VARCHAR2(32)   NOT NULL
, is_primary  NUMBER NOT NULL
, name        VARCHAR2(300) NOT NULL
, email        VARCHAR2(4000)
, affiliation  VARCHAR2(4000)
, city        VARCHAR2(200)
, state        VARCHAR2(200)
, country        VARCHAR2(200)
, address        VARCHAR2(1000)
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_@SUFFIX@.dataset (dataset_id)
);

drop VIEW VDI_CONTROL_@SUFFIX@.AvailableUserDatasets;

-- convenience view showing datasets visible to a user that are fully installed, and not deleted
-- application code should use this view to find datasets a user can use
CREATE VIEW VDI_CONTROL_@SUFFIX@.AvailableUserDatasets AS
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
    VDI_CONTROL_@SUFFIX@.dataset_visibility v,
    VDI_CONTROL_@SUFFIX@.dataset d,
    VDI_CONTROL_@SUFFIX@.dataset_meta m,
    VDI_CONTROL_@SUFFIX@.dataset_project p,
    (SELECT dataset_id
     FROM VDI_CONTROL_@SUFFIX@.dataset_install_message
     WHERE install_type = 'meta'
     AND status = 'complete'
     INTERSECT
     SELECT dataset_id
     FROM VDI_CONTROL_@SUFFIX@.dataset_install_message
     WHERE install_type = 'data'
     AND status = 'complete'
    ) i,
    (select dataset_id, owner as user_id, 1 as is_owner
    from VDI_CONTROL_@SUFFIX@.dataset
    union 
    select x.dataset_id, x.user_id, 0 as is_owner
    from (select dataset_id, user_id 
          from VDI_CONTROL_@SUFFIX@.dataset_visibility
          minus
          select dataset_id, owner as user_id
          from VDI_CONTROL_@SUFFIX@.dataset) x
    ) o
    WHERE d.dataset_id = i.dataset_id
    and v.user_id = o.user_id
    and d.dataset_id = v.dataset_id
    and d.dataset_id = m.dataset_id
    and d.dataset_id = p.dataset_id
    and d.dataset_id = o.dataset_id
    and d.is_deleted = 0;

GRANT SELECT ON VDI_CONTROL_@SUFFIX@.dataset_publication     TO gus_r;
GRANT SELECT ON VDI_CONTROL_@SUFFIX@.dataset_hyperlink       TO gus_r;
GRANT SELECT ON VDI_CONTROL_@SUFFIX@.dataset_organism        TO gus_r;
GRANT SELECT ON VDI_CONTROL_@SUFFIX@.dataset_contact         TO gus_r;
GRANT SELECT ON VDI_CONTROL_@SUFFIX@.AvailableUserDatasets   TO gus_r;

GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_@SUFFIX@.dataset_publication     TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_@SUFFIX@.dataset_hyperlink       TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_@SUFFIX@.dataset_organism        TO vdi_w;
GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_@SUFFIX@.dataset_contact         TO vdi_w;
