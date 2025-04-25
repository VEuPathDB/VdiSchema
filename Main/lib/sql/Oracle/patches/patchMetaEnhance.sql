ALTER TABLE VDI_CONTROL_@SUFFIX@.dataset ADD COLUMN accessibility varchar(30);
ALTER TABLE VDI_CONTROL_@SUFFIX@.dataset ADD COLUMN days_for_approval number;
ALTER TABLE VDI_CONTROL_@SUFFIX@.dataset ADD COLUMN creation_date DATE;

CREATE TABLE VDI_CONTROL_@SUFFIX@.dataset_properties (
  dataset_id      VARCHAR2(32)   PRIMARY KEY NOT NULL
, JSON   CLOB   
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_@SUFFIX@.dataset (dataset_id)
);

drop VIEW VDI_CONTROL_@SUFFIX@.AvailableUserDatasets;
CREATE VIEW VDI_CONTROL_@SUFFIX@.AvailableUserDatasets AS
SELECT
    v.dataset_id as user_dataset_id,
    v.user_id,
    o.is_owner,
    d.type_name as type,
    o.accessibility,
    d.creation_date,
    m.name,
    m.description,
    m.summary,
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
    (select dataset_id, owner as user_id, 1 as is_owner, accessibility
    from VDI_CONTROL_@SUFFIX@.dataset
    union 
    select x.dataset_id, x.user_id, 0 as is_owner, 'private' as accessibility
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


GRANT SELECT ON VDI_CONTROL_@SUFFIX@.dataset_property   TO gus_r;
GRANT SELECT ON VDI_CONTROL_@SUFFIX@.AvailableUserDatasets   TO gus_r;

GRANT DELETE, INSERT, SELECT, UPDATE ON VDI_CONTROL_@SUFFIX@.dataset_property     TO vdi_w;


