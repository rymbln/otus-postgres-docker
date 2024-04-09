DO
$do$
BEGIN
	IF NOT EXISTS (SELECT FROM   pg_catalog.pg_roles WHERE rolname = 'otususer') THEN
    	CREATE ROLE otususer WITH LOGIN PASSWORD 'otuspassword';
	END IF;
END
$do$;

DO
$do$
BEGIN
	IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'otusdb') THEN
    	CREATE DATABASE otusdb
				WITH OWNER = otususer
					ENCODING = 'utf8'
					TABLESPACE = pg_default
					LC_COLLATE = 'en_US.utf8'
					LC_CTYPE = 'en_US.utf8'
					CONNECTION LIMIT = -1;
	END IF;
	GRANT CONNECT, TEMPORARY ON DATABASE otusdb TO public;
	GRANT ALL ON DATABASE otusdb TO otususer;
	ALTER ROLE otususer SUPERUSER;
END
$do$;
