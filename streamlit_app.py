import streamlit as st
import pandas as pd
import sqlite3
import os
import re

st.set_page_config(page_title="StreamPulse Analytics", layout="wide")

# Custom CSS to make it look less "bland"
st.markdown("""
    <style>
    .main { background-color: #f5f7f9; }
    .stMetric { background-color: #ffffff; padding: 15px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    </style>
    """, unsafe_all_white_space=True)

st.title("📊 StreamPulse Analytics")

DB_FILE = 'streampulse.db'
SQL_FILE = 'StreamPulse.sql'

def init_db():
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)
    
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    
    if os.path.exists(SQL_FILE):
        with open(SQL_FILE, 'r') as f:
            # Filter out MySQL-specific lines that break SQLite
            lines = f.readlines()
            clean_lines = []
            for line in lines:
                # Remove SET, USE, SHOW, and comments starting with /*!
                if not any(line.strip().upper().startswith(x) for x in ["SET ", "USE ", "SHOW ", "/*"]):
                    clean_lines.append(line)
            
            sql_script = "".join(clean_lines)
            # Standardize Integer Primary Key for SQLite
            sql_script = re.sub(r'INT PRIMARY KEY', 'INTEGER PRIMARY KEY', sql_script, flags=re.IGNORECASE)

        try:
            cursor.executescript(sql_script)
            conn.commit()
        except Exception as e:
            st.error(f"Initialization Note: {e}")
    conn.close()

if 'db_initialized' not in st.session_state:
    init_db()
    st.session_state['db_initialized'] = True

def run_query(query):
    try:
        with sqlite3.connect(DB_FILE) as conn:
            return pd.read_sql_query(query, conn)
    except:
        return None

# --- RESTORING FUNCTIONS: THE DASHBOARD ---

# 1. Top Level Metrics (KPIs)
col1, col2, col3, col4 = st.columns(4)
total_movies = run_query("SELECT COUNT(*) as count FROM Media_Content")
total_users = run_query("SELECT COUNT(*) as count FROM User_Account")
total_studios = run_query("SELECT COUNT(*) as count FROM Production_House")
active_engine = run_query("SELECT Version FROM Rec_Engine ORDER BY EngineID DESC LIMIT 1")

with col1:
    st.metric("Total Titles", total_movies['count'][0] if total_movies is not None else 0)
with col2:
    st.metric("Global Users", total_users['count'][0] if total_users is not None else 0)
with col3:
    st.metric("Partner Studios", total_studios['count'][0] if total_studios is not None else 0)
with col4:
    st.metric("Engine Version", active_engine['Version'][0] if active_engine is not None else "N/A")

# 2. Main Content Area
tab1, tab2, tab3 = st.tabs(["Media Catalog", "User Insights", "Technical Infrastructure"])

with tab1:
    st.subheader("Master Media Catalog")
    search = st.text_input("Search by Title...")
    query = "SELECT Title, Release_Year, Content_Type FROM Media_Content"
    if search:
        query += f" WHERE Title LIKE '%{search}%'"
    
    df_media = run_query(query)
    if df_media is not None:
        st.dataframe(df_media, use_container_width=True)

with tab2:
    col_a, col_b = st.columns(2)
    with col_a:
        st.write("### Users by City")
        df_users = run_query("SELECT City, COUNT(*) as Count FROM User_Account GROUP BY City")
        if df_users is not None:
            st.bar_chart(df_users.set_index('City'))
    
    with col_b:
        st.write("### Content Distribution")
        df_dist = run_query("SELECT Content_Type, COUNT(*) as Count FROM Media_Content GROUP BY Content_Type")
        if df_dist is not None:
            st.area_chart(df_dist.set_index('Content_Type'))

with tab3:
    st.subheader("System & Server Status")
    # Pulling from your CDN_Server table
    df_cdn = run_query("SELECT Region, IP_Address, Storage_Capacity_TB FROM CDN_Server")
    if df_cdn is not None:
        st.table(df_cdn)
