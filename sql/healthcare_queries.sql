
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
--tatal records

SELECT COUNT(*) AS total_records
FROM healthcare_master;
--data preview
SELECT *
FROM healthcare_master
LIMIT 10;
--gender
SELECT gender,
       COUNT(*) AS total_patients
FROM healthcare_master
GROUP BY gender;
--ttaol patient
SELECT COUNT(DISTINCT patient_id_x) AS total_patients
FROM healthcare_master;
--age group
SELECT age_group,
       COUNT(*) AS total_patients
FROM healthcare_master
GROUP BY age_group
ORDER BY total_patients DESC;
--appointment ststus
SELECT status,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY status;
--pripory
SELECT priority,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY priority;
--traetment analysis
SELECT treatment_type,
       COUNT(*) AS frequency
FROM healthcare_master
GROUP BY treatment_type
ORDER BY frequency DESC;
--total revennu
SELECT SUM(amount) AS total_revenue
FROM healthcare_master;
-- paymet ststus 
SELECT payment_status,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY payment_status;
-- revenu by teaetment type
SELECT treatment_type,
       ROUND(SUM(amount),2) AS revenue
FROM healthcare_master
GROUP BY treatment_type
ORDER BY revenue DESC;
-- top 5 most common treatment
SELECT treatment_type,
       COUNT(*) AS frequency
FROM healthcare_master
GROUP BY treatment_type
ORDER BY frequency DESC
LIMIT 5;
-- avg tratmnet cost
SELECT ROUND(AVG(cost),2) AS avg_cost
FROM healthcare_master;
-- revenu by payment methode
SELECT payment_method,
       ROUND(SUM(amount),2) AS revenue
FROM healthcare_master
GROUP BY payment_method
ORDER BY revenue DESC;
-- payment ststus analysis
SELECT payment_status,
       COUNT(*) AS total_bills
FROM healthcare_master
GROUP BY payment_status;
-- high priopty casw
SELECT COUNT(*) AS high_priority_cases
FROM healthcare_master
WHERE priority='High';
-- . Appointment Status Distribution
SELECT status,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY status;
-- Top 10 Highest Bills
SELECT bill_id,
       amount
FROM healthcare_master
ORDER BY amount DESC
LIMIT 10;
-- Revenue by Age Group
SELECT age_group,
       ROUND(SUM(amount),2) AS revenue
FROM healthcare_master
GROUP BY age_group
ORDER BY revenue DESC;
-- Cost Category Analysis
SELECT cost_category,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY cost_category;

SELECT COUNT(*)
FROM healthcare_master;
-- Top Revenue Generating Treatments
SELECT treatment_type,
       ROUND(SUM(amount),2) AS revenue
FROM healthcare_master
GROUP BY treatment_type
ORDER BY revenue DESC
LIMIT 5;
-- Rank Treatments by Revenue (Window Function)
SELECT treatment_type,
       ROUND(SUM(amount),2) AS revenue,
       RANK() OVER(ORDER BY SUM(amount) DESC) AS revenue_rank
FROM healthcare_master
GROUP BY treatment_type;
-- revenue Contribution by Age Group
SELECT age_group,
       ROUND(SUM(amount),2) AS revenue
FROM healthcare_master
GROUP BY age_group
ORDER BY revenue DESC;
-- Running Revenue (Window Function)
SELECT bill_date,
       amount,
       SUM(amount) OVER(ORDER BY bill_date) AS running_revenue
FROM healthcare_master;
-- Highest Bill in Each Payment Method
SELECT payment_method,
       MAX(amount) AS highest_bill
FROM healthcare_master
GROUP BY payment_method;
-- CTE Example
WITH treatment_revenue AS (
    SELECT treatment_type,
           SUM(amount) AS revenue
    FROM healthcare_master
    GROUP BY treatment_type
)
SELECT *
FROM treatment_revenue
ORDER BY revenue DESC;

-- Monthly Revenue Trend
SELECT month,
       ROUND(SUM(amount),2) AS revenue
FROM healthcare_master
GROUP BY month
ORDER BY revenue DESC;

-- Payment Status
SELECT payment_status,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY payment_status;

-- Appointment Status
SELECT status,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY status;

-- Priority Distribution
SELECT priority,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY priority;

-- Cost Category Analysis
SELECT cost_category,
       COUNT(*) AS total
