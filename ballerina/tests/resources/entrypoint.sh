#!/bin/bash

set -e

# Set TLS settings
/opt/mssql/bin/mssql-conf set network.tlscert /etc/ssl/certs/mssql.pem
/opt/mssql/bin/mssql-conf set network.tlskey /etc/ssl/private/mssql.key
/opt/mssql/bin/mssql-conf set network.tlsprotocols 1.2
/opt/mssql/bin/mssql-conf set network.forceencryption 1

# Start SQL Server
/opt/mssql/bin/sqlservr
