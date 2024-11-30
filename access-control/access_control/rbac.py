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

    # Create the engine
    engine = create_engine("postgresql+psycopg2://role_admin:adminpassword@localhost:5432/rbac_example")

    # Attach events
    event.listen(engine, "checkout", set_role('role1'))  # Set role on checkout
    event.listen(engine, "checkin", reset_role())       # Reset role on checkin

    db = SQLDatabase(engine)

    print(db.run("SELECT * FROM table1 LIMIT 10"))
    # [(1, 'Data for Table 1 - Row 1'), (2, 'Data for Table 1 - Row 2')]

    # This will error out as role1 doesn't have access to table2
    try:
        print(db.run("SELECT * FROM table2 LIMIT 10"))
    except Exception as e:
        print(e)
        # (psycopg2.errors.InsufficientPrivilege) permission denied for table table2

    # From here if db variable can be used with langchain objects and is ensure to only be able to access