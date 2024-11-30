from langchain_community.utilities import SQLDatabase
from sqlalchemy import create_engine, event


if __name__ == "__main__":
    # ensure user is set before running any query
    def set_user(user):
        def set_current_user(dbapi_conn, connection_rec, connection_proxy):
            cursor = dbapi_conn.cursor()
            cursor.execute(f"SET app.current_user_id='{user}';")
            cursor.close()
        return set_current_user

    # ensure user is reset after running any query
    def reset_user():
        def reset_current_user(dbapi_conn, connection_rec):
            cursor = dbapi_conn.cursor()
            cursor.execute("RESET app.current_user_id;")
            cursor.close()
        return reset_current_user

    engine = create_engine("postgresql+psycopg2://example:example@localhost:5432/rls_example")

    # automatically set user id before running any query
    event.listen(engine, "checkout", set_user('101'))
    event.listen(engine, "checkin", reset_user())

    db = SQLDatabase(engine)

    print(db.run("SELECT * FROM purchase LIMIT 10"))
    # [(2, 102, 'Smartphone', 2, datetime.date(2024, 11, 21))]

    # Only returns rows from user 101
    # db variable can now be passed into langchain objects (e.g. create_sql_agent) and will only be able to access data from user 101