-- run as user 'postgres' on database 'postgres'
-- ddl = data definition language
-- 		i.e. role that can create and use objects
-- dml = data modeling language 
-- 		i.e. role that can only perform CRUD operations on objects 
-- CRUD = Create Replace Update Delete

CREATE DATABASE :name;

-- revoke 'public' access
REVOKE ALL 
	ON DATABASE :name
	FROM PUBLIC;

REVOKE CREATE 
	ON SCHEMA public 
	FROM PUBLIC;

-- create ddl role
-- i.e. role that can create objects
CREATE ROLE db_:name_ddl;

GRANT
    CONNECT
    ON DATABASE :name
   	TO db_:name_ddl;

GRANT
    TEMPORARY
    ON DATABASE :name 
   	TO db_:name_ddl;

-- create dml role
-- i.e. one that only has CRUD options on objects
CREATE ROLE db_:name_dml;

GRANT
    CONNECT
    ON DATABASE :name 
   	TO db_:name_dml;

GRANT
    TEMPORARY
    ON DATABASE :name 
	TO db_:name_dml;