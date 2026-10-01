<h1 align="center">📊 E-Commerce Monthly Revenue Growth & Performance Intelligence</h1>
<h3 align="center">A Governed SQL, Python & Tableau Revenue Analytics Engagement</h3>

<p align="center">
  <img src="assets/banner.png" alt="Revenue Intelligence Banner" width="100%" />
</p>

<p align="center">
  <a href="#-executive-summary"><img src="https://img.shields.io/badge/Executive-Summary-blue?style=for-the-badge&logo=markdown" /></a>
  <a href="#-tableau-dashboard"><img src="https://img.shields.io/badge/Tableau-Live_Dashboard-orange?style=for-the-badge&logo=tableau" /></a>
  <a href="#-sql-analytics"><img src="https://img.shields.io/badge/Pipeline-SQL_%26_Python-green?style=for-the-badge&logo=python" /></a>
  <a href="docs/metric_definitions.md"><img src="https://img.shields.io/badge/Docs-Modular_Files-purple?style=for-the-badge&logo=read-the-docs" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" /></a>
</p>

<p align="center">
  <em>23 Months Analyzed · $15,737,501 Gross Revenue Tracked · 100% Reconciled SQL + Python + Tableau Pipeline</em>
</p>

---

## 📑 Table of Contents

- [📌 Executive Summary](#-executive-summary)
- [💼 Scope & Data Gap Disclosure](#-scope--data-gap-disclosure)
- [🎯 Business Problem & Key Questions](#-business-problem--key-questions)
- [📊 KPI Framework & Metric Definitions](#-kpi-framework--metric-definitions)
- [🏗️ Technical Architecture & Pipeline](#-technical-architecture--pipeline)
- [🗄️ SQL Analytics Pipeline](#-sql-analytics-pipeline)
- [🐍 Python Analytics & Reconciliations](#-python-analytics--reconciliations)
- [🌐 Tableau Dashboard & Visual Analytics](#-tableau-dashboard--visual-analytics)
- [💡 Key Business Insights](#-key-business-insights)
- [📋 Business Recommendations](#-business-recommendations)
- [📄 Reports & Presentations](#-reports--presentations)
- [📚 Documentation Suite](#-documentation-suite)
- [🗂️ Repository Structure](#-repository-structure)
- [🛠️ Skills Demonstrated](#-skills-demonstrated)
- [👤 Author & License](#-author--license)

---

## 📌 Executive Summary

In enterprise e-commerce analytics, ad-hoc spreadsheet reporting often leads to conflicting MoM growth metrics, unverified aggregations, and metric drift. This project replaces manual spreadsheet pulls with a **governed, production-ready revenue analytics engine** built on **SQL, Python, and Tableau**. 

Analyzing **23 consecutive months of sales data** (October 2016 through August 2018) representing **$15,737,501 in cumulative gross revenue**, this pipeline delivers 100% data auditability, window-function growth diagnostics, and an executive-ready dashboard.

- **Total Analyzed Revenue:** `$15,737,501`
- **Time Horizon:** 23 Months (`2016-10-01` to `2018-08-01`)
- **Peak Monthly Revenue:** `$1,061,000` (May 2018)
- **Latest MoM Growth:** `-4.00%` (August 2018; 1-month dip following +0.53% in July 2018)
- **Max Consecutive Decline Streak:** **1 month** (No multi-month contraction anywhere in the 23-month history)

**Full Executive Report:** [`reports/executive_report.md`](reports/executive_report.md) · **Executive Presentation Deck:** [`reports/presentation.pdf`](reports/presentation.pdf)

---

## 💼 Scope & Data Gap Disclosure

> [!IMPORTANT]
> **Data Transparency Disclosure**
> The source extract (`data/raw/monthly_revenue_raw.csv`) contains two primary fields: `sales_month` and `current_month_revenue` across 23 monthly records. Order-level attributes (Order ID, Order Count, Unit Prices, customer IDs) are **not present in the raw source**.
>
> Consequently, **Order Count, Order Growth %, and Average Order Value (AOV) are strictly out of scope**. Rather than inventing synthetic order counts, this constraint is documented transparently across [`docs/assumptions.md`](docs/assumptions.md) and [`sql/03_analysis/05_orders_and_aov_NOT_AVAILABLE.sql`](sql/03_analysis/05_orders_and_aov_NOT_AVAILABLE.sql). All remaining core metrics—MoM %, YoY %, Cumulative Revenue, Gaps-and-Islands streak analysis, and Rolling Averages—are engineered at full scale.

---

## 🎯 Business Problem & Key Questions

Leadership required a reliable, centralized data asset to answer key financial performance questions on demand:

1. **Revenue Baseline & Trend:** What is the trajectory of monthly revenue over time? Is growth compounding or plateauing?
2. **MoM & YoY Performance:** How does each month perform against its preceding month and prior-year baseline?
3. **Volatility & Decline Identification:** Are revenue dips isolated shocks or systemic multi-month contractions?
4. **Cumulative Run-Rate:** What is the running lifetime revenue generated over the observed lifecycle?
5. **Recent Momentum:** Is recent performance (last 3 months vs. prior 3 months) accelerating or deteriorating?

---

## 📊 KPI Framework & Metric Definitions

| Metric Name | Mathematical & SQL Definition | Business Purpose | Reference Script |
|---|---|---|---|
| **Current Month Revenue** | `SUM(current_month_revenue)` | Measures total top-line revenue per monthly window | [`sql/03_analysis/01_monthly_revenue.sql`](sql/03_analysis/01_monthly_revenue.sql) |
| **MoM Growth %** | `(Current - LAG(Current)) / LAG(Current) * 100` | Tracks month-over-month percentage velocity | [`sql/03_analysis/02_mom_growth.sql`](sql/03_analysis/02_mom_growth.sql) |
| **YoY Growth %** | `(Current - LAG(Current, 12)) / LAG(Current, 12) * 100` | Evaluates annual performance comparison (Months 13+) | [`sql/03_analysis/03_yoy_growth.sql`](sql/03_analysis/03_yoy_growth.sql) |
| **Running Revenue** | `SUM(current_month_revenue) OVER (ORDER BY sales_month)` | Calculates cumulative platform lifetime revenue | [`sql/03_analysis/04_running_revenue.sql`](sql/03_analysis/04_running_revenue.sql) |
| **3-Month Rolling Avg** | `AVG(current_month_revenue) OVER (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` | Smooths monthly noise to establish baseline trend | [`sql/03_analysis/06_growth_diagnostics.sql`](sql/03_analysis/06_growth_diagnostics.sql) |
| **Decline Streak** | Gaps-and-Islands count of consecutive MoM negative months | Flags active contraction risks requiring intervention | [`sql/04_business_cases/01_revenue_decline_detection.sql`](sql/04_business_cases/01_revenue_decline_detection.sql) |

Full documentation: [`docs/metric_definitions.md`](docs/metric_definitions.md)

---

## 🏗️ Technical Architecture & Pipeline

<p align="center">
  <img src="assets/architecture.png" alt="Technical Pipeline Architecture" width="90%" />
</p>

The analytics engine processes raw extracts through a 5-stage governed workflow:
1. **Raw Ingestion:** Ingest raw CSV data into a staging environment (`sql/00_schema/01_create_tables.sql`).
2. **SQL Data Quality & Cleaning:** Execute automated integrity scripts checking for nulls, duplicates, date continuity, and zero revenue (`sql/01_data_quality/`).
3. **SQL Analytics Engine:** Compute advanced window-function metrics and business-case diagnostics (`sql/03_analysis/` & `sql/04_business_cases/`).
4. **Python Reconciliations:** Perform independent mathematical verification across 5 Jupyter Notebooks (`python/`).
5. **Dashboard Presentation Layer:** Export reconciled extracts to Tableau Desktop (`dashboard/tableau/revenue_intelligence.twbx`).

Full architecture specification: [`docs/architecture.md`](docs/architecture.md)

---

## 🗄️ SQL Analytics Pipeline

The SQL pipeline consists of 14 modular ANSI-SQL / PostgreSQL scripts structured across four functional layers:

```
sql/
├── 00_schema/
│   └── 01_create_tables.sql                      # DDL schema definition
├── 01_data_quality/
│   ├── 01_null_checks.sql                       # Verifies zero NULL values in critical keys
│   ├── 02_duplicate_checks.sql                  # Confirms uniqueness of sales_month
│   ├── 03_date_validation.sql                   # Validates monthly date continuity
│   └── 04_revenue_validation.sql                # Asserts positive revenue bounds
├── 02_cleaning/
│   └── 01_clean_monthly_revenue.sql             # Normalizes data types into clean view
├── 03_analysis/
│   ├── 01_monthly_revenue.sql                   # Monthly revenue aggregation
│   ├── 02_mom_growth.sql                        # MoM growth % using LAG()
│   ├── 03_yoy_growth.sql                        # YoY growth % using 12-month window LAG()
│   ├── 04_running_revenue.sql                   # Running cumulative revenue calculation
│   ├── 05_orders_and_aov_NOT_AVAILABLE.sql      # Formal out-of-scope metric documentation
│   └── 06_growth_diagnostics.sql                # 3-month rolling averages and variance
└── 04_business_cases/
    ├── 01_revenue_decline_detection.sql         # Gaps-and-islands decline streak analysis
    ├── 02_growth_acceleration.sql               # MoM acceleration & deceleration deltas
    ├── 03_best_worst_months.sql                 # Rank-ordered best and worst revenue periods
    └── 04_recent_performance.sql               # Last 3 months vs. prior 3 months comparison
```

---

## 🐍 Python Analytics & Reconciliations

A 5-notebook Jupyter pipeline independently executes data loading, statistical validation, exploratory analysis, growth modeling, and dashboard export:

- [`01_data_loading.ipynb`](python/01_data_loading.ipynb): Ingests raw data and verifies file encoding & schemas.
- [`02_data_validation.ipynb`](python/02_data_validation.ipynb): Reconciles row counts and date continuous bounds.
- [`03_revenue_eda.ipynb`](python/03_revenue_eda.ipynb): Conducts summary statistics, distribution analysis, and outlier detection.
- [`04_growth_analysis.ipynb`](python/04_growth_analysis.ipynb): Re-computes MoM %, YoY %, and 3-month rolling trends independently.
- [`05_export_dashboard_data.ipynb`](python/05_export_dashboard_data.ipynb): Exports finalized extract to [`data/processed/tableau_extract.csv`](data/processed/tableau_extract.csv).

---

## 🌐 Tableau Dashboard & Visual Analytics

<p align="center">
  <img src="assets/dashboard-preview.png" alt="Revenue Intelligence Tableau Dashboard Preview" width="100%" />
</p>

### Dashboard Features & Structure:
- **Executive Header:** Displays dynamic date bounds (`Oct 2016 - Aug 2018`) and core business context.
- **Top KPI Cards:**
  - **Total Revenue:** `$15,737,501`
  - **Latest Month Revenue:** `$996,974` (August 2018)
  - **Latest MoM Growth:** `-4.00%` (Color-coded red alert)
  - **Decline Streak:** `1` Month
- **Monthly Revenue Trend:** Interactive line chart mapping monthly sales against a 3-month rolling average trendline.
- **Recent Performance Comparison:** Side-by-side bar chart comparing the last 3 months (`$1,022,829` avg) against the prior 3 months (`$1,039,333` avg).
- **MoM Growth % Visual:** Categorized bar chart distinguishing Growth months (`#1f9d55`) from Decline months (`#d64545`).
- **Revenue vs. Rolling Trend:** Diagnostic chart shading periods above or below trend baseline.

<p align="center">
  <img src="assets/revenue-trend.png" alt="Monthly Revenue Trend Analysis" width="90%" />
</p>

### Tableau Deliverables:
- **Packaged Workbook:** [`dashboard/tableau/revenue_intelligence.twbx`](dashboard/tableau/revenue_intelligence.twbx) (Self-contained with data extract)
- **Unpackaged XML Workbook:** [`dashboard/tableau/revenue_intelligence.twb`](dashboard/tableau/revenue_intelligence.twb)
- **Calculated Fields Specification:** [`dashboard/tableau/calculated_fields.md`](dashboard/tableau/calculated_fields.md)
- **Dashboard Audit & QA Checklist:** [`dashboard/tableau/dashboard_audit.md`](dashboard/tableau/dashboard_audit.md)

---

## 💡 Key Business Insights

<p align="center">
  <img src="assets/insights-preview.png" alt="Key Business Insights Summary" width="90%" />
</p>

1. **Ramp-and-Plateau Structure:** Early revenue climbed rapidly from `$43,000` (Oct 2016) to `$1,027,013` (Nov 2017), stabilizing in an `$861,000–$1,061,000` monthly band through Aug 2018.
2. **Early Growth Rates Are Unrepeatable:** Initial MoM surges (+144.19% in Nov 2016, +140.95% in Dec 2016) reflect low-base scaling rather than sustainable compounding growth.
3. **Nov 2017 Spike Reversion:** The `$1,027,013` surge in Nov 2017 reverted in Dec 2017 (-24.05% MoM), indicating seasonal holiday clustering rather than a permanent baseline shift.
4. **No Sustained Contraction:** The longest consecutive monthly decline across all 23 months is **1 month**. The latest August 2018 dip (-4.00%) follows a positive July 2018 (+0.53%) and represents normal variance.
5. **Flat Recent Performance:** Last 3 months (Jun–Aug 2018) averaged `$1,022,829` vs. `$1,039,333` in the prior 3 months (Mar–May 2018)—a slight `-1.59%` variance, confirming stability.

Full analytical writeup: [`analysis/key_insights.md`](analysis/key_insights.md) · PDF Version: [`analysis/key_insights.pdf`](analysis/key_insights.pdf)

---

## 📋 Business Recommendations

1. **Adopt Rolling Trend Benchmarking:** Use a 3-month rolling average as the primary trend benchmark to filter out single-month promotional noise.
2. **Establish 2-Month Decline Alert Threshold:** Trigger executive reviews only when a decline streak reaches **2 consecutive months** (a threshold never breached in the dataset).
3. **Isolate Baseline vs. Seasonal Spikes:** Exclude Q4 holiday spikes when setting baseline budget expectations for Q1.
4. **Ingest Order-Level Data:** Priority #1 for future data platform iterations is linking order IDs and item quantities to unlock volume vs. price diagnostic capabilities.

Full recommendations document: [`analysis/business_recommendations.md`](analysis/business_recommendations.md)

---

## 📄 Reports & Presentations

| Document | Format | Description | Target Audience |
|---|---|---|---|
| **Executive Report** | [`Markdown`](reports/executive_report.md) \| [`PDF`](reports/executive_report.pdf) | Comprehensive 11-section consulting report covering methodology, findings, and risk disclosures | C-Suite / VP of Analytics |
| **Executive Presentation** | [`Markdown`](reports/presentation.md) \| [`PDF`](reports/presentation.pdf) \| [`PPTX`](reports/presentation.pptx) | High-level executive slide deck for board-level walkthroughs | Executive Stakeholders |
| **Executive Summary** | [`Markdown`](analysis/executive_summary.md) | Concise 2-page briefing summarizing key metric takeaways | Department Heads |
| **Methodology Writeup** | [`Markdown`](analysis/methodology.md) | In-depth breakdown of SQL/Python reconciliation standards | Data Engineering Leads |

---

## 📚 Documentation Suite

- [`docs/metric_definitions.md`](docs/metric_definitions.md): Comprehensive math formulas and SQL logic for all indicators.
- [`docs/data_dictionary.md`](docs/data_dictionary.md): Field-level descriptions, data types, and null constraints for raw & processed tables.
- [`docs/architecture.md`](docs/architecture.md): End-to-end technical system architecture and data lineage.
- [`docs/assumptions.md`](docs/assumptions.md): Explicit documentation of business logic choices and data boundaries.
- [`docs/data_quality.md`](docs/data_quality.md): Empirical test results covering null checks, uniqueness, and statistical variance.

---

## 🗂️ Repository Structure

```
sql-revenue-growth-dashboard/
├── README.md                                     # Main project documentation
├── LICENSE                                        # MIT License
├── requirements.txt                               # Python dependencies
├── assets/                                        # Architecture & banner visual assets
│   ├── architecture.png
│   ├── banner.png
│   ├── dashboard-preview.png
│   ├── insights-preview.png
│   └── revenue-trend.png
├── analysis/                                      # Formal analytical writeups & insights
│   ├── business_recommendations.md
│   ├── executive_summary.md
│   ├── key_insights.md
│   ├── key_insights.pdf
│   └── methodology.md
├── dashboard/                                     # Tableau workbooks & design specifications
│   ├── dashboard-preview.png
│   ├── README.md
│   └── tableau/
│       ├── calculated_fields.md
│       ├── dashboard_audit.md
│       ├── README.md
│       ├── revenue_intelligence.twb
│       └── revenue_intelligence.twbx
├── data/                                          # Raw staging and processed data extracts
│   ├── processed/
│   │   ├── monthly_revenue_processed.csv
│   │   └── tableau_extract.csv
│   ├── raw/
│   │   └── monthly_revenue_raw.csv
│   └── README.md
├── docs/                                          # Core governance and architecture specs
│   ├── architecture.md
│   ├── assumptions.md
│   ├── data_dictionary.md
│   ├── data_quality.md
│   └── metric_definitions.md
├── python/                                        # Jupyter Notebook pipeline
│   ├── 01_data_loading.ipynb
│   ├── 02_data_validation.ipynb
│   ├── 03_revenue_eda.ipynb
│   ├── 04_growth_analysis.ipynb
│   └── 05_export_dashboard_data.ipynb
├── reports/                                       # Executive reports & presentations (MD/PDF/PPTX)
│   ├── executive_report.md
│   ├── executive_report.pdf
│   ├── presentation.md
│   ├── presentation.pdf
│   └── presentation.pptx
└── sql/                                           # Production SQL code (14 scripts)
    ├── 00_schema/
    ├── 01_data_quality/
    ├── 02_cleaning/
    ├── 03_analysis/
    └── 04_business_cases/
```

---

## 🛠️ Skills Demonstrated

- **SQL Engineering:** Window functions (`LAG()`, `SUM() OVER`, `AVG() OVER`), CTEs, Gaps-and-Islands streak detection, DDL schema creation.
- **Python Data Science:** Pandas ETL, NumPy mathematical reconciliations, Matplotlib visualization, Jupyter Notebook workflows.
- **Business Intelligence:** Tableau Desktop dashboard engineering, XML schema auditing, custom palette formatting, executive layout design.
- **Data Governance & Architecture:** Pipeline lineage design, data dictionary authorship, automated data quality testing, scope gap management.
- **Executive Communication:** Technical report writing, C-suite presentation design, business recommendation frameworks.

---

## 👤 Author & License

<p align="center">
  <strong>Mohammad Ammar (Sayyed)</strong><br />
  <em>Data Analytics & Business Intelligence Consultant</em>
</p>

<p align="center">
  <a href="https://github.com/theammarngp-makes">GitHub: @theammarngp-makes</a> · 
  <a href="https://x.com/theammarngp">X: @theammarngp</a>
</p>

This repository is released under the **[MIT License](LICENSE)**.
