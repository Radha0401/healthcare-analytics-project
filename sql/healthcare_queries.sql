-- ============================================================
-- Healthcare Analytics Project — SQL Queries
-- Database: PostgreSQL
-- Table: healthcare_master (patients + appointments + treatments + billing)
-- ============================================================

CREATE TABLE healthcare_master (
    patient_id_x VARCHAR(10),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    date_of_birth DATE,
    contact_number VARCHAR(20),
    address TEXT,
    registration_date DATE,
    insurance_provider VARCHAR(100),
    insurance_number VARCHAR(50),
    email VARCHAR(100),

    age INT,
    age_group VARCHAR(20),

    appointment_id VARCHAR(10),
    doctor_id VARCHAR(10),
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit VARCHAR(255),
    status VARCHAR(30),
    day VARCHAR(15),
    month_x VARCHAR(20),
    priority VARCHAR(20),

    treatment_id VARCHAR(10),
    treatment_type VARCHAR(100),
    description TEXT,
    cost DECIMAL(10,2),
    treatment_date DATE,
    cost_category VARCHAR(20),
    month_y VARCHAR(20),

    month VARCHAR(20),

    bill_id VARCHAR(10),
    patient_id_y VARCHAR(10),
    bill_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(30),
    bill_category VARCHAR(20)
);


-- ============================================================
-- SECTION 1: Data Preview & Basic Counts
-- ============================================================

-- Total records in the table
SELECT COUNT(*) AS total_records
FROM healthcare_master;

-- Preview first 10 rows
SELECT *
FROM healthcare_master
LIMIT 10;

-- Total distinct patients
SELECT COUNT(DISTINCT patient_id_x) AS total_patients
FROM healthcare_master;


-- ============================================================
-- SECTION 2: Patient Demographics
-- ============================================================

-- Patients by gender
SELECT gender,
       COUNT(*) AS total_patients
FROM healthcare_master
GROUP BY gender;

-- Patients by age group
SELECT age_group,
       COUNT(*) AS total_patients
FROM healthcare_master
GROUP BY age_group
ORDER BY total_patients DESC;

-- Age categorization (CASE WHEN example)
SELECT patient_id_x,
       age,
       CASE
           WHEN age < 18 THEN 'Child'
           WHEN age BETWEEN 18 AND 40 THEN 'Young'
           WHEN age BETWEEN 41 AND 60 THEN 'Middle Age'
           ELSE 'Senior'
       END AS age_category
FROM healthcare_master;


-- ============================================================
-- SECTION 3: Appointment Analysis
-- ============================================================

-- Appointment status distribution
SELECT status,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY status;

-- Priority level distribution
SELECT priority,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY priority;

-- High priority case count
SELECT COUNT(*) AS high_priority_cases
FROM healthcare_master
WHERE priority = 'High';

-- High priority success rate (status breakdown by priority)
SELECT priority,
       status,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY priority, status
ORDER BY priority;

-- No-Show Rate
SELECT ROUND(
           COUNT(*) FILTER (WHERE status = 'No-show') * 100.0 / COUNT(*),
           2
       ) AS no_show_percentage
FROM healthcare_master;


-- ============================================================
-- SECTION 4: Treatment Analysis
-- ============================================================

-- Treatment frequency
SELECT treatment_type,
       COUNT(*) AS frequency
FROM healthcare_master
GROUP BY treatment_type
ORDER BY frequency DESC;

-- Top 5 most common treatments
SELECT treatment_type,
       COUNT(*) AS frequency
FROM healthcare_master
GROUP BY treatment_type
ORDER BY frequency DESC
LIMIT 5;

-- Average treatment cost
SELECT ROUND(AVG(cost), 2) AS avg_cost
FROM healthcare_master;

-- Cost category distribution
SELECT cost_category,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY cost_category;

-- Revenue category classification (CASE WHEN example)
SELECT treatment_type,
       amount,
       CASE
           WHEN amount > 4000 THEN 'High Revenue'
           WHEN amount > 2000 THEN 'Medium Revenue'
           ELSE 'Low Revenue'
       END AS revenue_category
FROM healthcare_master;


-- ============================================================
-- SECTION 5: Revenue & Billing Analysis
-- ============================================================

-- Total revenue
SELECT SUM(amount) AS total_revenue
FROM healthcare_master;

-- Payment status distribution
SELECT payment_status,
       COUNT(*) AS total_bills
FROM healthcare_master
GROUP BY payment_status;

-- Revenue by payment method
SELECT payment_method,
       ROUND(SUM(amount), 2) AS revenue
FROM healthcare_master
GROUP BY payment_method
ORDER BY revenue DESC;

-- Most valuable payment method (highest avg bill)
SELECT payment_method,
       ROUND(AVG(amount), 2) AS avg_bill
