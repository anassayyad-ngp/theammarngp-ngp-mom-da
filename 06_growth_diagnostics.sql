-- =====================================================================
-- File:     06_growth_diagnostics.sql
-- Purpose:  Classify each month's growth behavior and detect
--           consecutive-direction streaks, using only revenue data
--           (order-volume/AOV decomposition is out of scope -- see
--           05_orders_and_aov_NOT_AVAILABLE.sql).
--
-- Diagnostic tree actually supported by this data:
--
--   Revenue Change
--     |
--     +-- Direction (up / down / flat)
--     +-- Magnitude (mom_growth_pct)
--     +-- Consecutive-month streak in the same direction
--     +-- Position vs. 3-month rolling average (noise vs. trend)
--
-- Wording used throughout: "revenue increased/decreased" -- never
-- "driven by order volume" or "driven by AOV", since that would
-- require data this project does not have.
-- =====================================================================

WITH growth AS (
    SELECT
        sales_month,
        current_month_revenue,
        ROUND(
            (current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY sales_month))
            / NULLIF(LAG(current_month_revenue) OVER (ORDER BY sales_month), 0) * 100.0,
            2
        ) AS mom_growth_pct,
        ROUND(AVG(current_month_revenue) OVER (
            ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2) AS rolling_3m_avg
    FROM vw_clean_monthly_revenue
),
classified AS (
    SELECT
        *,
        CASE
            WHEN mom_growth_pct IS NULL THEN 'no_prior_month'
            WHEN mom_growth_pct > 0    THEN 'increase'
            WHEN mom_growth_pct < 0    THEN 'decrease'
            ELSE 'flat'
        END AS direction,
        CASE
            WHEN mom_growth_pct IS NULL THEN NULL
            WHEN current_month_revenue > rolling_3m_avg THEN 'above_trend'
            WHEN current_month_revenue < rolling_3m_avg THEN 'below_trend'
            ELSE 'on_trend'
        END AS vs_rolling_trend
    FROM growth
)
SELECT
    sales_month,
    current_month_revenue,
    mom_growth_pct,
    direction,
    rolling_3m_avg,
    vs_rolling_trend
FROM classified
ORDER BY sales_month;
