-- revoke default connections to db
DO
$$
BEGIN
   EXECUTE (
	   SELECT string_agg(format('REVOKE CONNECT ON DATABASE %I FROM public', datname), '; ')
	   FROM   pg_database
   );
END
$$;
