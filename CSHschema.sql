DROP TABLE IF EXISTS Administrator;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS AdmissionType;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Admission;

CREATE TABLE Administrator (
    UserName VARCHAR(10) PRIMARY KEY,
    Password VARCHAR(20) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(20) NOT NULL
);

INSERT INTO Administrator VALUES 
('jdoe', 'Pass1234', 'John', 'Doe', 'jdoe@csh.com'),
('jsmith', 'Pass5678', 'Jane', 'Smith', 'jsmith@csh.com'),
('ajohnson', 'Passabcd', 'Alice', 'Johnson', 'ajohnson@csh.com'),
('bbrown', 'Passwxyz', 'Bob', 'Brown', 'bbrown@csh.com'),
('cdavis', 'Pass9876', 'Charlie', 'Davis', 'cdavis@csh.com'),
('ksmith', 'Pass5566', 'Karen', 'Smith', 'ksmith@csh.com');

CREATE TABLE Patient (
    PatientID VARCHAR(10) PRIMARY KEY,
    Password VARCHAR(20) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Mobile VARCHAR(20) NOT NULL
);

INSERT INTO Patient VALUES 
('dwilson', 'Pass5432', 'David', 'Wilson', '4455667788'),
('etylor', 'Passlmno', 'Eva', 'Taylor', '5566778899'),
('faderson', 'Passrstu', 'Frank', 'Anderson', '6677889900'),
('gthomas', 'Pass1357', 'Grace', 'Thomas', '7788990011'),
('smartinez', 'Pass2468', 'Stan', 'Martinez', '8899001122'),
('lroberts', 'Pass1122', 'Laura', 'Roberts', '9900112233');


