from os import getenv
from os.path import abspath, dirname
from dotenv import load_dotenv
from psycopg2 import connect as pg_connect
from functools import wraps, partial


def SqlExecutor(
        method=None,
        *,
        default_host=True,
        default_port=True,
        default_dbname=True,
        default_user=True,
        default_password=True
):
    """
    Decorator for prepared sql statements

    :param method: function handle. Used to determine if the decorator was passed any non-default arguments.
                    Do not change.
    :type method: callable
    :param default_host: Use the default database server host as configured in the .env file. Default = True.
    :type default_host: bool
    :param default_port: Use the default database server port as configured in the .env file. Default = True.
    :type default_port: bool
    :param default_dbname: Use the default database name as configured in the .env file. Default = True.
    :type default_dbname: bool
    :param default_user: Use the default database user host as configured in the .env file. Default = True.
    :type default_user: bool
    :param default_password: Use the default database user password host as configured in the .env file. Default = True.
    :type default_password: bool
    :return: None

    source: https://stackoverflow.com/questions/3888158/making-decorators-with-optional-arguments#comment65959042_24617244
    """

    # if decorator not called with any different args
    if not callable(method):
        return partial(
            SqlExecutor,
            default_host=default_host,
            default_port=default_port,
            default_dbname=default_dbname,
            default_user=default_user,
            default_password=default_password
        )

    @wraps(method)
    def wrapper(*args, **kwargs):
        fpath = f"{abspath(dirname(__file__))}/.env"
        load_dotenv(dotenv_path=fpath)

        if default_host:
            host = getenv("POSTGRES_HOST")
        else:
            host = kwargs.get("host")

        if default_port:
            port = getenv("POSTGRES_PORT")
        else:
            port = kwargs.get("port")

        if default_dbname:
            database = getenv("POSTGRES_DATABASE")
        else:
            database = kwargs.get("database")

        if default_user:
            user = getenv("POSTGRES_USER")
        else:
            user = kwargs.get("user")

        if default_password:
            password = getenv("POSTGRES_PASSWORD")
        else:
            password = kwargs.get("password")

        conn = pg_connect(
            host=host,
            port=port,
            dbname=database,
            user=user,
            password=password
        )

        conn.autocommit = True

        # get prepared sql statement
        query = method(*args, **kwargs)

        # execute sql statement
        with conn.cursor() as cur:
            cur.execute(query)

        # close db connection
        conn.close()

    return wrapper
