from os import getenv
from os.path import abspath, dirname
from dotenv import load_dotenv
from psycopg2 import connect as pg_connect
from functools import wraps, partial

# source: https://stackoverflow.com/questions/3888158/making-decorators-with-optional-arguments#comment65959042_24617244


def SqlExecutor(
        method=None,
        *,
        default_host=True,
        default_port=True,
        default_dbname=True,
        default_user=True,
        default_password=True
):
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
        load_env()

        if default_host:
            host = getenv("POSTGRES_HOST")
        else:
            host = kwargs.get("host")
        print(host)
        method(*args, **kwargs)
    return wrapper


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


@SqlExecutor(default_host=False)
def test(host=None):
    print("my test")
