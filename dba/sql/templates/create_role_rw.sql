-- create ddl role
-- ddl = data definition language
-- i.e. role that can create objects

CREATE 
    ROLE IF NOT EXISTS ${DATABASE}_${SCHEMA}_rw
    WITH ENCRYPTED PASSWORD '${DEFAULT_RW_PASSWORD}';

GRANT
    CONNECT,
    TEMPORARY
    ON DATABASE ${DATABASE}
   	TO ${DATABASE}_${SCHEMA}_rw;
    