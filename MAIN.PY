import mysql.connector
from mysql.connector import Error

def get_connection():
    db_password = "gojosotaru123"
    
    try:
        # First connect without specifying database to create it if missing
        connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password=db_password
        )
        cursor = connection.cursor()
        cursor.execute("CREATE DATABASE IF NOT EXISTS SportsClubDB;")
        connection.database = "SportsClubDB"
        
        print("\n Successfully connected to SportsClubDB!\n")
        return connection
    except Error as e:
        print(f"\n Error connecting to database: {e}")
        return None
def show_menu():
    print("-" * 40)
    print("      SPORTS CLUB MANAGEMENT MENU")
    print("-" * 40)
    print("1. View All Members")
    print("2. Add New Member")
    print("3. View Teams and Coaches")
    print("4. View Tournament Fixtures")
    print("5. View Equipment Inventory")
    print("6. Run Custom SQL Query")
    print("0. Exit")
    print("-" * 40)

def view_members(cursor):
    query = "SELECT Member_ID, Name, Gender, Phone, Email, Status FROM Member;"
    cursor.execute(query)
    records = cursor.fetchall()
    
    print("\n--- MEMBER LIST ---")
    print(f"{'ID':<5} {'Name':<20} {'Gender':<10} {'Phone':<15} {'Status':<10}")
    print("-" * 65)
    for row in records:
        print(f"{row[0]:<5} {row[1]:<20} {row[2]:<10} {row[3]:<15} {row[5]:<10}")
    print()

def add_member(connection, cursor):
    print("\n--- ADD NEW MEMBER ---")
    name = input("Enter Full Name: ").strip()
    dob = input("Enter DOB (YYYY-MM-DD): ").strip()
    gender = input("Enter Gender (Male/Female/Other): ").strip()
    phone = input("Enter Phone: ").strip()
    email = input("Enter Email: ").strip()
    join_date = input("Enter Join Date (YYYY-MM-DD): ").strip()
    
    query = """
    INSERT INTO Member (Name, DOB, Gender, Phone, Email, Join_Date, Status)
    VALUES (%s, %s, %s, %s, %s, %s, 'Active');
    """
    
    try:
        cursor.execute(query, (name, dob, gender, phone, email, join_date))
        connection.commit()
        print(f"\n Member '{name}' added successfully!\n")
    except Error as e:
        print(f"\n Failed to add member: {e}\n")

def view_teams(cursor):
    query = """
    SELECT T.Team_ID, T.Team_Name, S.Sport_Name, C.Coach_Name
    FROM Team T
    JOIN Sport S ON T.Sport_ID = S.Sport_ID
    LEFT JOIN Coach C ON T.Coach_ID = C.Coach_ID;
    """
    cursor.execute(query)
    records = cursor.fetchall()
    
    print("\n--- TEAMS & COACHES ---")
    print(f"{'ID':<5} {'Team Name':<20} {'Sport':<15} {'Coach':<20}")
    print("-" * 65)
    for row in records:
        coach = row[3] if row[3] else "Unassigned"
        print(f"{row[0]:<5} {row[1]:<20} {row[2]:<15} {coach:<20}")
    print()

def view_fixtures(cursor):
    query = """
    SELECT F.Fixture_ID, Tn.Name AS Tournament, T1.Team_Name AS Team1, T2.Team_Name AS Team2, F.Date, F.Start_Time
    FROM Fixture F
    JOIN Tournament Tn ON F.Tournament_ID = Tn.Tournament_ID
    JOIN Team T1 ON F.Team1_ID = T1.Team_ID
    JOIN Team T2 ON F.Team2_ID = T2.Team_ID;
    """
    cursor.execute(query)
    records = cursor.fetchall()
    
    print("\n--- TOURNAMENT FIXTURES ---")
    print(f"{'ID':<5} {'Tournament':<22} {'Team 1':<15} {'Team 2':<15} {'Date':<12}")
    print("-" * 75)
    for row in records:
        print(f"{row[0]:<5} {row[1]:<22} {row[2]:<15} {row[3]:<15} {str(row[4]):<12}")
    print()

def view_equipment(cursor):
    query = "SELECT Equipment_ID, Name, Category, Quantity, Available_Quantity FROM Equipment;"
    cursor.execute(query)
    records = cursor.fetchall()
    
    print("\n--- EQUIPMENT INVENTORY ---")
    print(f"{'ID':<5} {'Name':<20} {'Category':<15} {'Total':<10} {'Available':<10}")
    print("-" * 65)
    for row in records:
        print(f"{row[0]:<5} {row[1]:<20} {row[2]:<15} {row[3]:<10} {row[4]:<10}")
    print()

def run_custom_query(cursor):
    print("\n--- RUN CUSTOM SQL SELECT QUERY ---")
    sql = input("Enter SQL Query: ").strip()
    try:
        cursor.execute(sql)
        results = cursor.fetchall()
        print("\nResults:")
        for row in results:
            print(row)
        print()
    except Error as e:
        print(f"\n Query Error: {e}\n")

def main():
    connection = get_connection()
    if not connection:
        return
    
    cursor = connection.cursor()
    
    while True:
        show_menu()
        choice = input("Enter choice (0-6): ").strip()
        
        if choice == "1":
            view_members(cursor)
        elif choice == "2":
            add_member(connection, cursor)
        elif choice == "3":
            view_teams(cursor)
        elif choice == "4":
            view_fixtures(cursor)
        elif choice == "5":
            view_equipment(cursor)
        elif choice == "6":
            run_custom_query(cursor)
        elif choice == "0":
            print("\nClosing connection. Goodbye!")
            break
        else:
            print("\nInvalid choice! Please select 0-6.\n")
            
    cursor.close()
    connection.close()

if __name__ == "__main__":
    main()