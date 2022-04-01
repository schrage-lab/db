-- run as user 'postgres' on database 'postgres'
-- used in conjunction with "pg_createdb.bash" which will replace all instances of ${DATABASE} with the provided database name
-- ddl = data definition language
-- 		i.e. role that can create and use objects
-- dml = data modeling language 
-- 		i.e. role that can only perform CRUD operations on objects 
-- CRUD = Create Replace Update Delete

CREATE 
    DATABASE ${DATABASE};

-- revoke 'public' access
REVOKE ALL 
	ON DATABASE ${DATABASE}
	FROM PUBLIC;

REVOKE CREATE 
	ON SCHEMA public 
	FROM PUBLIC;

-- create ddl role
-- i.e. role that can create objects
CREATE 
    ROLE ${DATABASE}_ddl_role;

GRANT
    CONNECT
    ON DATABASE ${DATABASE}
   	TO ${DATABASE}_ddl_role;

GRANT
    TEMPORARY
    ON DATABASE ${DATABASE} 
   	TO ${DATABASE}_ddl_role;

-- create dml role
-- i.e. one that only has CRUD options on objects
CREATE 
    ROLE ${DATABASE}_dml_role;

GRANT
    CONNECT
    ON DATABASE ${DATABASE} 
   	TO ${DATABASE}_dml_role;

GRANT
    TEMPORARY
    ON DATABASE ${DATABASE} 
	TO ${DATABASE}_dml_role;