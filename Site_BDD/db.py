import psycopg2
import psycopg2.extras

# Version pour se connecter au serveur de la fac
def connect():
    conn = psycopg2.connect(
    host = 'sqledu.univ-eiffel.fr',
    dbname = 'zelia_db', # nom de votre base de données
    password = 'miaou18', # mot de passe de la base
    cursor_factory = psycopg2.extras.NamedTupleCursor,
    )
    conn.autocommit = True
    return conn

# Version pour se connecter chez nous
"""def connect():
    conn = psycopg2.connect(
    dbname = "DemoPsyco",
    cursor_factory = psycopg2.extras.NamedTupleCursor,
    )p
    conn.autocommit = True
    return conn
    """