#!/bin/bash
# allow users to connect
sed -i 's/host all all all md5//g' /var/lib/postgresql/data/pg_hba.conf
echo '# CONNECTIONS' >> /var/lib/postgresql/data/pg_hba.conf
echo 'host    otusdb       otususer     0.0.0.0/0      md5' >> /var/lib/postgresql/data/pg_hba.conf
echo 'host    all          postgres     172.0.0.0/8    md5' >> /var/lib/postgresql/data/pg_hba.conf

# restart postgres
pg_ctl reload