FROM healthcare_master
GROUP BY payment_method
ORDER BY avg_bill DESC;

-- Highest bill per payment method
SELECT payment_method,
       MAX(amount) AS highest_bill
FROM healthcare_master
GROUP BY payment_method;

-- Revenue by treatment type
SELECT treatment_type,
       ROUND(SUM(amount), 2) AS revenue
FROM healthcare_master
GROUP BY treatment_type
ORDER BY revenue DESC;

-- Top revenue-generating treatments (top 5)
SELECT treatment_type,
       ROUND(SUM(amount), 2) AS revenue
FROM healthcare_master
GROUP BY treatment_type
ORDER BY revenue DESC
LIMIT 5;

-- Revenue by age group
SELECT age_group,
       ROUND(SUM(amount), 2) AS revenue
FROM healthcare_master
GROUP BY age_group
ORDER BY revenue DESC;

-- Monthly revenue trend
SELECT month,
       ROUND(SUM(amount), 2) AS revenue
FROM healthcare_master
GROUP BY month
ORDER BY revenue DESC;

-- Top 10 highest bills
SELECT bill_id,
       amount
FROM healthcare_master
ORDER BY amount DESC
LIMIT 10;

-- Revenue above the overall average (subquery)
SELECT *
FROM healthcare_master
WHERE amount > (
    SELECT AVG(amount)
    FROM healthcare_master
);

-- Revenue difference from overall average, by treatment type
SELECT treatment_type,
       ROUND(AVG(amount), 2) AS avg_revenue,
       ROUND(
           AVG(amount) - (SELECT AVG(amount) FROM healthcare_master),
           2
       ) AS difference_from_avg
FROM healthcare_master
GROUP BY treatment_type;

-- Correlated subquery: bills above the average for their own payment method
SELECT *
FROM healthcare_master h1
WHERE amount > (
    SELECT AVG(amount)
    FROM healthcare_master h2
    WHERE h1.payment_method = h2.payment_method
);

-- High-risk revenue loss (revenue by payment status — flags pending/unpaid amounts)
SELECT payment_status,
       SUM(amount) AS revenue
FROM healthcare_master
GROUP BY payment_status;

-- Executive dashboard summary query
SELECT
    COUNT(DISTINCT patient_id_x) AS total_patients,
    COUNT(DISTINCT appointment_id) AS total_appointments,
    COUNT(DISTINCT treatment_id) AS total_treatments,
    SUM(amount) AS total_revenue,
    ROUND(AVG(amount), 2) AS avg_bill
FROM healthcare_master;


-- ============================================================
-- SECTION 6: Window Functions
-- ============================================================

-- ROW_NUMBER(): rank individual bills by amount
SELECT patient_id_x,
       amount,
       ROW_NUMBER() OVER (ORDER BY amount DESC) AS row_num
FROM healthcare_master;

-- RANK(): treatments ranked by total revenue
SELECT treatment_type,
       SUM(amount) AS revenue,
       RANK() OVER (ORDER BY SUM(amount) DESC) AS revenue_rank
FROM healthcare_master
GROUP BY treatment_type;

-- DENSE_RANK(): treatments ranked by revenue (no gaps on ties)
SELECT treatment_type,
       SUM(amount) AS revenue,
       DENSE_RANK() OVER (ORDER BY SUM(amount) DESC) AS rank
FROM healthcare_master
GROUP BY treatment_type;

-- NTILE(4): quartile buckets by bill amount
SELECT patient_id_x,
       amount,
       NTILE(4) OVER (ORDER BY amount DESC) AS quartile
FROM healthcare_master;

-- NTILE(5): top 20% of bills
SELECT patient_id_x,
       amount,
       NTILE(5) OVER (ORDER BY amount DESC) AS revenue_bucket
FROM healthcare_master;

-- LAG(): previous bill amount, ordered by date
SELECT bill_date,
       amount,
       LAG(amount) OVER (ORDER BY bill_date) AS previous_amount,
       amount - LAG(amount) OVER (ORDER BY bill_date) AS difference
FROM healthcare_master;

-- LEAD(): next bill amount, ordered by date
SELECT bill_date,
       amount,
       LEAD(amount) OVER (ORDER BY bill_date) AS next_amount
FROM healthcare_master;

-- Running / cumulative revenue over time
SELECT bill_date,
       amount,
       SUM(amount) OVER (ORDER BY bill_date) AS cumulative_revenue
FROM healthcare_master;

-- Monthly revenue growth (compare to previous month)
SELECT month,
       SUM(amount) AS revenue,
       LAG(SUM(amount)) OVER (ORDER BY month) AS prev_revenue
FROM healthcare_master
GROUP BY month;

-- Revenue contribution % of each treatment type (window function in aggregate)
SELECT treatment_type,
       ROUND(SUM(amount), 2) AS revenue,
       ROUND(
           SUM(amount) * 100.0 / SUM(SUM(amount)) OVER (),
           2
       ) AS contribution_percent
