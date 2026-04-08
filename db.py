import mysql.connector
import streamlit as st
import pandas as pd

@st.cache_resource
def get_connection():
    return mysql.connector.connect(
        host=st.secrets["mysql"]["host"],
        port=st.secrets["mysql"]["port"],
        database=st.secrets["mysql"]["database"],
        user=st.secrets["mysql"]["user"],
        password=st.secrets["mysql"]["password"]
    )

def run_query(query, params=None):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(query, params or ())
    results = cursor.fetchall()
    cursor.close()
    return pd.DataFrame(results)
