-- run as user 'postgres' on database 'postgres'
-- used in conjunction with "pg_createdb.bash" which will replace all instances of ${DATABASE} with the provided database name

CREATE 
    DATABASE ${DATABASE};

-- revoke 'public' access
REVOKE ALL 
	ON DATABASE ${DATABASE}
	FROM PUBLIC;

REVOKE CREATE 
	ON SCHEMA public 
	FROM PUBLIC;
