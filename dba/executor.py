from psycopg2 import connect as pg_connect
from os import getenv
from os.path import abspath, dirname
from dotenv import load_dotenv
from functools import wraps


# if params for SqlExecutor is true -> pull from kwargs else pull from env

def SqlExecutor(*,
        host=False,
        port=False,
        dbname=False,
        user=False,
        password=False
):
    def _decorate(function):
        @wraps(function)
        def wrapper(*args, **kwargs):



            if host:
                host = kwargs.get("host")
            else:
                host = getenv("POSTGRES_HOST")

            if port:
                port = kwargs.get("port")
            else:
                port = getenv("POSTGRES_PORT")

            if not dbname:
                getenv("POSTGRES_DATABASE")
            if not user:
                getenv("POSTGRES_USER")
            if not password:
                getenv("POSTGRES_PASSWORD")


            # get prepared sql statement
            # query = func(*args, **kwargs)

            # execute sql statement
            # with conn.cursor() as cur:
            #     cur.execute(query)

            # close db connection
            # conn.close()

            return function(*args, **kwargs)
        return wrapper
    return _decorate

def load_env():
    fpath = f"{abspath(dirname(__file__))}/.env"
    load_dotenv(dotenv_path=fpath)


def create_db_connection(
        *,
        host: str = None,
        port: str = None,
        dbname: str = None,
        user: str = None,
        password: str = None
) -> pg_connect:

    conn = pg_connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password
    )

    conn.autocommit = True
    return conn
