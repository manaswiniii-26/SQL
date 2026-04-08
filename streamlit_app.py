import streamlit as st
import pandas as pd
import sqlite3

st.set_page_config(page_title="StreamPulse Analytics", layout="wide")
st.title("StreamPulse Analytics Dashboard")

# Function to connect and run queries
def run_query(query):
    conn = sqlite3.connect('streampulse.db')
    return pd.read_sql_query(query, conn)

# Display content from your SQL tables
st.subheader("Master Media Catalog")
# Pulling Title and Release Year from your Media_Content table
media_df = run_query("SELECT Title, Release_Year, Content_Type FROM Media_Content LIMIT 10")
st.dataframe(media_df, use_container_width=True)

# Visualize user data from your SQL table
st.subheader("User Distribution by City")
# Using the City column from your User_Account table
user_stats = run_query("SELECT City, COUNT(*) as Count FROM User_Account GROUP BY City")
st.bar_chart(user_stats.set_index('City'))

# Check Recommendation Engine status
st.sidebar.header("System Status")
# Pulling Version information from your Rec_Engine table
engine_info = run_query("SELECT Version, Model_Type FROM Rec_Engine WHERE EngineID = 50")
st.sidebar.write(f"Active Engine: {engine_info['Model_Type'][0]} ({engine_info['Version'][0]})")