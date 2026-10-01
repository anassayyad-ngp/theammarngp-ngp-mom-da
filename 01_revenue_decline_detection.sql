-- =====================================================================
-- File:     01_revenue_decline_detection.sql
-- Purpose:  Flag every month where revenue declined vs. the prior
--           month, and measure how many consecutive months of
--           decline preceded it (a streak, not just a single flag).
--
-- Business use: a single red month can be noise. A streak of 2+ is
-- what should trigger a management review.
-- =====================================================================

WITH mom AS (
    SELECT
        sales_month,
        current_month_revenue,
        ROUND(
            (current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY sales_month))
            / NULLIF(LAG(current_month_revenue) OVER (ORDER BY sales_month), 0) * 100.0,
            2
        ) AS mom_growth_pct
    FROM vw_clean_monthly_revenue
),
flagged AS (
    SELECT
        *,
        CASE WHEN mom_growth_pct < 0 THEN 1 ELSE 0 END AS is_decline
    FROM mom
),
-- group consecutive decline months using the "gaps and islands" technique:
-- subtracting a running row number from a running count of decline months
-- gives a constant value for each unbroken streak.
grouped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY sales_month)
          - SUM(is_decline) OVER (ORDER BY sales_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
          AS streak_group
    FROM flagged
)
SELECT
    sales_month,
    current_month_revenue,
    mom_growth_pct,
    is_decline,
    CASE WHEN is_decline = 1
         THEN COUNT(*) FILTER (WHERE is_decline = 1) OVER (PARTITION BY streak_group ORDER BY sales_month)
         ELSE 0
    END AS consecutive_decline_months
FROM grouped
ORDER BY sales_month;
