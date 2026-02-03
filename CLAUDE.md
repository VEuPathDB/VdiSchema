# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

VdiSchema is a database schema management tool for the VDI (User Dataset) system. It manages SQL schemas and tables across Oracle and Postgres databases in a multi-environment setup with lifecycle stages (dev, qa, feat, beta, prod) and campus locations (north/south).

## Architecture

### Dual Schema Design

The VDI system maintains two separate schemas per environment:

1. **VDI_CONTROL_[LIFECYCLE]_[CAMPUS]**: Metadata and control tables
   - Dataset registry and metadata
   - Sync control and installation messages
   - Project and contact information

2. **VDI_DATASETS_[LIFECYCLE]_[CAMPUS]**: User dataset tables
   - Gene IDs, profile sets, protocol app nodes
   - Study information and entity graphs
   - Dataset-specific content

### Schema Naming Convention

Schemas are suffixed with `{LIFECYCLE}_{CAMPUS}` in uppercase:
- Lifecycle: `dev`, `qa`, `feat`, `beta`, `prod`
- Campus: `n` (north), `s` (south)
- Example: `VDI_CONTROL_QA_N`, `VDI_DATASETS_PROD_S`

### Database Platform Differences

**Oracle**:
- Schemas are user objects managed by DBA
- `installVdiSchema` only creates tables within existing schemas
- Uses parameterized SQL with `&1.` macro for schema suffix

**Postgres**:
- `installVdiSchema` creates both schemas and tables
- Uses `:VAR1` for variable substitution
- Requires `createVdiSchemas.sql` to run first

## Development Commands

### Installation

**Single database installation:**
```bash
export DB_PLATFORM=Oracle  # or Postgres
export DB_USER=<your-login>
export DB_PASS=<your-password>

./Main/bin/installVdiSchema \
  --dbName <db-name> \
  --dbHost <host> \
  --create \
  --lifecycle dev \
  --campus n
```

**Bulk installation across multiple databases:**
```bash
./Main/bin/bulkInstallVdiSchema \
  --logFile mylog.txt \
  --dbCampusName penn \
  --create \
  --dbDescriptors 'plas-inc:ares9,toxo-inc:ares8' \
  --campusInitials 'n,s' \
  --lifecycles 'dev,qa'
```

### Schema Removal

**Drop schemas (with confirmation):**
```bash
./Main/bin/installVdiSchema \
  --dbName <db-name> \
  --dbHost <host> \
  --drop \
  --lifecycle dev \
  --campus n
```

For Oracle: drops all tables within the schema
For Postgres: drops the entire schema

### Patching

**Apply patches across multiple databases:**
```bash
./Main/bin/bulkPatchVdiSchema \
  --dbNames 'plas-inc,toxo-inc' \
  --sqlFile Main/lib/sql/Oracle/patches/patchFile.sql \
  --forReal
```

Omit `--forReal` for dry-run mode. Patch SQL files can use `@SUFFIX@` macro which gets replaced with the lifecycle_campus suffix (e.g., `QA_N`).

### Build System

This project integrates with the GUS build system via Ant:
```bash
ant VdiSchema-Installation
```

Dependencies: `SchemaInstallUtils` project must be available in `${projectsDir}`.

## SQL Organization

### Main SQL Files

**Oracle**: `Main/lib/sql/Oracle/`
- `createVdiControlTables.sql` - Control schema tables
- `createUserDatasetTypeTables.sql` - Dataset schema tables
- `createEntityGraphTables.sql` - Entity graph tables

**Postgres**: `Main/lib/sql/Postgres/`
- `createVdiSchemas.sql` - Schema creation (run first)
- Same table creation files as Oracle

### Patches

Located in `Main/lib/sql/Oracle/patches/`:
- `patchUpgradeMetaTables.sql`
- `patchMetaEnhance.sql`
- `patchDependencies.sql`
- `patchDescription.sql`
- `createViewPatch.sql`

Patches support the `@SUFFIX@` macro for dynamic schema targeting.

## Key Architectural Concepts

### Parameterized SQL

All SQL files use platform-specific parameter substitution:
- **Oracle**: `&1.` macro filled by sqlplus
- **Postgres**: `:VAR1` variable substitution

The `LIFECYCLE_CAMPUS` suffix (e.g., `DEV_N`) is passed as the parameter to create environment-specific schemas.

### Perl Utilities

Scripts use `SchemaInstallUtils::Main::Utils` module providing:
- `runSql()` - Execute SQL files with parameter substitution
- `dropSchemaSetTables()` - Drop all objects in Oracle schemas
- `dropSchemaSetPostgres()` - Drop Postgres schemas
- `getDbh()` - Get database handle for Oracle or Postgres

### Installation Order

1. For Postgres: Create schemas first (`createVdiSchemas.sql`)
2. Create control tables (`createVdiControlTables.sql`)
3. Create user dataset type tables (`createUserDatasetTypeTables.sql`)
4. Create entity graph tables (`createEntityGraphTables.sql`)

### Foreign Key Relationships

Dataset tables in `VDI_DATASETS_*` reference the `dataset` table in corresponding `VDI_CONTROL_*` schema, enforcing referential integrity across schemas.

## Environment Variables

Required for all operations:
- `DB_PLATFORM`: `Oracle` or `Postgres`
- `DB_USER`: Database login
- `DB_PASS`: Database password

## Common Database Targets

Inc databases: `ameb-inc`, `cryp-inc`, `eda-inc`, `fung-inc`, `giar-inc`, `host-inc`, `micr-inc`, `piro-inc`, `plas-inc`, `toxo-inc`, `tryp-inc`, `tvag-inc`, `vect-inc`

Host format: `<host>.<campus>.apidb.org` (e.g., `ares9.penn.apidb.org`)
