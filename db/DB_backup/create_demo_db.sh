#!/bin/bash
### This script assumes to be used in the context of Docker-Compose
# 1-define environment
echo "db:5432:dqm_db:postgres:postgres" > .pgpass
PGPASSFILE=".pgpass"
export PGPASSFILE
# 2-create a user, database and schemas
psql -h db -w -U postgres <<-EOSQL
  CREATE USER dqm WITH PASSWORD 'dqmApp';
  CREATE DATABASE dqm_db OWNER dqm;
  \connect dqm_db
  CREATE SCHEMA dqm_app AUTHORIZATION dqm;
EOSQL
# 3-restore the demo database
pg_restore -h db -w -d dqm_db -U postgres < demo_db.tar
