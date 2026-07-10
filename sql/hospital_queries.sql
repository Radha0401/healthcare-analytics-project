-- ============================================================
-- Hospital Database Management System
-- Database: PostgreSQL
-- Normalized schema: patients, doctors, appointments, treatments,
--                     billing, insurance
-- ============================================================

-- ============================================================
-- SECTION 0: Schema Design (Tables, Keys, Indexes)
-- ============================================================

DROP TABLE IF EXISTS billing CASCADE;
DROP TABLE IF EXISTS treatments CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS insurance CASCADE;
DROP TABLE IF EXISTS patients CASCADE;
DROP TABLE IF EXISTS doctors CASCADE;

CREATE TABLE patients (
    patient_id         VARCHAR(10) PRIMARY KEY,
    first_name         VARCHAR(50) NOT NULL,
    last_name          VARCHAR(50) NOT NULL,
    gender              VARCHAR(10),
    date_of_birth       DATE,
    contact_number      VARCHAR(20),
    address             TEXT,
    registration_date   DATE,
    email               VARCHAR(100)
);

CREATE TABLE doctors (
    doctor_id           VARCHAR(10) PRIMARY KEY,
    first_name          VARCHAR(50) NOT NULL,
    last_name           VARCHAR(50) NOT NULL,
    specialization       VARCHAR(50),
    department           VARCHAR(50),
    years_experience     INT,
    contact_number        VARCHAR(20),
    email                VARCHAR(100)
);

CREATE TABLE insurance (
    insurance_id        VARCHAR(10) PRIMARY KEY,
    patient_id           VARCHAR(10) REFERENCES patients(patient_id),
    insurance_provider    VARCHAR(100),
    insurance_number       VARCHAR(50),
    policy_start_date     DATE
);

CREATE TABLE appointments (
    appointment_id        VARCHAR(10) PRIMARY KEY,
    patient_id             VARCHAR(10) REFERENCES patients(patient_id),
    doctor_id                VARCHAR(10) REFERENCES doctors(doctor_id),
    appointment_date          DATE,
    appointment_time          TIME,
    reason_for_visit          VARCHAR(255),
    status                    VARCHAR(30)
);

CREATE TABLE treatments (
    treatment_id          VARCHAR(10) PRIMARY KEY,
    appointment_id          VARCHAR(10) REFERENCES appointments(appointment_id),
    treatment_type            VARCHAR(100),
    description                TEXT,
    cost                        DECIMAL(10,2),
    treatment_date              DATE
);

CREATE TABLE billing (
    bill_id                VARCHAR(10) PRIMARY KEY,
    patient_id               VARCHAR(10) REFERENCES patients(patient_id),
    treatment_id                VARCHAR(10) REFERENCES treatments(treatment_id),
    bill_date                     DATE,
    amount                          DECIMAL(10,2),
    payment_method                   VARCHAR(50),
    payment_status                    VARCHAR(30)
);

-- Indexes for common lookups / joins
CREATE INDEX idx_appointments_patient ON appointments (patient_id);
CREATE INDEX idx_appointments_doctor  ON appointments (doctor_id);
CREATE INDEX idx_treatments_appt      ON treatments (appointment_id);
CREATE INDEX idx_billing_patient      ON billing (patient_id);
CREATE INDEX idx_billing_treatment    ON billing (treatment_id);
CREATE INDEX idx_insurance_patient    ON insurance (patient_id);


-- ============================================================
-- SECTION 1: Data Preview & Basic Counts
-- ============================================================

SELECT COUNT(*) AS total_patients FROM patients;
SELECT COUNT(*) AS total_doctors FROM doctors;
SELECT COUNT(*) AS total_appointments FROM appointments;

SELECT * FROM patients LIMIT 10;


-- ============================================================
-- SECTION 2: Patient Demographics
-- ============================================================

-- Patients by gender
SELECT gender, COUNT(*) AS total_patients
FROM patients
GROUP BY gender;

