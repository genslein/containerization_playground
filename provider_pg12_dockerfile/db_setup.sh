#!/bin/bash

# assumes already postgres user: su postgres
# initdb and setup
touch /tmp/pwdfile && echo "postgres_pass" > /tmp/pwdfile

env                                                                   \
LC_COLLATE=en_US.UTF-8                                                \
LC_CTYPE=en_US.UTF-8                                                  \
LC_MESSAGES=en_US.UTF-8                                               \
LC_MONETARY=en_US.UTF-8                                               \
LC_NUMERIC=en_US.UTF-8                                                \
LC_TIME=en_US.UTF-8                                                   \
/usr/lib/postgresql/12/bin/initdb -D /database -E UTF8 -U postgres --pwfile=/tmp/pwdfile

rm /tmp/pwdfile

mkdir -p /database/pgextwlist/pg_stat_statements && touch /database/pgextwlist/pg_stat_statements/after-create.sql;
echo "GRANT EXECUTE ON FUNCTION pg_stat_statements_reset(Oid, Oid, bigint) TO test_user;" >> /database/pgextwlist/pg_stat_statements/after-create.sql;

#Update configuration to use pgextwlist

cat <<EOF >> /database/postgresql.conf
shared_preload_libraries = 'pg_stat_statements'
local_preload_libraries = pgextwlist
extwlist.extensions = 'pg_stat_statements'
extwlist.custom_path = '/database/pgextwlist'
EOF

# Start process, create user/db
/usr/lib/postgresql/12/bin/pg_ctl -D /database -l /logfile start

PGPASSWORD=postgres_pass psql -p 5432 -U postgres <<EOF
SET log_statement TO 'none';
ALTER ROLE postgres WITH PASSWORD 'postgres_pass';
ALTER ROLE postgres SET search_path = 'pg_catalog';
REVOKE ALL ON DATABASE postgres FROM PUBLIC;
CREATE ROLE test_user;
ALTER ROLE test_user WITH LOGIN PASSWORD 'test_user_pass' NOSUPERUSER NOCREATEDB NOCREATEROLE;
REVOKE ALL ON DATABASE postgres FROM test_user;
CREATE DATABASE test_db OWNER test_user;
REVOKE ALL ON DATABASE template1 FROM PUBLIC;
REVOKE ALL ON DATABASE test_db FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT CONNECT ON DATABASE test_db TO test_user;
GRANT ALL ON DATABASE test_db TO test_user;
GRANT ALL ON SCHEMA public TO test_user;
SELECT version();
EOF

echo "host all  all    0.0.0.0/0  md5" >> /database/pg_hba.conf

PGPASSWORD=postgres_pass psql -U postgres -d postgres -c 'CREATE EXTENSION pg_stat_statements WITH SCHEMA public'

PGPASSWORD=test_user_pass psql -U test_user -d test_db -c 'CREATE EXTENSION pg_stat_statements WITH SCHEMA public'

PGPASSWORD=postgres_pass psql -U postgres -d postgres -c 'SELECT * FROM pg_extension'

PGPASSWORD=test_user_pass psql -U test_user -d test_db -c 'SELECT * FROM pg_extension'
