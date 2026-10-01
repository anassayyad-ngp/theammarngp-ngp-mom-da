-- =====================================================================
-- File:     03_date_validation.sql
-- Purpose:  Validate the month sequence is continuous (no gap months)
--           and that every value falls on the first of the month.
-- Expected result on this dataset: continuous Oct-2016 -> Aug-2018,
--   23 of 23 expected months present, 0 gaps (verified in Python EDA).
-- =====================================================================

-- 1. Confirm every date is stored as the first of the month
SELECT sales_month
FROM monthly_revenue
WHERE sales_month <> DATE_TRUNC('month', sales_month);

-- 2. Gap detection: generate the full expected month series between
--    min and max, then LEFT JOIN back to find any missing months.
WITH bounds AS (
    SELECT MIN(sales_month) AS min_month, MAX(sales_month) AS max_month
    FROM monthly_revenue
),
expected_months AS (
    SELECT generate_series(min_month, max_month, INTERVAL '1 month')::date AS sales_month
    FROM bounds
)
SELECT e.sales_month AS missing_month
FROM expected_months e
LEFT JOIN monthly_revenue m ON e.sales_month = m.sales_month
WHERE m.sales_month IS NULL
ORDER BY e.sales_month;

-- 3. Confirm chronological range for documentation
SELECT
    MIN(sales_month) AS first_month,
    MAX(sales_month) AS last_month,
    COUNT(*)          AS months_present,
    (DATE_PART('year', MAX(sales_month)) - DATE_PART('year', MIN(sales_month))) * 12
      + (DATE_PART('month', MAX(sales_month)) - DATE_PART('month', MIN(sales_month))) + 1
                      AS months_expected
FROM monthly_revenue;
