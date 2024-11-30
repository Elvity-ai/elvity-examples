# Example: Switch roles in the application
from langchain_community.utilities import SQLDatabase
from sqlalchemy import create_engine, event

if __name__ == "__main__":
    # ensure user is set before running any query
    def set_role(role):
        def set_current_role(dbapi_conn, connection_rec, connection_proxy):
            cursor = dbapi_conn.cursor()
            cursor.execute(f"SET ROLE '{role}';")
            cursor.close()
        return set_current_role

    # ensure user is reset after running any query
    def reset_role():
        def reset_current_role(dbapi_conn, connection_rec):
            cursor = dbapi_conn.cursor()
            cursor.execute("RESET ROLE;")  # Resets the role to the default role
            cursor.close()
        return reset_current_role

    # Login using role_admin, so we can switch roles for access control
    engine = create_engine("postgresql+psycopg2://app_role:app_role_password@localhost:5432/rbac_example")

    # Attach events. Set apporpriate role before running any query
    event.listen(engine, "checkout", set_role('finance'))  # Set role on checkout
    event.listen(engine, "checkin", reset_role())       # Reset role on checkin

    db = SQLDatabase(engine)

    print(db.run("SELECT * FROM revenue LIMIT 10"))
    # [(1, datetime.datetime(2022, 1, 1, 0, 0), 'XYZ Corp', 'development', Decimal('500.00'))]

    # This will error out as finance role doesn't have access to salaries
    try:
        print(db.run("SELECT * FROM salaries LIMIT 10"))
    except Exception as e:
        print(e)
        # (psycopg2.errors.InsufficientPrivilege) permission denied for table salaries

    # From here if db variable can be used with langchain objects and is ensure to only be able to access