FROM healthcare_master
GROUP BY cost_category;
--age and age category
SELECT patient_id_x,
       age,
       CASE
           WHEN age < 18 THEN 'Child'
           WHEN age BETWEEN 18 AND 40 THEN 'Young'
           WHEN age BETWEEN 41 AND 60 THEN 'Middle Age'
           ELSE 'Senior'
       END AS age_category
FROM healthcare_master;
--revenu type
SELECT treatment_type,
       amount,
       CASE
           WHEN amount > 4000 THEN 'High Revenue'
           WHEN amount > 2000 THEN 'Medium Revenue'
           ELSE 'Low Revenue'
       END AS revenue_category
FROM healthcare_master;
--using row no
SELECT patient_id_x,
       amount,
       ROW_NUMBER() OVER(ORDER BY amount DESC) AS row_num
FROM healthcare_master;
-- rank
SELECT treatment_type,
       SUM(amount) AS revenue,
       RANK() OVER(ORDER BY SUM(amount) DESC) AS rank
FROM healthcare_master
GROUP BY treatment_type;
-- dense rank
SELECT treatment_type,
       SUM(amount) AS revenue,
       DENSE_RANK() OVER(ORDER BY SUM(amount) DESC) AS rank
FROM healthcare_master
GROUP BY treatment_type;
--cte tearemt and paisaa
WITH revenue_data AS
(
    SELECT treatment_type,
           SUM(amount) AS revenue
    FROM healthcare_master
    GROUP BY treatment_type
)
SELECT *
FROM revenue_data
WHERE revenue > 100000;
--subquery
SELECT *
FROM healthcare_master
WHERE amount >
(
    SELECT AVG(amount)
    FROM healthcare_master
);

-- Correlated Subquery
SELECT *
FROM healthcare_master h1
WHERE amount >
(
    SELECT AVG(amount)
    FROM healthcare_master h2
    WHERE h1.payment_method = h2.payment_method
);

-- NTILE() highest payment kiski hai
SELECT patient_id_x,
       amount,
       NTILE(4) OVER(ORDER BY amount DESC) AS quartile
FROM healthcare_master;

-- Running Total
SELECT bill_date,
       amount,
       SUM(amount) OVER(ORDER BY bill_date) AS running_total
FROM healthcare_master;

-- 1. LAG()
SELECT bill_date,
       amount,
       LAG(amount) OVER(ORDER BY bill_date) AS previous_amount
FROM healthcare_master;

-- LEAD()
SELECT bill_date,
       amount,
       LEAD(amount) OVER(ORDER BY bill_date) AS next_amount
FROM healthcare_master;

-- Stored Function
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

-- Stored Procedure
CREATE OR REPLACE PROCEDURE patient_count()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Total Patients: %',
    (SELECT COUNT(DISTINCT patient_id_x)
     FROM healthcare_master);
END;
$$;

CALL patient_count();

-- -- LOOP Example (PL/pgSQL)
-- DO $$
-- DECLARE
--     i INT := 1;
-- BEGIN
--     WHILE i <= 5 LOOP
--         RAISE NOTICE 'Value: %', i;
--         i := i + 1;
--     END LOOP;
-- END $$;


-- loops use . data of all patients
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT patient_id_x, amount
        FROM healthcare_master
    LOOP
        RAISE NOTICE 'Patient: %, Amount: %',
        rec.patient_id_x,
        rec.amount;
    END LOOP;
END $$;
------

-- Top Revenue Treatment with Percentage Contribution
SELECT
    treatment_type,
    ROUND(SUM(amount),2) AS revenue,
    ROUND(
        SUM(amount) * 100.0 /
        SUM(SUM(amount)) OVER(),
        2
    ) AS contribution_percent
FROM healthcare_master
GROUP BY treatment_type
ORDER BY revenue DESC;
----

-- Revenue Above Average
SELECT *
FROM healthcare_master
WHERE amount >
(
    SELECT AVG(amount)
    FROM healthcare_master
);
----
-- Top 3 Highest Bills
WITH bill_rank AS
(
    SELECT *,
           DENSE_RANK() OVER
           (ORDER BY amount DESC) rnk
    FROM healthcare_master
)
SELECT *
FROM bill_rank
WHERE rnk <= 3;
------
-- Running Revenue Trend
SELECT
    bill_date,
    amount,
    SUM(amount)
    OVER(ORDER BY bill_date)
    AS cumulative_revenue
