reset role;   -- resets to GUS_W, which is needed to create schemas
create schema VDI_CONTROL_:VAR1 AUTHORIZATION vdi_w;
GRANT USAGE ON SCHEMA VDI_CONTROL_:VAR1 TO gus_r;

create schema VDI_DATASETS_:VAR1 AUTHORIZATION vdi_w;
GRANT USAGE ON SCHEMA VDI_DATASETS_:VAR1 TO gus_r;
