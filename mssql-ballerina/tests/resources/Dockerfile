FROM microsoft/mssql-server-linux

COPY keystore/server/mssql.pem /etc/ssl/certs/mssql.pem
COPY keystore/server/mssql.key /etc/ssl/private/mssql.key

USER root
RUN chmod 777 /etc/ssl/certs/mssql.pem
RUN chmod 777 /etc/ssl/private/mssql.key

RUN /opt/mssql/bin/mssql-conf set network.tlscert /etc/ssl/certs/mssql.pem
RUN /opt/mssql/bin/mssql-conf set network.tlskey /etc/ssl/private/mssql.key
RUN /opt/mssql/bin/mssql-conf set network.tlsprotocols 1.2
RUN /opt/mssql/bin/mssql-conf set network.forceencryption 1

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=DefaultPassword123
