CREATE VIEW VDI_DATASETS_@SUFFIX@.AvailableUserDatasets AS
SELECT
    v.dataset_id as user_dataset_id,
    v.user_id,
    d.type_name as type,
    m.name,
    m.description
FROM
    VDI_CONTROL_@SUFFIX@.dataset_visibility v,
    VDI_CONTROL_@SUFFIX@.dataset d,
    VDI_CONTROL_@SUFFIX@.dataset_meta m,
    (SELECT dataset_id
     FROM VDI_CONTROL_@SUFFIX@.dataset_install_message
     WHERE install_type = 'meta'
     AND status = 'complete'
     INTERSECT
     SELECT dataset_id
     FROM VDI_CONTROL_@SUFFIX@.dataset_install_message
     WHERE install_type = 'data'
     AND status = 'complete'
    ) i
    WHERE v.dataset_id = i.dataset_id
    and v.dataset_id = d.dataset_id
    and v.dataset_id = m.dataset_id
    and d.is_deleted = 0;
