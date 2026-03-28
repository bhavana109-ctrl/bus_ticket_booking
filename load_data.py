#!/usr/bin/env python3
"""
Load SQL data from bus_booking.sql
"""

import mysql.connector
import os

# Database configuration
DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'root'),
    'password': os.environ.get('DB_PASSWORD', 'bhavana@123xxjb'),
    'database': os.environ.get('DB_NAME', 'bus_booking')
}

def load_sql_file():
    """Load and execute the SQL file"""
    
    try:
        # Connect to MySQL
        db = mysql.connector.connect(
            host=DB_CONFIG['host'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password']
        )
        cursor = db.cursor()
        
        # Read SQL file
        with open('bus_booking.sql', 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Split and execute statements
        statements = sql_content.split(';')
        
        for statement in statements:
            statement = statement.strip()
            if statement:
                try:
                    cursor.execute(statement)
                    db.commit()
                except Exception as e:
                    print(f"Error executing statement: {e}")
                    print(f"Statement: {statement[:100]}...")
        
        print("Database loaded successfully!")
        
        # Verify buses were loaded
        cursor.execute("SELECT COUNT(*) as bus_count FROM buses")
        result = cursor.fetchone()
        print(f"Total buses in database: {result[0]}")
        
        cursor.close()
        db.close()
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    load_sql_file()