CREATE TABLE AdmissionType (
    AdmissionTypeID SERIAL PRIMARY KEY,
    AdmissionTypeName VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO AdmissionType VALUES (1, 'Emergency');
INSERT INTO AdmissionType VALUES (2, 'Transfer');
INSERT INTO AdmissionType VALUES (3, 'Inpatient');
INSERT INTO AdmissionType VALUES (4, 'Outpatient');

CREATE TABLE Department (
    DeptId SERIAL PRIMARY Key,
    DeptName VARCHAR(20) UNIQUE not NULL
);

INSERT INTO Department VALUES (1, 'General');
INSERT INTO Department VALUES (2, 'Emergency');
INSERT INTO Department VALUES (3, 'Surgery');
INSERT INTO Department VALUES (4, 'Obstetrics');
INSERT INTO Department VALUES (5, 'Rehabilitation');
INSERT INTO Department VALUES (6, 'Paediatrics');

CREATE table Admission (
    AdmissionID SERIAL PRIMARY KEY,
    AdmissionType INTEGER NOT NULL,
    Department INTEGER NOT NULL,
	Patient VARCHAR(10) NOT NULL,
	Administrator VARCHAR(10) NOT NULL,
    Fee Decimal(7,2),
    DischargeDate Date,
    Condition VARCHAR(500),
	FOREIGN KEY(AdmissionType) REFERENCES AdmissionType,
	FOREIGN KEY(Department) REFERENCES Department,
	FOREIGN KEY(Patient) REFERENCES Patient,
	FOREIGN KEY(Administrator) REFERENCES Administrator
);

INSERT INTO Admission (AdmissionType, Department, Fee, Patient, Administrator, DischargeDate, Condition) VALUES
    (4, 1, 666.00, 'lroberts', 'jdoe', '28/02/2024', 'a red patch on my skin that looks irritated. It started small but has been spreading and feels warm to the touch'),
	(2, 1, 100.00, 'gthomas', 'jdoe', '11/09/2021', NULL),
	(1, 2, NULL, 'lroberts','jsmith', '02/09/2019', 'Admitted to the emergency department after suffering head trauma from a fall, requiring a CT scan and observation for potential concussion.'),
	(2, 3, 7688.00, 'dwilson','ajohnson', '01/12/2022', NULL),
	(2, 6, 1600.00, 'faderson', 'ajohnson', '03/09/2014', 'Child admitted to the hospital with a severe asthma attack, requiring oxygen therapy and nebulizer treatment.'),
	(4, 1, 90.00, 'gthomas', 'ksmith', '04/07/2021', 'Routine follow-up consultation to review progress after recent knee surgery, with positive recovery observed.'),
	(1, 2, 1450.00, 'smartinez', 'jsmith', NULL, 'Admitted to the emergency department with severe food poisoning, requiring IV fluids and anti-nausea medication for recovery.'),
	(4, 5, 180.95, 'dwilson', 'cdavis', '06/11/2021', 'Attended a physiotherapy session as part of an ongoing rehabilitation program following shoulder surgery.'),
	(3, 1, 2000.00, 'etylor', 'ajohnson', '10/09/2021', NULL),
	(2, 4, 8290.00, 'gthomas', 'jsmith', '01/09/2024', 'Postpartum care following a natural childbirth, including monitoring of both the mother and the newborn for potential complications.'),
	(2, 6, 1800.00, 'faderson', 'bbrown',  NULL, 'Child admitted to the paediatrics department for severe pneumonia, requiring intravenous antibiotics and respiratory therapy.'),
	(4, 1, 75.00, 'gthomas', 'bbrown', '19/11/2023', 'Routine general practitioner consultation for a follow-up after a recent bout of seasonal allergies.'),
	(3, 3, 7000.50, 'smartinez', 'jdoe', '15/10/2024', NULL),
	(1, 2, NULL, 'etylor', 'jdoe', NULL, 'I am having intense, crushing pain in my chest that feels like an elephant is sitting on it. It is spreading to my left arm and neck.');



-- Stored Procedures

-- checkLogin
DROP FUNCTION IF EXISTS sp_check_administrator_login(admin_username VARCHAR, admin_password VARCHAR);
CREATE OR REPLACE FUNCTION sp_check_administrator_login(admin_username VARCHAR, admin_password VARCHAR)
RETURNS TABLE (
    UserName VARCHAR,
    Password VARCHAR,
    FirstName VARCHAR,
    LastName VARCHAR,
    Email VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.UserName,
        a.Password,
        a.FirstName, 
        a.LastName, 
        a.Email
    FROM 
        Administrator a
    WHERE 
        a.UserName = admin_username 
        AND a.Password = admin_password;
END;
$$ LANGUAGE plpgsql;

-- findAdmissionsByAdmin
DROP FUNCTION IF EXISTS sp_get_admissions_by_administrator(admin_login VARCHAR);
CREATE OR REPLACE FUNCTION sp_get_admissions_by_administrator(admin_login VARCHAR)
RETURNS TABLE (
    admissionid INT, 
    admissiontypename VARCHAR, 
    deptname VARCHAR, 
    dischargedate DATE, 
    fee NUMERIC, 
    full_name TEXT, 
    admissioncondition VARCHAR
) 
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        admission.admissionid AS admissionid, 
        admissiontype.admissiontypename AS admissiontypename, 
        department.deptname AS deptname, 
        admission.dischargedate AS dischargedate, 
        admission.fee AS fee, 
        CONCAT(patient.firstname, ' ', patient.lastname) AS full_name, 
        admission.condition AS admissioncondition 
    FROM 
        admission 
    JOIN 
        admissiontype ON admissiontype.admissiontypeid = admission.admissiontype 
    JOIN 
        department ON department.deptid = admission.department 
    JOIN 
        patient ON patient.patientid = admission.patient 
    WHERE 
        admission.administrator = admin_login 
    ORDER BY 
        dischargedate DESC NULLS LAST, 
        full_name ASC, 
        admissiontypename DESC;
END;
$$ LANGUAGE plpgsql;

-- findAdmissionsByCriteria
DROP FUNCTION IF EXISTS sp_search_admissions(search_string VARCHAR);
CREATE OR REPLACE FUNCTION sp_search_admissions(search_string VARCHAR)
RETURNS TABLE (
    admissionid INT, 
    admissiontypename VARCHAR, 
    deptname VARCHAR, 
    dischargedate DATE, 
    fee NUMERIC, 
    full_name TEXT, 
    admissioncondition VARCHAR
) 
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        admission.admissionid AS admissionid, 
        admissiontype.admissiontypename AS admissiontypename, 
        department.deptname AS deptname, 
        admission.dischargedate AS dischargedate, 
        admission.fee AS fee, 
        CONCAT(patient.firstname, ' ', patient.lastname) AS full_name, 
        admission.condition AS admissioncondition 
    FROM 
        admission 
    JOIN 
        admissiontype ON admissiontype.admissiontypeid = admission.admissiontype 
    JOIN 
        department ON department.deptid = admission.department 
    JOIN 
        patient ON patient.patientid = admission.patient 
    WHERE 
        (admission.dischargedate IS NULL OR admission.dischargedate > CURRENT_DATE - INTERVAL '2 years') 
        AND (
            admissiontype.admissiontypename ILIKE '%' || search_string || '%' OR 
            department.deptname ILIKE '%' || search_string || '%' OR 
            CONCAT(patient.firstname, ' ', patient.lastname) ILIKE '%' || search_string || '%' OR 
            admission.condition ILIKE '%' || search_string || '%'
        )
    ORDER BY 
        dischargedate ASC NULLS FIRST, 
        full_name ASC;
END;
$$ LANGUAGE plpgsql;

-- addAdmission

DROP PROCEDURE IF EXISTS sp_insert_admission(
    p_admissiontype VARCHAR,
    p_department VARCHAR,
    p_patient VARCHAR,
    p_administrator VARCHAR,
    p_condition VARCHAR
);
CREATE OR REPLACE PROCEDURE sp_insert_admission(
    p_admissiontype VARCHAR,
    p_department VARCHAR,
    p_patient VARCHAR,
    p_administrator VARCHAR,
    p_condition VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO admission (admissiontype, department, patient, administrator, condition)
    VALUES (
        (SELECT admissiontypeid FROM admissiontype WHERE admissiontypename ILIKE p_admissiontype LIMIT 1),
        (SELECT deptid FROM department WHERE deptname ILIKE p_department LIMIT 1),
        p_patient,
        p_administrator,
        p_condition
    );
END;
$$;

-- updateAdmission
DROP PROCEDURE IF EXISTS sp_update_admission(
    p_admissionid INT,
    p_admissiontype VARCHAR,
    p_department VARCHAR,
    p_dischargedate DATE,
    p_fee Decimal,
    p_patient VARCHAR,
    p_condition VARCHAR
);
CREATE OR REPLACE PROCEDURE sp_update_admission(
    p_admissionid INT,
    p_admissiontype VARCHAR,
    p_department VARCHAR,
    p_dischargedate DATE,
    p_fee Decimal,
    p_patient VARCHAR,
    p_condition VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE admission
    SET admissiontype = (SELECT admissiontypeid FROM admissiontype WHERE admissiontypename ILIKE p_admissiontype LIMIT 1),
        department = (SELECT deptid FROM department WHERE deptname ILIKE p_department LIMIT 1),
        dischargedate = p_dischargedate,
        fee = p_fee,
        patient = (SELECT patientid FROM patient WHERE CONCAT(firstname, ' ', lastname) ILIKE p_patient LIMIT 1),
        condition = p_condition
    WHERE admissionid = p_admissionid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Admission with id % does not exist or matching criteria not found', p_admissionid;
    END IF;
END;
$$;