FROM healthcare_master;
--------
-- Previous Payment Comparison
SELECT
    bill_date,
    amount,
    LAG(amount)
    OVER(ORDER BY bill_date) AS previous_bill,
    amount -
    LAG(amount)
    OVER(ORDER BY bill_date)
    AS difference
FROM healthcare_master;
-----
-- Revenue by Age Group Ranking
SELECT
    age_group,
    SUM(amount) revenue,
    RANK() OVER
    (ORDER BY SUM(amount) DESC)
    AS revenue_rank
FROM healthcare_master
GROUP BY age_group;
------------
-- High Risk Revenue Loss
SELECT
    payment_status,
    SUM(amount) revenue
FROM healthcare_master
GROUP BY payment_status;
------------
-- No-Show Rate
SELECT
ROUND(
COUNT(*) FILTER
(WHERE status='No-show')
*100.0/
COUNT(*),
2
) AS no_show_percentage
FROM healthcare_master;
---------------
-- High Priority Success Rate
SELECT
priority,
status,
COUNT(*)
FROM healthcare_master
GROUP BY priority,status
ORDER BY priority;
-------------
-- Most Valuable Payment Method
SELECT
payment_method,
ROUND(AVG(amount),2) avg_bill
FROM healthcare_master
GROUP BY payment_method
ORDER BY avg_bill DESC;
------------
-- Monthly Revenue Growth
SELECT
month,
SUM(amount) revenue,
LAG(SUM(amount))
OVER(ORDER BY month) prev_revenue
FROM healthcare_master
GROUP BY month;
--------------

SELECT * FROM healthcare_master LIMIT 1
-- executive dashboard query
SELECT
COUNT(DISTINCT patient_id_x) AS total_patients,
COUNT(DISTINCT appointment_id) AS total_appointments,
COUNT(DISTINCT treatment_id) AS total_treatments,
SUM(amount) AS total_revenue,
ROUND(AVG(amount),2) AS avg_bill
FROM healthcare_master;
-- cte 
WITH treatment_revenue AS
(
    SELECT
        treatment_type,
        SUM(amount) AS revenue
    FROM healthcare_master
    GROUP BY treatment_type
)
SELECT *,
       RANK() OVER(ORDER BY revenue DESC) AS treatment_rank
FROM treatment_revenue;

-------------

-- Highest Revenue Treatment per Age Group
WITH treatment_revenue AS
(
    SELECT
        age_group,
        treatment_type,
        SUM(amount) revenue,
        RANK() OVER
        (
            PARTITION BY age_group
            ORDER BY SUM(amount) DESC
        ) rnk
    FROM healthcare_master
    GROUP BY age_group,treatment_type
)
SELECT *
FROM treatment_revenue
WHERE rnk = 1;

-- Concept: CTE + PARTITION BY + RANK

-- 2. Revenue Difference from Overall Average
SELECT
    treatment_type,
    ROUND(AVG(amount),2) avg_revenue,
    ROUND(
        AVG(amount) -
        (SELECT AVG(amount)
         FROM healthcare_master),
         2
    ) difference_from_avg
FROM healthcare_master
GROUP BY treatment_type;


-----------

-- Top 20% Bills (NTILE)
SELECT
    patient_id_x,
    amount,
    NTILE(5)
    OVER(ORDER BY amount DESC) AS revenue_bucket
FROM healthcare_master;

-------
CREATE VIEW revenue_summary AS
SELECT
    treatment_type,
    SUM(amount) AS revenue
FROM healthcare_master
GROUP BY treatment_type;

SELECT * FROM revenue_summary;

CREATE INDEX idx_patient
ON healthcare_master(patient_id_x);

CREATE INDEX idx_treatment
ON healthcare_master(treatment_type);


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

SELECT
    treatment_type,
    COUNT(*) AS total_cases,
    ROUND(AVG(amount),2) AS avg_bill,
    ROUND(SUM(amount),2) AS total_revenue
FROM healthcare_master
GROUP BY treatment_type
ORDER BY total_revenue DESC;

SELECT
    payment_method,
    payment_status,
    COUNT(*) AS total_transactions
FROM healthcare_master
GROUP BY payment_method, payment_status
ORDER BY payment_method;