FROM healthcare_master
GROUP BY treatment_type
ORDER BY revenue DESC;

-- Revenue ranking by age group
SELECT age_group,
       SUM(amount) AS revenue,
       RANK() OVER (ORDER BY SUM(amount) DESC) AS revenue_rank
FROM healthcare_master
GROUP BY age_group;


-- ============================================================
-- SECTION 7: CTEs & Multi-Step Analysis
-- ============================================================

-- Basic CTE: revenue by treatment type
WITH treatment_revenue AS (
    SELECT treatment_type,
           SUM(amount) AS revenue
    FROM healthcare_master
    GROUP BY treatment_type
)
SELECT *
FROM treatment_revenue
ORDER BY revenue DESC;

-- CTE + RANK(): treatments ranked by revenue
WITH treatment_revenue AS (
    SELECT treatment_type,
           SUM(amount) AS revenue
    FROM healthcare_master
    GROUP BY treatment_type
)
SELECT *,
       RANK() OVER (ORDER BY revenue DESC) AS treatment_rank
FROM treatment_revenue;

-- CTE filter: treatments with revenue above 100,000
WITH revenue_data AS (
    SELECT treatment_type,
           SUM(amount) AS revenue
    FROM healthcare_master
    GROUP BY treatment_type
)
SELECT *
FROM revenue_data
WHERE revenue > 100000;

-- CTE + PARTITION BY + RANK: highest revenue treatment per age group
WITH treatment_revenue AS (
    SELECT age_group,
           treatment_type,
           SUM(amount) AS revenue,
           RANK() OVER (PARTITION BY age_group ORDER BY SUM(amount) DESC) AS rnk
    FROM healthcare_master
    GROUP BY age_group, treatment_type
)
SELECT *
FROM treatment_revenue
WHERE rnk = 1;

-- CTE + DENSE_RANK(): top 3 highest bills
WITH bill_rank AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY amount DESC) AS rnk
    FROM healthcare_master
)
SELECT *
FROM bill_rank
WHERE rnk <= 3;


-- ============================================================
-- SECTION 8: Views & Indexes
-- ============================================================

CREATE VIEW revenue_summary AS
SELECT treatment_type,
       SUM(amount) AS revenue
FROM healthcare_master
GROUP BY treatment_type;

SELECT * FROM revenue_summary;

CREATE INDEX idx_patient
ON healthcare_master (patient_id_x);

CREATE INDEX idx_treatment
ON healthcare_master (treatment_type);


-- ============================================================
-- SECTION 9: Stored Functions, Procedures & Triggers (PL/pgSQL)
-- ============================================================

-- Stored function: total revenue
CREATE OR REPLACE FUNCTION get_total_revenue()
RETURNS NUMERIC AS
$$
BEGIN
    RETURN (
        SELECT SUM(amount)
        FROM healthcare_master
    );
END;
$$ LANGUAGE plpgsql;

SELECT get_total_revenue();

-- Stored function: revenue by a given treatment type
CREATE OR REPLACE FUNCTION get_revenue_by_treatment(t_name VARCHAR)
RETURNS NUMERIC AS
$$
BEGIN
    RETURN (
        SELECT SUM(amount)
        FROM healthcare_master
        WHERE treatment_type = t_name
    );
END;
$$ LANGUAGE plpgsql;

SELECT get_revenue_by_treatment('MRI');
SELECT get_revenue_by_treatment('ECG');

-- Stored procedure: total patient count
CREATE OR REPLACE PROCEDURE patient_count()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Total Patients: %',
        (SELECT COUNT(DISTINCT patient_id_x) FROM healthcare_master);
END;
$$;

CALL patient_count();

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
BEFORE INSERT ON healthcare_master
FOR EACH ROW
EXECUTE FUNCTION check_amount();

-- PL/pgSQL loop example: print patient_id + amount for every row
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT patient_id_x, amount
        FROM healthcare_master
    LOOP
        RAISE NOTICE 'Patient: %, Amount: %', rec.patient_id_x, rec.amount;
    END LOOP;
END $$;


-- ============================================================
-- SECTION 10: Combined Summary Queries
-- ============================================================

-- Treatment-level summary: case count, avg bill, total revenue
SELECT
    treatment_type,
    COUNT(*) AS total_cases,
    ROUND(AVG(amount), 2) AS avg_bill,
    ROUND(SUM(amount), 2) AS total_revenue
FROM healthcare_master
GROUP BY treatment_type
ORDER BY total_revenue DESC;

-- Payment method x payment status breakdown
SELECT
    payment_method,
    payment_status,
    COUNT(*) AS total_transactions
FROM healthcare_master
GROUP BY payment_method, payment_status
ORDER BY payment_method;
