-- create dml role
-- dml = data modeling language 
-- 		i.e. role that can only perform CRUD operations on objects 
-- CRUD = Create Replace Update Delete

CREATE 
    ROLE ${DATABASE}_ro
    WITH ENCRYPTED PASSWORD '${DEFAULT_RO_PASSWORD}';

GRANT
    CONNECT,
    TEMPORARY
    ON DATABASE ${DATABASE}
   	TO ${DATABASE}_ro;

GRANT
    pg_read_all_data 
    TO ${DATABASE}_ro;
