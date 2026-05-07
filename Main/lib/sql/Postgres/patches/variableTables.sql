        DO $$
        DECLARE
            rec      RECORD;
            ag_table TEXT;
        BEGIN
            FOR rec IN
                SELECT DISTINCT
                    s.stable_id AS dataset_id,
                    s.internal_abbrev                               AS study_abbrev,
                    e.internal_abbrev                               AS entity_abbrev
                FROM vdi_datasets_dev_n.study s
                JOIN vdi_datasets_dev_n.entitytypegraph e ON s.stable_id = e.study_stable_id
                WHERE s.internal_abbrev IS NOT NULL
            LOOP
                ag_table := 'vdi_datasets_dev_n.attributegraph_' || rec.study_abbrev || '_' || lower(rec.entity_abbrev);

                IF to_regclass(ag_table) IS NULL THEN
                    CONTINUE;
                END IF;

                EXECUTE format(
                    'INSERT INTO vdi_datasets_dev_n.AttributeCategoricalValue (study_stable_id, stable_id, value)
                     SELECT %L, ag.stable_id, v.value
                     FROM %s ag
                     CROSS JOIN LATERAL jsonb_array_elements_text(ag.vocabulary::jsonb) AS v(value)
                     WHERE ag.data_shape = %L
                       AND ag.vocabulary IS NOT NULL
                       AND ag.stable_id != %L',
                    rec.dataset_id,  -- %L: literal dataset_id value
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
                    s.stable_id AS dataset_id,
                    s.internal_abbrev                               AS study_abbrev,
                    e.internal_abbrev                               AS entity_abbrev
                FROM vdi_datasets_beta_s.study s
                JOIN vdi_datasets_beta_s.entitytypegraph e ON s.stable_id = e.study_stable_id
                WHERE s.internal_abbrev IS NOT NULL
            LOOP
                ag_table := 'vdi_datasets_beta_s.attributegraph_' || rec.study_abbrev || '_' || lower(rec.entity_abbrev);

                IF to_regclass(ag_table) IS NULL THEN
                    CONTINUE;
                END IF;

                EXECUTE format(
                    'INSERT INTO vdi_datasets_beta_s.attributegraph (study_stable_id, stable_id, bin_width_computed, bin_width_override, data_shape, data_type, definition, display_name, display_order, display_range_max, display_range_min, display_type, distinct_values_count, has_study_dependent_vocabulary, has_values, hidden, impute_zero, is_featured, is_merge_key, is_multi_valued, is_repeated, is_temporal, lower_quartile, mean, median, parent_stable_id, precision, provider_label, range_max, range_min, scale, unit, upper_quartile, variable_spec_to_impute_zeroes_for, weighting_variable_spec)
                     SELECT %L, stable_id, bin_width_computed, bin_width_override, data_shape, data_type, definition, display_name, display_order, display_range_max, display_range_min, display_type, distinct_values_count, has_study_dependent_vocabulary, has_values, hidden, impute_zero, is_featured, is_merge_key, is_multi_valued, is_repeated, is_temporal, lower_quartile, mean, median, parent_stable_id, precision, provider_label, range_max, range_min, scale, unit, upper_quartile, variable_spec_to_impute_zeroes_for, weighting_variable_spec
                     FROM %s ag
                     WHERE ag.stable_id != %L',
                    rec.dataset_id,  -- %L: literal dataset_id value
                    ag_table,        -- %s: attributegraph table
                    'VEUPATHDB_GENE_ID'  -- %L: exclude gene id variable
                );
            END LOOP;
        END $$;
