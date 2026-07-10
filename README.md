# Hospital Database Management System

> A normalized relational database for managing hospital operations — patients, doctors, appointments, treatments, billing, and insurance — built in PostgreSQL with advanced SQL analytics for operational decision-making.

---

## Problem Statement

Hospitals generate data across multiple disconnected areas — patient records, doctor schedules, treatments, billing, and insurance. This project designs a normalized relational schema to bring these together with proper integrity constraints, then builds analytical SQL queries to surface patient trends, doctor workload, revenue performance, and insurance coverage patterns.

---

## Key Results

| Metric | Value |
|---|---|
| Total Patients | 50 |
| Total Doctors | 10 |
| Total Appointments | 200 |
| No-Show Rate | 26% |
| Total Revenue | ₹551,249.85 |
| Top Revenue Treatment | Chemotherapy |

---

## Technologies Used

| Category | Tools |
|---|---|
| Database | PostgreSQL |
| Techniques | Joins, CTEs, Window Functions, Subqueries, Views, Indexes, Stored Functions, Stored Procedures, Triggers |
| Environment | pgAdmin / psql |

---

## Database Schema

Six normalized tables with primary and foreign key relationships:

```
patients (patient_id PK)
doctors (doctor_id PK)
insurance (insurance_id PK, patient_id FK -> patients)
appointments (appointment_id PK, patient_id FK -> patients, doctor_id FK -> doctors)
treatments (treatment_id PK, appointment_id FK -> appointments)
billing (bill_id PK, patient_id FK -> patients, treatment_id FK -> treatments)
```

- `patients` — demographic and contact details
- `doctors` — specialization, department, experience
- `insurance` — one insurance record per patient (provider, policy number)
- `appointments` — links a patient to a doctor for a given date/time
- `treatments` — treatment given during an appointment
- `billing` — bill generated for a treatment

Indexes are created on all foreign key columns to support efficient joins.

---

## SQL Analysis (`sql/hospital_queries.sql`)

Organized into clear sections:

1. **Schema Design** — table creation, PK/FK constraints, indexes
2. **Patient Demographics** — gender and age-group breakdowns
3. **Appointment Analysis** — status distribution, no-show rate, multi-table joins
4. **Doctor Workload Analysis** — appointments per doctor, no-show rate per doctor, revenue generated per doctor, department-wise ranking
5. **Treatment Analysis** — frequency, average cost, cost categorization
6. **Revenue & Billing Analysis** — payment method/status breakdowns, subqueries, correlated subqueries
7. **Window Functions** — `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `NTILE()`, `LAG()`, `LEAD()`, running totals
8. **CTEs** — multi-step revenue and ranking analysis
9. **Insurance Analysis** — patients by provider, billing status by provider, patients with no insurance on file
10. **Views & Indexes** — `vw_revenue_summary`, `vw_doctor_performance`
11. **Stored Functions, Procedures & Triggers** — `get_total_revenue()`, `get_doctor_revenue()`, `patient_count()`, `doctor_no_show_summary()`, and a trigger preventing negative bill amounts
12. **Combined Summary Queries**

---

## Repository Structure

```
hospital-dbms-project/
├── data/
│   ├── patients.csv
│   ├── doctors.csv
│   ├── insurance.csv
│   ├── appointments.csv
│   ├── treatments.csv
│   └── billing.csv
├── dashboard/
│   └── sql_queries/         # Query output screenshots
├── sql/
│   └── hospital_queries.sql
├── LICENSE
└── README.md
```

---

## How to Run

```bash
# 1. Clone the repo
git clone https://github.com/Radha0401/hospital-dbms-project.git
cd hospital-dbms-project

# 2. Create a PostgreSQL database
createdb hospital_dbms

# 3. Run the schema + queries file (creates tables, indexes, views, functions)
psql -d hospital_dbms -f sql/hospital_queries.sql

# 4. Load the CSV data (run inside psql, or use \copy per table)
\copy patients FROM 'data/patients.csv' CSV HEADER
\copy doctors FROM 'data/doctors.csv' CSV HEADER
\copy insurance FROM 'data/insurance.csv' CSV HEADER
\copy appointments FROM 'data/appointments.csv' CSV HEADER
\copy treatments FROM 'data/treatments.csv' CSV HEADER
\copy billing FROM 'data/billing.csv' CSV HEADER
```

---

## Data Dictionary

| Table | Column | Description |
|---|---|---|
| patients | patient_id | Unique patient identifier (PK) |
| doctors | doctor_id | Unique doctor identifier (PK) |
| doctors | specialization | Doctor's medical specialization |
| insurance | insurance_id | Unique insurance record identifier (PK) |
| appointments | status | Appointment outcome (Scheduled / Completed / No-show) |
| treatments | cost | Cost of the treatment administered |
| billing | payment_status | Paid or Pending |

---

## Dataset

- **Source:** Synthetically generated for demonstration purposes
- **Records:** 50 patients, 10 doctors, 200 appointments, 200 treatments, 200 bills

---

## Author

**Radha Yadav**

Data Analytics | SQL (PostgreSQL)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Radha%20Yadav-blue?logo=linkedin)](https://www.linkedin.com/in/radha-yadav05)
[![GitHub](https://img.shields.io/badge/GitHub-Radha0401-black?logo=github)](https://github.com/Radha0401)
