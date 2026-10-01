-- =====================================================================
-- File:     01_monthly_revenue.sql
-- Purpose:  Base monthly revenue series -- the foundation every other
--           analysis query builds on.
-- =====================================================================

SELECT
    sales_month,
    current_month_revenue
FROM vw_clean_monthly_revenue
ORDER BY sales_month;
