# Healthcare Analytics & Predictive Modeling

End-to-end healthcare analytics project built using SQL, Python, Machine Learning, and Power BI — analyzing patient trends, financial performance, and predicting appointment no-shows to support data-driven decision-making in healthcare organizations.

---

## Problem Statement

Patient no-shows are a major operational and financial challenge for healthcare providers, leading to wasted clinical capacity and lost revenue. This project analyzes historical patient, appointment, treatment, and billing data to uncover patterns behind no-shows, and builds predictive models to flag at-risk patients in advance.

---

## Dataset

- **Source:** Synthetically generated for demonstration purposes
- **Records:** 200 patients
- **Fields:** Patient demographics, appointment details, treatment type, billing/insurance information, and appointment priority
- **Note:** This is a small sample dataset; results are intended to demonstrate methodology and should be validated on a larger, real-world dataset before production use.

---

## Technologies Used

- Python (Pandas, NumPy, Matplotlib, Seaborn, SciPy)
- Scikit-Learn
- SQL (PostgreSQL) — window functions, CTEs, stored functions, procedures, triggers
- Power BI
- Jupyter Notebook

---

## Project Workflow

### 1. Data Collection & Integration
Collected and integrated patient, appointment, treatment, and billing datasets into a unified healthcare analytics database (PostgreSQL).

### 2. Data Cleaning & Preprocessing
- Handled missing values and inconsistent records
- Removed duplicate entries and corrected data formats
- Engineered new feature: `lead_time_days` (days between registration and appointment date)
- Prepared datasets for machine learning and dashboard development

