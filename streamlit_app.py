import streamlit as st
import pandas as pd
import sqlite3
import os
import re

# 1. Page Config & Custom Styling
st.set_page_config(page_title="StreamPulse Analytics", layout="wide")

st.markdown("""
    <style>
    .main { background-color: #0e1117; color: #fafafa; }
    .stMetric { 
        background-color: #161b22; 
        padding: 20px; 
        border-radius: 10px; 
        border: 1px solid #30363d;
    }
    </style>
    """, unsafe_allow_html=True)

st.title("📊 StreamPulse Analytics Dashboard")

DB_FILE = 'streampulse.db'
SQL_FILE = 'StreamPulse.sql'

# 2. Database Initialization (Cleaning MySQL syntax for SQLite)
def init_db():
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)
    
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    
    if os.path.exists(SQL_FILE):
        with open(SQL_FILE, 'r') as f:
            lines = f.readlines()
            # Filter out lines that crash SQLite (SET, USE, SHOW)
            clean_lines = [l for l in lines if not any(l.strip().upper().startswith(x) for x in ["SET ", "USE ", "SHOW ", "/*"])]
            sql_script = "".join(clean_lines)
            # Fix primary key syntax
            sql_script = re.sub(r'INT PRIMARY KEY', 'INTEGER PRIMARY KEY', sql_script, flags=re.IGNORECASE)

        try:
            cursor.executescript(sql_script)
            conn.commit()
        except Exception as e:
            st.error(f"SQL Load Note: {e}")
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

# 3. Dashboard Layout
# Top Metrics (KPIs)
m1, m2, m3, m4 = st.columns(4)
res_m = run_query("SELECT COUNT(*) as c FROM Media_Content")
res_u = run_query("SELECT COUNT(*) as c FROM User_Account")
res_s = run_query("SELECT COUNT(*) as c FROM CDN_Server")
res_v = run_query("SELECT Version FROM Rec_Engine ORDER BY EngineID DESC LIMIT 1")

m1.metric("Total Titles", res_m['c'][0] if res_m is not None else 0)
m2.metric("Total Users", res_u['c'][0] if res_u is not None else 0)
m3.metric("Active Servers", res_s['c'][0] if res_s is not None else 0)
m4.metric("Engine Version", res_v['Version'][0] if res_v is not None else "v1.0")

st.divider()

# Main Tabs for Navigation
tab1, tab2, tab3 = st.tabs(["🎥 Media Catalog", "👥 User Insights", "🌐 Infrastructure"])

with tab1:
    st.subheader("Content Explorer")
    search_term = st.text_input("Search by Movie/Show Title", "")
    
    query = "SELECT Title, Release_Year, Content_Type FROM Media_Content"
    if search_term:
        query += f" WHERE Title LIKE '%{search_term}%'"
    
    df_media = run_query(query)
    if df_media is not None:
        st.dataframe(df_media, use_container_width=True, hide_index=True)

with tab2:
    col_left, col_right = st.columns(2)
    with col_left:
        st.write("### Users by City")
        df_users = run_query("SELECT City, COUNT(*) as Count FROM User_Account GROUP BY City")
        if df_users is not None:
            st.bar_chart(df_users.set_index('City'))
    
    with col_right:
        st.write("### Platform Distribution")
        df_plat = run_query("SELECT Content_Type, COUNT(*) as Count FROM Media_Content GROUP BY Content_Type")
        if df_plat is not None:
            st.pie_chart(df_plat, values='Count', names='Content_Type')

with tab3:
    st.subheader("CDN Performance & Storage")
    df_cdn = run_query("SELECT Region, IP_Address, Storage_Capacity_TB FROM CDN_Server")
    if df_cdn is not None:
        st.table(df_cdn)
