# Healthcare Analytics & Predictive Modeling

End-to-end healthcare analytics project built using SQL, Python, Machine Learning, and Power BI — analyzing patient trends, financial performance, and predicting appointment no-shows to support data-driven decision-making in healthcare organizations.

---

## Problem Statement

Patient no-shows are a major operational and financial challenge for healthcare providers, leading to wasted clinical capacity and lost revenue. This project analyzes historical patient, appointment, treatment, and billing data to uncover patterns behind no-shows, and builds predictive models to flag at-risk patients in advance.

---

## Dataset

- Records: 200 patients
- Fields: patient demographics, appointment details, treatment type, billing/insurance information, and appointment priority
- [Add dataset source here — e.g. Kaggle link, or "synthetically generated for demonstration purposes"]
- Note: This is a small sample dataset; results are intended to demonstrate methodology and should be validated on a larger, real-world dataset before production use.

---

## Technologies Used

- Python (Pandas, NumPy, Matplotlib, Seaborn, SciPy)
- Scikit-Learn
- SQL (SQLite)
- Power BI
- Jupyter Notebook

---

## Project Workflow

### 1. Data Collection & Integration
Collected and integrated patient, appointment, treatment, and billing datasets into a unified healthcare analytics database.

### 2. Data Cleaning & Preprocessing
Handled missing values, removed duplicates, corrected data formats, and engineered features including `lead_time_days` (days between registration and appointment date).

### 3. SQL-Based Data Analysis
Designed and executed SQL queries (`sql/healthcare_queries.sql`) covering patient demographics, appointment trends, treatment performance, revenue/billing analysis, and ranking analysis using window functions (e.g., `RANK()` for billing analysis by insurance provider).

### 4. Machine Learning

**Models used:** Logistic Regression, Random Forest Classifier, K-Means Clustering

#### Model Evaluation

| Model | Notes | Accuracy | Precision | Recall | F1-Score |
|---|---|---|---|---|---|
| Logistic Regression | All features | 0.675 | 0.444 | 0.333 | 0.380 |
| Random Forest | All features | 0.775 | 0.714 | 0.417 | 0.526 |
| Random Forest | Leakage-corrected (priority removed) | 0.500 | 0.214 | 0.250 | 0.231 |
| Random Forest | Leakage-corrected + engineered `lead_time_days` | 0.600 | 0.167 | 0.083 | 0.111 |
| Random Forest (5-fold CV) | Leakage-corrected + `lead_time_days` | 0.625 (± 0.047) | — | — | — |

**Key finding — Data Leakage Detection:** Initial feature importance analysis showed `priority` (Low/Medium) as the dominant predictor in both models. Further investigation revealed `priority = Low` and `priority = Medium` perfectly predicted "no no-show" (100% of cases), indicating data leakage rather than genuine behavioral signal. After removing this feature, accuracy dropped from an inflated 77.5% to an honest ~50-62%, reflecting the model's true predictive power on legitimate features. This highlights the importance of feature auditing in ML pipelines.

**Class imbalance observation:** Adding `lead_time_days` slightly improved raw accuracy but reduced recall significantly, since the dataset's no-show cases are a minority class. Accuracy alone is a misleading metric here — future work should apply class-balancing techniques (e.g., SMOTE, class weighting).

#### Statistical Validation
A chi-square test was performed to validate whether `reason_for_visit` has a statistically significant relationship with no-show outcomes: χ² = 6.24, p = 0.182. At the 5% significance level, this relationship is not statistically significant, indicating this feature alone does not strongly explain no-show behavior.

#### Patient Risk Segmentation (K-Means)
Patients were segmented into Low, Medium, and High Risk groups using K-Means clustering. A PCA-based 2D visualization confirmed reasonable separation between risk segments, validating the clustering approach.

### 5. Dashboard Development
Developed an interactive Power BI dashboard (`power_bi/healthcare_data.pbix`) with the following pages: Executive Dashboard, Patient Analytics, Appointment Analytics, Financial Analytics, Predictive Analytics, and Patient Details.

---

## Key Results

| Metric | Value |
|---|---|
| Total Patients | 200 |
| No-Show Rate | 26% |
| High-Risk Patients Identified | 32 |
| Best Honest Model Accuracy (5-fold CV) | 62.5% |

---

## Key Insights & Recommendations

- Identified and corrected a data leakage issue in the `priority` feature, ensuring model evaluation reflects genuine predictive power rather than an artifact of the data.
- Appointment lead time and patient demographics show some predictive value, but recall remains limited on this small dataset — recommend collecting richer behavioral features (e.g., prior no-show history, distance to clinic) for a production-grade model.
- `reason_for_visit` alone is not a statistically significant driver of no-shows (p = 0.182); decisions should not be based on this feature in isolation.
- K-Means segmentation provides a usable framework for prioritizing outreach (e.g., reminder calls) to High-Risk patients.

---

## Dashboard Screenshots

### Executive Dashboard
![Executive Dashboard](https://github.com/Radha0401/healthcare-analytics-project/raw/main/dashboard/executive%20analysis.png)

### Patient Analytics
![Patient Analytics](https://github.com/Radha0401/healthcare-analytics-project/raw/main/dashboard/patients%20analysis.png)

### Appointment Analytics
![Appointment Analytics](https://github.com/Radha0401/healthcare-analytics-project/raw/main/dashboard/appointment%20analysis.png)

### Financial Analytics
![Financial Analytics](https://github.com/Radha0401/healthcare-analytics-project/raw/main/dashboard/financial%20analysis.png)

### Predictive Analytics
![Predictive Analytics](https://github.com/Radha0401/healthcare-analytics-project/raw/main/dashboard/predictive%20analysis.png)

### Patient Details
![Patient Details](https://github.com/Radha0401/healthcare-analytics-project/raw/main/dashboard/details.png)

---

## Repository Structure