-- Age group breakdown (age derived from date_of_birth)
SELECT
    CASE
        WHEN AGE(CURRENT_DATE, date_of_birth) < INTERVAL '18 years' THEN 'Child'
        WHEN AGE(CURRENT_DATE, date_of_birth) < INTERVAL '41 years' THEN 'Young Adult'
        WHEN AGE(CURRENT_DATE, date_of_birth) < INTERVAL '61 years' THEN 'Middle Age'
        ELSE 'Senior'
    END AS age_group,
    COUNT(*) AS total_patients
FROM patients
GROUP BY age_group
ORDER BY total_patients DESC;


-- ============================================================
-- SECTION 3: Appointment Analysis (JOINS)
-- ============================================================

-- Appointment status distribution
SELECT status, COUNT(*) AS total
FROM appointments
GROUP BY status;

-- No-show rate
SELECT ROUND(
           COUNT(*) FILTER (WHERE status = 'No-show') * 100.0 / COUNT(*), 2
       ) AS no_show_percentage
FROM appointments;

-- Appointments with patient + doctor names (INNER JOIN)
SELECT
    a.appointment_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    a.appointment_date,
    a.status
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_date;

-- Reason for visit distribution
SELECT reason_for_visit, COUNT(*) AS total
FROM appointments
GROUP BY reason_for_visit
ORDER BY total DESC;


-- ============================================================
-- SECTION 4: Doctor Workload Analysis
-- ============================================================

-- Appointments handled per doctor
SELECT
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id) AS total_appointments
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, doctor_name, d.specialization
ORDER BY total_appointments DESC;

-- No-show rate per doctor
SELECT
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    COUNT(*) FILTER (WHERE a.status = 'No-show') AS no_shows,
    COUNT(*) AS total_appointments,
    ROUND(
        COUNT(*) FILTER (WHERE a.status = 'No-show') * 100.0 / COUNT(*), 2
    ) AS no_show_rate_pct
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, doctor_name
ORDER BY no_show_rate_pct DESC;

-- Revenue generated per doctor (join across appointments -> treatments -> billing)
SELECT
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    ROUND(SUM(b.amount), 2) AS revenue_generated
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
JOIN billing b ON t.treatment_id = b.treatment_id
GROUP BY d.doctor_id, doctor_name, d.specialization
ORDER BY revenue_generated DESC;

-- Doctor workload ranking within each department (window function)
WITH doctor_load AS (
    SELECT
        d.department,
        d.doctor_id,
        d.first_name || ' ' || d.last_name AS doctor_name,
        COUNT(a.appointment_id) AS total_appointments
    FROM doctors d
    LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
    GROUP BY d.department, d.doctor_id, doctor_name
)
SELECT *,
       RANK() OVER (PARTITION BY department ORDER BY total_appointments DESC) AS dept_rank
FROM doctor_load;


-- ============================================================
-- SECTION 5: Treatment Analysis
-- ============================================================

-- Treatment frequency
SELECT treatment_type, COUNT(*) AS frequency
FROM treatments
GROUP BY treatment_type
ORDER BY frequency DESC;

-- Average treatment cost by type
SELECT treatment_type, ROUND(AVG(cost), 2) AS avg_cost
FROM treatments
GROUP BY treatment_type
ORDER BY avg_cost DESC;

-- Cost category classification (CASE WHEN)
SELECT treatment_id, treatment_type, cost,
       CASE
           WHEN cost > 4000 THEN 'High Cost'
           WHEN cost > 2000 THEN 'Medium Cost'
           ELSE 'Low Cost'
       END AS cost_category
FROM treatments;


-- ============================================================
-- SECTION 6: Revenue & Billing Analysis
-- ============================================================

-- Total revenue
SELECT SUM(amount) AS total_revenue FROM billing;

-- Payment status distribution
SELECT payment_status, COUNT(*) AS total_bills
FROM billing
GROUP BY payment_status;

-- Revenue by payment method
SELECT payment_method, ROUND(SUM(amount), 2) AS revenue
FROM billing
GROUP BY payment_method
ORDER BY revenue DESC;

-- Revenue by treatment type (JOIN billing -> treatments)
SELECT
    t.treatment_type,
    ROUND(SUM(b.amount), 2) AS revenue
FROM billing b
JOIN treatments t ON b.treatment_id = t.treatment_id
GROUP BY t.treatment_type
ORDER BY revenue DESC;

