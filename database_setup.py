import sqlite3

# 1. Connect to a local file (it creates 'streampulse.db')
conn = sqlite3.connect('streampulse.db')
cursor = conn.cursor()

# 2. Read your SQL file
with open('StreamPulse.sql', 'r') as f:
    sql_script = f.read()

# 3. Clean and Execute (SQLite doesn't use "use database")
sql_script = sql_script.replace('show databases;', '').replace('use  Streampulse;', '')
cursor.executescript(sql_script)

conn.commit()
conn.close()