### 3. SQL-Based Data Analysis
Designed and executed advanced SQL queries (`sql/healthcare_queries.sql`) in PostgreSQL covering:
- Patient demographics and age group analysis
- Appointment trends, attendance patterns, and no-show behavior
- Treatment performance and revenue/billing analysis
- **Window Functions:** `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `NTILE()`, `LAG()`, `LEAD()`
- **CTEs** for multi-step analysis (e.g., top revenue treatment per age group)
- **Subqueries & Correlated Subqueries** for advanced filtering
- **Views, Indexes, Stored Functions, Procedures, and Triggers** (PL/pgSQL)

> SQL query outputs with actual results are available in `dashboard/sql_queries/`

### 4. Machine Learning

**Models used:** Logistic Regression, Random Forest Classifier, K-Means Clustering

#### Model Evaluation

| Model | Notes | Accuracy | Precision | Recall | F1-Score |
|---|---|---|---|---|---|
| Logistic Regression | All features (with priority) | 0.675 | 0.444 | 0.333 | 0.380 |
| Random Forest | All features (with priority) | 0.775 | 0.714 | 0.417 | 0.526 |
| Random Forest | Leakage-corrected (priority removed) | 0.500 | 0.214 | 0.250 | 0.231 |
| Random Forest | Leakage-corrected + `lead_time_days` | 0.600 | 0.167 | 0.083 | 0.111 |
| Random Forest (5-fold CV) | Leakage-corrected + `lead_time_days` | 0.625 ± 0.047 | — | — | — |

#### Key Finding — Data Leakage Detection
Initial feature importance analysis revealed `priority` (Low/Medium) as the dominant predictor in both models. Further investigation confirmed that `priority = Low` and `priority = Medium` perfectly predicted no-show = 0 (100% of cases), indicating **data leakage** rather than genuine behavioral signal. After removing this feature, accuracy dropped from an inflated 77.5% to an honest ~50–62%, reflecting the model's true predictive power on legitimate features. This highlights the critical importance of feature auditing in ML pipelines.

#### Class Imbalance Observation
Adding `lead_time_days` slightly improved raw accuracy but reduced recall significantly, since no-show cases are a minority class in this dataset. Accuracy alone is a misleading metric here — future work should apply class-balancing techniques (e.g., SMOTE, class weighting).

#### Hyperparameter Tuning
GridSearchCV was performed on the Random Forest model (parameters: `n_estimators`, `max_depth`). Best configuration: `n_estimators=150, max_depth=None`. Best F1 score: **0.11** — confirming that the bottleneck is feature richness and dataset size, not model configuration.

#### Statistical Validation
Chi-square test on `reason_for_visit` vs. no-show outcome:
- χ² = 6.24, p = 0.182
- At the 5% significance level, this relationship is **not statistically significant** — this feature alone does not strongly explain no-show behavior.

#### Patient Risk Segmentation (K-Means)
Patients were segmented into Low, Medium, and High Risk groups using K-Means clustering. A PCA-based 2D visualization confirmed reasonable separation between risk segments, validating the clustering approach.

### 5. Dashboard Development
Developed an interactive Power BI dashboard (`power_bi/healthcare_data.pbix`) with 6 pages:
- Executive Dashboard
- Patient Analytics
- Appointment Analytics
- Financial Analytics
- Predictive Analytics
- Patient Details

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

## Key Insights & Recommendations

- **Data Leakage Identified & Fixed:** `priority` feature was found to perfectly predict outcomes — removed and model retrained for honest evaluation.
- **Lead Time Matters:** Appointment lead time shows some predictive value; patients booked far in advance may need additional reminders.
- **`reason_for_visit` Not Significant:** Chi-square test (p = 0.182) confirms this feature alone does not drive no-shows — avoid over-relying on it.
- **K-Means Segmentation:** High-Risk patients (32 total) should be prioritized for proactive outreach (SMS/call reminders) to reduce no-show rates.
- **Revenue Insight:** Chemotherapy generates the highest revenue (23.38% contribution); MRI and X-Ray follow. Missed appointments in these categories represent significant revenue loss.
- **Model Limitation:** With 200 records and limited behavioral features, current model recall is low — recommend incorporating prior no-show history and distance to clinic for a production-grade model.

---
> Download `power_bi/healthcare_data.pbix` and open in **Power BI Desktop** (free) to explore the fully interactive dashboard.

---


## Repository Structure
healthcare-analytics-project/

├── dashboard/

│   ├── ml_ss/               # ML visualization screenshots

│   ├── sql_queries/         # SQL query output screenshots (13 queries)

│   └── power_bi/            # Power BI dashboard screenshots

├── power_bi/

│   └── healthcare_data.pbix # Interactive Power BI file (open in Power BI Desktop)

├── data/

│   ├── raw folder/          # Original raw datasets (large files excluded)

│   └── cleaned folder/      # Cleaned, processed datasets

├── notebook/

│   ├── data_cleaning.ipynb

│   ├── analysis.ipynb

│   └── ML_work.ipynb

├── sql/

│   └── healthcare_queries.sql

├── hospital_healthcare.db

├── requirements.txt

├── LICENSE

└── README.md


## How to Run This Project

1. Clone the repository:
git clone https://github.com/Radha0401/healthcare-analytics-project.git

cd healthcare-analytics-project

2. Install dependencies:
pip install -r requirements.txt

3. Run the notebooks in order:
data_cleaning.ipynb → analysis.ipynb → ML_work.ipynb

4. Open `power_bi/healthcare_data.pbix` in **Power BI Desktop** (free download) to explore the interactive dashboard.

5. For SQL queries, open `sql/healthcare_queries.sql` in **pgAdmin** (PostgreSQL) and run queries individually by selecting and pressing F5.

---

## Data Dictionary

| Column | Description |
|---|---|
| patient_id_x | Unique patient identifier |
| age | Patient's age in years |
| age_group | Categorized age bracket (Young Adult, Middle Age, Senior) |
| gender | Patient's gender (M/F) |
| priority | Appointment urgency level assigned at booking (Low/Medium/High) |
| reason_for_visit | Purpose of appointment (Consultation, Therapy, Follow-up, Emergency) |
| treatment_type | Type of treatment received (X-Ray, MRI, ECG, Physiotherapy, Chemotherapy) |
| cost | Cost of treatment |
| amount | Billing amount |
| payment_status | Whether bill was paid or pending |
| lead_time_days | Engineered feature: days between registration and appointment date |
| target | No-show outcome — 1 = did not show, 0 = attended |
| Patient_Segment | K-Means cluster label (Low Risk / Medium Risk / High Risk) |

---

## Future Improvements

- Validate findings on a larger, real-world healthcare dataset
- Apply class-balancing techniques (SMOTE, class weights) to improve recall
- Incorporate behavioral features: prior no-show history, distance to clinic, weather data
- Deploy the no-show prediction model as a web app (Streamlit)
- Publish Power BI dashboard for live, interactive viewing
- Implement automated data pipeline for real-time analytics

---

## Project Highlights

- Built an end-to-end healthcare analytics solution using SQL, Python, Machine Learning, and Power BI
- **Identified and corrected a data leakage issue** during model development — a critical ML evaluation skill
- Validated findings using **chi-square statistical testing** and **5-fold cross-validation**
- Performed **hyperparameter tuning** (GridSearchCV) confirming dataset size as the primary bottleneck
- Applied **K-Means clustering** for patient risk segmentation, visualized using PCA
- Wrote advanced PostgreSQL queries including **window functions, CTEs, stored procedures, and triggers**
- Designed a **6-page interactive Power BI dashboard** for healthcare reporting
- Translated analytical findings into **actionable business recommendations**

---

## Author

**Radha Yadav**

Data Analytics | SQL (PostgreSQL) | Python | Machine Learning | Power BI

[![GitHub](https://img.shields.io/badge/GitHub-Radha0401-black?logo=github)](https://github.com/Radha0401)