-- Revenue above overall average (subquery)
SELECT *
FROM billing
WHERE amount > (SELECT AVG(amount) FROM billing);

-- Correlated subquery: bills above the average for their own payment method
SELECT *
FROM billing b1
WHERE amount > (
    SELECT AVG(amount)
    FROM billing b2
    WHERE b1.payment_method = b2.payment_method
);

-- Executive summary query
SELECT
    (SELECT COUNT(*) FROM patients)     AS total_patients,
    (SELECT COUNT(*) FROM doctors)      AS total_doctors,
    (SELECT COUNT(*) FROM appointments) AS total_appointments,
    (SELECT SUM(amount) FROM billing)   AS total_revenue;


-- ============================================================
-- SECTION 7: Window Functions
-- ============================================================

-- ROW_NUMBER(): rank individual bills by amount
SELECT bill_id, amount,
       ROW_NUMBER() OVER (ORDER BY amount DESC) AS row_num
FROM billing;

-- RANK() / DENSE_RANK(): treatments ranked by total revenue
SELECT
    t.treatment_type,
    SUM(b.amount) AS revenue,
    RANK() OVER (ORDER BY SUM(b.amount) DESC) AS revenue_rank,
    DENSE_RANK() OVER (ORDER BY SUM(b.amount) DESC) AS revenue_dense_rank
FROM billing b
JOIN treatments t ON b.treatment_id = t.treatment_id
GROUP BY t.treatment_type;

-- NTILE(4): quartile buckets by bill amount
SELECT bill_id, amount,
       NTILE(4) OVER (ORDER BY amount DESC) AS quartile
FROM billing;

-- LAG() / LEAD(): previous / next bill amount ordered by date
SELECT bill_date, amount,
       LAG(amount) OVER (ORDER BY bill_date)  AS previous_amount,
       LEAD(amount) OVER (ORDER BY bill_date) AS next_amount
FROM billing;

-- Running / cumulative revenue over time
SELECT bill_date, amount,
       SUM(amount) OVER (ORDER BY bill_date) AS cumulative_revenue
FROM billing;

-- Revenue contribution % of each treatment type
SELECT
    t.treatment_type,
    ROUND(SUM(b.amount), 2) AS revenue,
    ROUND(SUM(b.amount) * 100.0 / SUM(SUM(b.amount)) OVER (), 2) AS contribution_percent
FROM billing b
JOIN treatments t ON b.treatment_id = t.treatment_id
GROUP BY t.treatment_type
ORDER BY revenue DESC;


-- ============================================================
-- SECTION 8: CTEs & Multi-Step Analysis
-- ============================================================

-- Basic CTE: revenue by treatment type
WITH treatment_revenue AS (
    SELECT t.treatment_type, SUM(b.amount) AS revenue
    FROM billing b
    JOIN treatments t ON b.treatment_id = t.treatment_id
    GROUP BY t.treatment_type
)
SELECT *, RANK() OVER (ORDER BY revenue DESC) AS treatment_rank
FROM treatment_revenue;

-- CTE + PARTITION BY: highest revenue treatment per doctor specialization
WITH spec_revenue AS (
    SELECT
        d.specialization,
        t.treatment_type,
        SUM(b.amount) AS revenue,
        RANK() OVER (PARTITION BY d.specialization ORDER BY SUM(b.amount) DESC) AS rnk
    FROM doctors d
    JOIN appointments a ON d.doctor_id = a.doctor_id
    JOIN treatments t ON a.appointment_id = t.appointment_id
    JOIN billing b ON t.treatment_id = b.treatment_id
    GROUP BY d.specialization, t.treatment_type
)
SELECT * FROM spec_revenue WHERE rnk = 1;

-- CTE: top 3 highest bills
WITH bill_rank AS (
    SELECT *, DENSE_RANK() OVER (ORDER BY amount DESC) AS rnk
    FROM billing
)
SELECT * FROM bill_rank WHERE rnk <= 3;


-- ============================================================
-- SECTION 9: Insurance Analysis
-- ============================================================

-- Patients by insurance provider
SELECT insurance_provider, COUNT(*) AS total_patients
FROM insurance
GROUP BY insurance_provider
ORDER BY total_patients DESC;

