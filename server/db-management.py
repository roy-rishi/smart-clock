import sqlite3

# create databases
alarms_db = sqlite3.connect("db/alarms.db").cursor()

# create alarms table
alarms_db.execute("""CREATE TABLE Alarms (
                  Time TEXT NOT NULL,
                  Routine TEXT NOT NULL
                  )""")
