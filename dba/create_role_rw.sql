-- create ddl role
-- ddl = data definition language
-- i.e. role that can create objects

CREATE 
    ROLE ${DATABASE}_rw
    WITH ENCRYPTED PASSWORD '${DEFAULT_RW_PASSWORD}';

GRANT
    ALL
    ON DATABASE ${DATABASE}
   	TO ${DATABASE}_rw;

GRANT
    pg_write_all_data 
    TO ${DATABASE}_rw;

GRANT
    pg_read_all_data 
    TO ${DATABASE}_rw;
