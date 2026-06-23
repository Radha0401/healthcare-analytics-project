# Healthcare Analytics & Predictive Modeling

> End-to-end healthcare analytics project using SQL, Python, Machine Learning, and Power BI — analyzing patient trends, financial performance, and predicting appointment no-shows to support data-driven decision-making.

---

## Problem Statement

Patient no-shows are a major operational and financial challenge for healthcare providers, leading to wasted clinical capacity and lost revenue. This project analyzes historical patient, appointment, treatment, and billing data to uncover patterns behind no-shows, and builds predictive models to flag at-risk patients in advance.

---

## Key Results

| Metric | Value |
|---|---|
| Total Patients | 200 |
| No-Show Rate | 26% |
| Total Revenue | ₹551,249.85 |
| High-Risk Patients Identified | 32 |
| Best Honest Model Accuracy (5-fold CV) | 62.5% |
| Top Revenue Treatment | Chemotherapy (₹128,855.68) |

---

## Technologies Used

| Category | Tools |
|---|---|
| Language | Python (Pandas, NumPy, Matplotlib, Seaborn, SciPy) |
| Machine Learning | Scikit-Learn (Logistic Regression, Random Forest, K-Means) |
| Database | PostgreSQL — window functions, CTEs, stored procedures, triggers |
| BI & Visualization | Power BI (6-page interactive dashboard) |
| Environment | Jupyter Notebook, VS Code |

---

## Project Workflow

### 1. Data Collection & Integration
Collected and integrated patient, appointment, treatment, and billing datasets into a unified PostgreSQL analytics database.

### 2. Data Cleaning & Preprocessing (`notebook/data_cleaning.ipynb`)
- Handled missing values and inconsistent records
- Removed duplicate entries and corrected data formats
- Engineered features: `bmi_category`, `risk_score`, `risk_level`
- Engineered `lead_time_days` (days between registration and appointment date)

