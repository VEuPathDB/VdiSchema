# VdiSchema
SQL and scripts to install the VDI control and datasets schemas

This repo includes a library of SQL scripts that create and drop the VDI schemas, and also the `installVdiSchema` program.

It is intended to run in a Docker container.

To run `installVdiSchema` outside a container, clone the `lib-schema-install-utils` repo, and copy `lib-schema-install-utils/lib/perl/SchemaInstallUtils.pm` into `VdiSchema/lib/perl`


