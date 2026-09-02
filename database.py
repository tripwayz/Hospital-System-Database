#!/usr/bin/env python3
import psycopg2

#####################################################
##  Database Connection
#####################################################

'''
Connect to the database using the connection string
'''
def openConnection():
    # connection parameters - ENTER YOUR LOGIN AND PASSWORD HERE
    userid = "zcw"
    database = "hospital"
    passwd = "zcw1415926"
    myHost = "127.0.0.1"


    # Create a connection to the database
    conn = None
    try:
        # Parses the config file and connects using the connect string
        conn = psycopg2.connect(database=database,
                                    user=userid,
                                    password=passwd,
                                    host=myHost)

    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)
    
    # return the connection to use
    return conn

'''
Validate staff based on username and password
'''
def checkLogin(login, password):
    login_data = []

    try:
        conn = openConnection()
        cur = conn.cursor()
        cur.callproc('sp_check_administrator_login', (login, password))
        conn.commit()
        login_data = cur.fetchall()
    except psycopg2.Error as e:
        print(f"PSQL error:{e}")
        return None
    finally:
        if conn:
            cur.close()
            conn.close()
    
    return [login_data[0][0], 
            login_data[0][2], 
            login_data[0][3], 
            login_data[0][4]] if login_data else None


'''
List all the associated admissions records in the database by staff
'''
def findAdmissionsByAdmin(login):
    admission_records = []
    try:
        conn = openConnection()
        cur = conn.cursor()
        cur.callproc('sp_get_admissions_by_administrator', (login,))
        conn.commit()
        admission_records = cur.fetchall()
    except psycopg2.Error as e:
        print(f"findAdmissionsByAdmin PSQL error:{e}")
        return None
    finally:
        if conn:
            cur.close()
            conn.close()
    
    admission_records = [{'admission_id': record[0] or '',
                          'admission_type': record[1] or '',
                          'admission_department': record[2] or '',
                          'discharge_date': record[3] or '',
                          'fee': record[4] or '',
                          'patient': record[5] or '',
                          'condition': record[6] or ''}
                          for record in admission_records]

    return admission_records


'''
Find a list of admissions based on the searchString provided as parameter
See assignment description for search specification
'''
def findAdmissionsByCriteria(searchString):
    admission_records = []
    try:
        conn = openConnection()
        cur = conn.cursor()
        cur.callproc('sp_search_admissions', (searchString,))
        conn.commit()
        admission_records = cur.fetchall()
    except psycopg2.Error as e:
        print(f"findAdmissionsByCriteria PSQL error:{e}")
        return None
    finally:
        if conn:
            cur.close()
            conn.close()
    
    admission_records = [{'admission_id': record[0] or '',
                          'admission_type': record[1] or '',
                          'admission_department': record[2] or '',
                          'discharge_date': record[3] or '',
                          'fee': record[4] or '',
                          'patient': record[5] or '',
                          'condition': record[6] or ''}
                          for record in admission_records]

    return admission_records


'''
Add a new addmission 
'''
def addAdmission(type, department, patient, condition, admin):
    try:
        conn = openConnection()
        cur = conn.cursor()
        cur.execute('CALL sp_insert_admission(%s, %s, %s, %s, %s)', (type, department, patient, admin, condition))
        conn.commit()
    except psycopg2.Error as e:
        print(f"addAdmission PSQL error:{e}")
        return False
    finally:
        if conn:
            cur.close()
            conn.close()
        
    return True


'''
Update an existing admission
'''
def updateAdmission(id, type, department, dischargeDate, fee, patient, condition):
    try:
        conn = openConnection()
        cur = conn.cursor()
        cur.execute(
            'CALL sp_update_admission(%s, %s, %s, %s, %s, %s, %s)',
            (id, type, department, dischargeDate, fee, patient, condition)
        )
        conn.commit()
    except psycopg2.Error as e:
        print(f"updateAdmission PSQL error:{e}")
        return False
    finally:
        if conn:
            cur.close()
            conn.close()
        
    return True
