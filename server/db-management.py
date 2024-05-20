import sqlite3

# create databases
alarms_db = sqlite3.connect("db/alarms.db").cursor()

# create alarms table
alarms_db.execute("""CREATE TABLE Alarms (
                  Hour INT NOT NULL,
                  Minute INT NOT NULL,
                  Routine TEXT NOT NULL
                  )""")
