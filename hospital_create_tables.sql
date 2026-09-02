-- DELETE orginal tables
DROP TABLE IF EXISTS discharge;
DROP TABLE IF EXISTS billing;
DROP TABLE IF EXISTS admission;
DROP TABLE IF EXISTS bed;
DROP TABLE IF EXISTS wards;
DROP TABLE IF EXISTS doctor;
DROP TABLE IF EXISTS nurse;
DROP TABLE IF EXISTS other_staff;
DROP TABLE IF EXISTS ref_practionners;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS departments;

-- departments
CREATE TABLE departments (
    department_id VARCHAR PRIMARY KEY,
    department_name VARCHAR(100),
    operating_hours INT,
    department_type VARCHAR(50) NOT NULL,
    CHECK (department_type IN ('general', 'emergency', 'pediatrics', 'surgery'))
);

-- wards
CREATE TABLE wards (
    ward_id VARCHAR PRIMARY KEY,
    beds INT,
    department_id VARCHAR,
    FOREIGN KEY (department_id) 
    REFERENCES departments(department_id)
);

-- bed
CREATE TABLE bed (
    bed_id VARCHAR PRIMARY KEY,
    comfort_level INT,
    bed_length NUMERIC(10, 2) NOT NULL CHECK (bed_length > 0 AND bed_length <= 2.13)
    bed_width NUMERIC(10, 2) NOT NULL CHECK (bed_width > 0 AND bed_length <= 1.27),
    mattress_thickness NUMERIC(10, 2) NOT NULL CHECK (mattress_thickness >= 15.24 AND mattress_thickness <= 17.78),
    bed_cost NUMERIC(10, 2),
    ward_id VARCHAR,
    FOREIGN KEY (ward_id) REFERENCES wards(ward_id)
);

--  bed - Triggers:
-- update_bed_count() : add or minus 1 on wards.beds while insert or delete bed
CREATE OR REPLACE FUNCTION update_bed_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE wards
    SET beds = (
        SELECT COUNT(*)
        FROM bed
        WHERE bed.ward_id = NEW.ward_id
    )
    WHERE wards.ward_id = NEW.ward_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER bed_count_trigger
AFTER INSERT OR UPDATE OR DELETE
on bed
FOR EACH ROW
EXECUTE FUNCTION update_bed_count();

-- staff
CREATE TABLE staff (
    staff_id VARCHAR PRIMARY KEY,
    full_name VARCHAR(100),
    staff_address VARCHAR(100),
    mobile_number VARCHAR,
    salary NUMERIC(10, 2) NOT NULL,
    department_id VARCHAR,
    position VARCHAR(100) CHECK (position in ('Nurse', 'Doctor', 'Other_staff')),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- other_staff
CREATE TABLE other_staff (
    staff_id VARCHAR(11) PRIMARY KEY,
    staff_type VARCHAR(100),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE
);

-- doctor
CREATE TABLE doctor (
    staff_id VARCHAR(11) PRIMARY KEY,
    qualificition INT CHECK (qualificition >= 1 and qualificition <= 5),
    training_date DATE,
    proficiency_level INT CHECK (proficiency_level >= 1 and proficiency_level <= 3),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE
);

-- nurse
CREATE TABLE nurse (
    staff_id VARCHAR(11) PRIMARY KEY,
    wwcc_state BOOL,
    wwcc_start DATE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE
);

-- referring_practitioners
CREATE TABLE ref_practitioners (
    staff_id VARCHAR(11) PRIMARY KEY,
    specialization VARCHAR(100),
    ref_number VARCHAR NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE
);

-- patients
CREATE TABLE patients (
    pid VARCHAR(11) PRIMARY KEY,
    full_name VARCHAR(50),
    mobile INT,
    patients_address VARCHAR(50),
    patients_email VARCHAR(50),
    emergency_contact_name VARCHAR(50),
    emergency_contact_number INT,
    insurance_number VARCHAR(100),
    birth_date DATE
);

-- Admission 
CREATE TABLE admission (
    aid VARCHAR(11) PRIMARY KEY,
    pid VARCHAR(11) NOT NULL,
    ward_id VARCHAR(11) NOT NULL,
    staff_id VARCHAR,
    admission_date DATE DEFAULT CURRENT_TIMESTAMP,
    admission_type VARCHAR(100) CHECK (admission_type IN ('Emergency', 'Planned')),
    FOREIGN KEY (pid) REFERENCES patients(pid) ON DELETE CASCADE,
    FOREIGN KEY (ward_id) REFERENCES wards(ward_id) ON DELETE CASCADE
);

-- discharge
CREATE TABLE discharge (
    discharge_id VARCHAR(11) PRIMARY KEY,
    aid VARCHAR(11) NOT NULL,
    discharge_date DATE NOT NULL,
    FOREIGN KEY (aid) REFERENCES admission(aid)
);

-- billing
CREATE TABLE billing (
    bid VARCHAR(11) PRIMARY KEY,
    discharge_id VARCHAR,
    aid VARCHAR(11),
    pid VARCHAR(11),
    total_cost NUMERIC(10, 2) NOT NULL CHECK (total_cost <= 50000),
    remaining_balance NUMERIC(10, 2) CHECK (remaining_balance > 0),
    covered_by_insurance NUMERIC(10, 2) CHECK (remaining_balance > 0),
    payment_date DATE DEFAULT CURRENT_TIMESTAMP,
    service_provided TEXT,
    FOREIGN KEY (pid) REFERENCES patients(pid) ON DELETE CASCADE,
    FOREIGN KEY (aid) REFERENCES admission(aid) ON DELETE CASCADE,
    FOREIGN KEY (discharge_id) REFERENCES discharge(discharge_id) ON DELETE CASCADE
);

-- auto_discharge: when patient is discharged, automatically generate a bill with information about the patient.
CREATE OR REPLACE FUNCTION generate_bill()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO billing(
        discharge_id, service_provided, total_cost, covered_by_insurance, remaining_balance, payment_date
        )
    VALUES (NEW.discharge_id, 'Service detail', 1000.00, 800,00, 200.00, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_discharge
AFTER INSERT ON discharge
FOR EACH ROW
EXECUTE FUNCTION generate_bill();

-- credit_card
CREATE TABLE credit_card (
    credit_card_number VARCHAR(16),
    cardholder_name VARCHAR(100),
    enquery_date DATE,
    card_number INT,
    CVV VARCHAR(3) CHECK (LENGTH(CVV) = 3),
    bid VARCHAR(11),
    FOREIGN KEY (bid) REFERENCES billing(bid) ON DELETE CASCADE
)









