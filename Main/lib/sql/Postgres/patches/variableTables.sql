        DO $$
        DECLARE
            rec      RECORD;
            ag_table TEXT;
        BEGIN
            FOR rec IN
                SELECT DISTINCT
                    s.stable_id AS study_id,
                    s.user_dataset_id AS dataset_id,
                    e.stable_id AS entity_id,
                    s.internal_abbrev                               AS study_abbrev,
                    e.internal_abbrev                               AS entity_abbrev
                FROM vdi_datasets_dev_s.study s
                JOIN vdi_datasets_dev_s.entitytypegraph e ON s.stable_id = e.study_stable_id
                WHERE s.internal_abbrev IS NOT NULL
            LOOP
                ag_table := 'vdi_datasets_dev_s.attributegraph_' || rec.study_abbrev || '_' || lower(rec.entity_abbrev);

                IF to_regclass(ag_table) IS NULL THEN
                    CONTINUE;
                END IF;

                EXECUTE format(
                    'INSERT INTO vdi_datasets_dev_s.VariableCategoricalValue (study_stable_id, dataset_id, entity_stable_id, stable_id, value)
                     SELECT %L, %L, %L, ag.stable_id, v.value
                     FROM %s ag
                     CROSS JOIN LATERAL jsonb_array_elements_text(ag.vocabulary::jsonb) AS v(value)
                     WHERE ag.data_shape = %L
                       AND ag.vocabulary IS NOT NULL
                       AND ag.stable_id != %L',
                    rec.study_id,  -- %L: literal study_id value
                    rec.dataset_id,  -- %L: literal dataset_id value
                    rec.entity_id,  -- %L: literal entity_id value
                    ag_table,        -- %s: attributegraph table
                    'categorical',   -- %L: data_shape filter
                    'VEUPATHDB_GENE_ID'  -- %L: exclude gene id variable
                );
            END LOOP;
        END $$;

--------------------------------------------------------------

        DO $$
        DECLARE
            rec      RECORD;
            ag_table TEXT;
        BEGIN
            FOR rec IN
                SELECT DISTINCT
                    s.user_dataset_id AS dataset_id,
                    s.stable_id AS study_id,
                    e.stable_id AS entity_id,
                    s.internal_abbrev                               AS study_abbrev,
                    e.internal_abbrev                               AS entity_abbrev
                FROM vdi_datasets_dev_s.study s
                JOIN vdi_datasets_dev_s.entitytypegraph e ON s.stable_id = e.study_stable_id
                WHERE s.internal_abbrev IS NOT NULL
            LOOP
                ag_table := 'vdi_datasets_dev_s.attributegraph_' || rec.study_abbrev || '_' || lower(rec.entity_abbrev);

                IF to_regclass(ag_table) IS NULL THEN
                    CONTINUE;
                END IF;

                EXECUTE format(
                    'INSERT INTO vdi_datasets_dev_s.variable (dataset_id, study_stable_id, entity_stable_id, stable_id, data_shape, data_type, definition, display_name, display_range_max, display_range_min, provider_label, hidden)
                     SELECT %L, %L, %L, stable_id, data_shape, data_type, definition, display_name, display_range_max, display_range_min, provider_label, hidden
                     FROM %s ag
                     WHERE ag.stable_id != %L',
                    rec.dataset_id,  -- %L: literal dataset_id value
                    rec.study_id,  -- %L: literal study_id value
                    rec.entity_id,  -- %L: literal entity_stable_id value
                    ag_table,        -- %s: attributegraph table
                    'VEUPATHDB_GENE_ID'  -- %L: exclude gene id variable
                );
            END LOOP;
        END $$;