### 3. SQL-Based Data Analysis (`sql/healthcare_queries.sql`)
Advanced PostgreSQL queries covering:
- Patient demographics and age group analysis
- Appointment trends, attendance patterns, and no-show behavior
- Treatment performance and revenue/billing analysis
- **Window Functions:** `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `NTILE()`, `LAG()`, `LEAD()`
- **CTEs** for multi-step analysis
- **Correlated Subqueries** for advanced filtering
- **Views, Indexes, Stored Functions, Procedures, and Triggers** (PL/pgSQL)

> SQL query outputs with actual results are in `dashboard/sql_queries/`

### 4. Machine Learning (`notebook/ML_work.ipynb`)

**Models:** Logistic Regression, Random Forest Classifier, K-Means Clustering

#### Model Evaluation

| Model | Notes | Accuracy | Precision | Recall | F1 |
|---|---|---|---|---|---|
| Logistic Regression | All features (with priority) | 0.675 | 0.444 | 0.333 | 0.380 |
| Random Forest | All features (with priority) | 0.775 | 0.714 | 0.417 | 0.526 |
| Random Forest | Leakage-corrected | 0.500 | 0.214 | 0.250 | 0.231 |
| Random Forest | + `lead_time_days` | 0.600 | 0.167 | 0.083 | 0.111 |
| Random Forest (5-fold CV) | Final honest estimate | 0.625 ± 0.047 | — | — | — |

#### ⚠️ Key Finding — Data Leakage Detection
Feature importance analysis revealed `priority` (Low/Medium) as the dominant predictor. Investigation confirmed that `priority = Low/Medium` perfectly predicted `no-show = 0` in 100% of cases — **data leakage**, not a genuine signal. After removing this feature, accuracy dropped from an inflated 77.5% to an honest ~62.5%, reflecting true predictive power on legitimate features.

#### Statistical Validation
Chi-square test on `reason_for_visit` vs. no-show: χ² = 6.24, **p = 0.182** — not statistically significant at the 5% level.

#### Patient Risk Segmentation
K-Means clustering (k=3) segmented patients into Low, Medium, and High Risk groups. PCA-based 2D visualization confirmed reasonable cluster separation.

### 5. Power BI Dashboard (`power_bi/healthcare_data.pbix`)
6-page interactive dashboard:
- Executive Dashboard
- Patient Analytics
- Appointment Analytics
- Financial Analytics
- Predictive Analytics
- Patient Details

---

## Dashboard Preview

![Dashboard](dashboard/power_bi/Screenshot%202026-06-21%20103009.png)

---

## Key Insights & Recommendations

- **Data Leakage Identified & Fixed:** `priority` feature was leaking the target — removed and model retrained for honest evaluation
- **Lead Time Matters:** Patients booked far in advance need proactive reminders
- **`reason_for_visit` Not Significant:** Chi-square (p = 0.182) — avoid over-relying on it
- **32 High-Risk Patients** should be prioritized for SMS/call reminders to reduce no-shows
- **Chemotherapy** generates highest revenue (23.38%) — missed appointments here represent significant loss
- **Model Limitation:** With 200 records, current recall is low — recommend SMOTE + prior no-show history for production use

---

## Repository Structure

```
healthcare-analytics-project/
├── dashboard/
│   ├── ml_ss/               # ML visualization screenshots
│   ├── sql_queries/         # SQL query output screenshots
│   └── power_bi/            # Power BI dashboard screenshots
├── power_bi/
│   └── healthcare_data.pbix # Interactive Power BI file
├── data/
│   ├── cleaned/             # Cleaned, processed datasets
│   └── raw_data/            # Raw datasets (large files excluded via .gitignore)
├── notebook/
│   ├── data_cleaning.ipynb  # Data cleaning & feature engineering
│   ├── analysis.ipynb       # EDA & SQL-based analysis
│   └── ML_work.ipynb        # ML modeling, evaluation & segmentation
├── sql/
│   └── healthcare_queries.sql
├── sql_outputs/             # SQL query results
├── .gitignore
├── requirements.txt
├── LICENSE
└── README.md
```

---

## How to Run

```bash
# 1. Clone the repo
git clone https://github.com/Radha0401/healthcare-analytics-project.git
cd healthcare-analytics-project

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run notebooks in order
#    data_cleaning.ipynb → analysis.ipynb → ML_work.ipynb

# 4. For SQL: open sql/healthcare_queries.sql in pgAdmin (PostgreSQL) and run with F5

# 5. For dashboard: open power_bi/healthcare_data.pbix in Power BI Desktop (free)
```

---

## Data Dictionary

| Column | Description |
|---|---|
| patient_id_x | Unique patient identifier |
| age | Patient age in years |
| age_group | Age bracket (Young Adult / Middle Age / Senior) |
| gender | Patient gender (M/F) |
| priority | Appointment urgency level (Low / Medium / High) |
| reason_for_visit | Visit purpose (Consultation / Therapy / Follow-up / Emergency) |
| treatment_type | Treatment received (X-Ray / MRI / ECG / Physiotherapy / Chemotherapy) |
| cost | Treatment cost |
| amount | Billing amount |
| payment_status | Paid or Pending |
| lead_time_days | Days between registration and appointment (engineered feature) |
| target | No-show outcome — 1 = No-Show, 0 = Attended |
| Patient_Segment | K-Means label (Low / Medium / High Risk) |

---

## Future Improvements

- Validate on a larger, real-world dataset
- Apply SMOTE / class weighting to improve recall on minority class
- Add behavioral features: prior no-show history, distance to clinic
- Deploy prediction model as a Streamlit web app
- Automate data pipeline for real-time analytics

---

## Dataset

- **Source:** Synthetically generated for demonstration purposes
- **Records:** 200 patients
- **Note:** Results demonstrate methodology — validate on real-world data before production use

---

## Author

**Radha Yadav**

Data Analytics | SQL (PostgreSQL) | Python | Machine Learning | Power BI

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Radha%20Yadav-blue?logo=linkedin)](https://www.linkedin.com/in/radha-yadav05)
[![GitHub](https://img.shields.io/badge/GitHub-Radha0401-black?logo=github)](https://github.com/Radha0401)
