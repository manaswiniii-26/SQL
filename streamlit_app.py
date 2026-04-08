import streamlit as st
import pandas as pd
import sqlite3
import os

st.set_page_config(page_title="StreamPulse Analytics", layout="wide")
st.title("StreamPulse Analytics Dashboard")

# 1. Database Setup Logic
DB_FILE = 'streampulse.db'
SQL_FILE = 'StreamPulse.sql'

def init_db():
    # Only create the database if it doesn't exist
    if not os.path.exists(DB_FILE):
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        if os.path.exists(SQL_FILE):
            with open(SQL_FILE, 'r') as f:
                sql_script = f.read()
            # Clean MySQL-specific commands that SQLite doesn't understand
            clean_script = sql_script.replace('show databases;', '').replace('use  Streampulse;', '')
            try:
                cursor.executescript(clean_script)
                conn.commit()
            except Exception as e:
                st.error(f"Error initializing database: {e}")
        conn.close()

# Initialize the database
init_db()

# 2. Query Function
def run_query(query):
    try:
        with sqlite3.connect(DB_FILE) as conn:
            return pd.read_sql_query(query, conn)
    except Exception as e:
        st.error(f"Query Error: {e}")
        return pd.DataFrame()

# 3. UI Sections
st.subheader("Master Media Catalog")
media_df = run_query("SELECT Title, Release_Year, Content_Type FROM Media_Content LIMIT 10")

if not media_df.empty:
    st.dataframe(media_df, use_container_width=True)
else:
    st.warning("No data found. Please check if Media_Content table exists in your SQL file.")

# User Distribution
st.subheader("User Distribution by City")
user_stats = run_query("SELECT City, COUNT(*) as Count FROM User_Account GROUP BY City")
if not user_stats.empty:
    st.bar_chart(user_stats.set_index('City'))