-- Revenue billed for insured patients vs their payment status
SELECT
    i.insurance_provider,
    b.payment_status,
    ROUND(SUM(b.amount), 2) AS total_amount
FROM insurance i
JOIN billing b ON i.patient_id = b.patient_id
GROUP BY i.insurance_provider, b.payment_status
ORDER BY i.insurance_provider;

-- Patients without any recorded insurance (LEFT JOIN + IS NULL)
SELECT p.patient_id, p.first_name, p.last_name
FROM patients p
LEFT JOIN insurance i ON p.patient_id = i.patient_id
WHERE i.insurance_id IS NULL;


-- ============================================================
-- SECTION 10: Views & Indexes
-- ============================================================

CREATE OR REPLACE VIEW vw_revenue_summary AS
SELECT t.treatment_type, SUM(b.amount) AS revenue
FROM billing b
JOIN treatments t ON b.treatment_id = t.treatment_id
GROUP BY t.treatment_type;

SELECT * FROM vw_revenue_summary;

CREATE OR REPLACE VIEW vw_doctor_performance AS
SELECT
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    ROUND(COALESCE(SUM(b.amount), 0), 2) AS total_revenue
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
LEFT JOIN treatments t ON a.appointment_id = t.appointment_id
LEFT JOIN billing b ON t.treatment_id = b.treatment_id
GROUP BY d.doctor_id, doctor_name, d.specialization;

SELECT * FROM vw_doctor_performance ORDER BY total_revenue DESC;


-- ============================================================
-- SECTION 11: Stored Functions, Procedures & Triggers (PL/pgSQL)
-- ============================================================

-- Stored function: total revenue
CREATE OR REPLACE FUNCTION get_total_revenue()
RETURNS NUMERIC AS
$$
BEGIN
    RETURN (SELECT SUM(amount) FROM billing);
END;
$$ LANGUAGE plpgsql;

SELECT get_total_revenue();

-- Stored function: revenue generated by a given doctor
CREATE OR REPLACE FUNCTION get_doctor_revenue(d_id VARCHAR)
RETURNS NUMERIC AS
$$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(b.amount), 0)
        FROM appointments a
        JOIN treatments t ON a.appointment_id = t.appointment_id
        JOIN billing b ON t.treatment_id = b.treatment_id
        WHERE a.doctor_id = d_id
    );
END;
$$ LANGUAGE plpgsql;

SELECT get_doctor_revenue('D001');

-- Stored procedure: print total patient count
CREATE OR REPLACE PROCEDURE patient_count()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Total Patients: %', (SELECT COUNT(*) FROM patients);
END;
$$;

CALL patient_count();

-- Stored procedure: print no-show summary for a given doctor
CREATE OR REPLACE PROCEDURE doctor_no_show_summary(d_id VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    total INT;
    no_shows INT;
BEGIN
    SELECT COUNT(*) INTO total FROM appointments WHERE doctor_id = d_id;
    SELECT COUNT(*) INTO no_shows FROM appointments WHERE doctor_id = d_id AND status = 'No-show';
    RAISE NOTICE 'Doctor %: % of % appointments were no-shows', d_id, no_shows, total;
END;
$$;

CALL doctor_no_show_summary('D001');

-- Trigger: prevent negative bill amounts
CREATE OR REPLACE FUNCTION check_amount()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.amount < 0 THEN
        RAISE EXCEPTION 'Amount cannot be negative';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER amount_validation
BEFORE INSERT ON billing
FOR EACH ROW
EXECUTE FUNCTION check_amount();


-- ============================================================
-- SECTION 12: Combined Summary Queries
-- ============================================================

-- Treatment-level summary: case count, avg bill, total revenue
SELECT
    t.treatment_type,
    COUNT(*) AS total_cases,
    ROUND(AVG(b.amount), 2) AS avg_bill,
    ROUND(SUM(b.amount), 2) AS total_revenue
FROM treatments t
JOIN billing b ON t.treatment_id = b.treatment_id
GROUP BY t.treatment_type
ORDER BY total_revenue DESC;

-- Payment method x payment status breakdown
SELECT payment_method, payment_status, COUNT(*) AS total_transactions
FROM billing
GROUP BY payment_method, payment_status
ORDER BY payment_method;
