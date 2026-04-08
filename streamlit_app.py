import streamlit as st
import pandas as pd
import sqlite3
import os
import re

st.set_page_config(page_title="StreamPulse Analytics", layout="wide")
st.title("StreamPulse Analytics Dashboard")

DB_FILE = 'streampulse.db'
SQL_FILE = 'StreamPulse.sql'

def init_db():
    # If the database already exists and is empty/broken, we recreate it
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)
        
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    
    if os.path.exists(SQL_FILE):
        with open(SQL_FILE, 'r') as f:
            sql_script = f.read()
        
        # 1. Remove MySQL-specific headers
        sql_script = sql_script.replace('show databases;', '')
        sql_script = sql_script.replace('use  Streampulse;', '')
        
        # 2. Convert common MySQL syntax to SQLite compatible syntax
        # SQLite prefers AUTOINCREMENT or just PRIMARY KEY for INT
        sql_script = re.sub(r'INT PRIMARY KEY', 'INTEGER PRIMARY KEY', sql_script, flags=re.IGNORECASE)
        # Remove any remaining SELECT statements at the end of your file that aren't inserts
        sql_script = re.sub(r'SELECT .*?;', '', sql_script, flags=re.DOTALL | re.IGNORECASE)

        try:
            # Execute the entire script to build User_Account, Media_Content, etc.
            cursor.executescript(sql_script)
            conn.commit()
            st.success("Database initialized successfully from StreamPulse.sql!")
        except Exception as e:
            st.error(f"Error during initialization: {e}")
    else:
        st.error("SQL file not found in repository.")
    conn.close()

# Force initialization on the first run
if 'db_initialized' not in st.session_state:
    init_db()
    st.session_state['db_initialized'] = True

def run_query(query):
    try:
        with sqlite3.connect(DB_FILE) as conn:
            return pd.read_sql_query(query, conn)
    except Exception as e:
        return None

# --- UI SECTIONS ---

# Section 1: Media Catalog
st.subheader("Master Media Catalog")
# Queries Media_Content table defined in your SQL
media_df = run_query("SELECT Title, Release_Year, Content_Type FROM Media_Content LIMIT 10")

if media_df is not None and not media_df.empty:
    st.dataframe(media_df, use_container_width=True)
else:
    st.warning("Media_Content table is currently empty or not found.")

# Section 2: User Analytics
st.subheader("User Distribution by City")
# Queries User_Account table defined in your SQL
user_stats = run_query("SELECT City, COUNT(*) as Count FROM User_Account GROUP BY City")

if user_stats is not None and not user_stats.empty:
    st.bar_chart(user_stats.set_index('City'))
