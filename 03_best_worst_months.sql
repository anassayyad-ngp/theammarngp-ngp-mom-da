-- =====================================================================
-- File:     03_best_worst_months.sql
-- Purpose:  Identify the highest/lowest revenue months and the
--           highest/lowest MoM growth months, ranked with RANK()
--           rather than a hardcoded TOP-N filter.
--
-- Note: the very first month (Oct-2016) is deliberately excluded from
-- the growth ranking, since it has no mom_growth_pct (no prior month
-- to compare against) -- see sql/03_analysis/02_mom_growth.sql.
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
ranked AS (
    SELECT
        *,
        RANK() OVER (ORDER BY current_month_revenue DESC) AS revenue_rank_desc,
        RANK() OVER (ORDER BY current_month_revenue ASC)  AS revenue_rank_asc,
        RANK() OVER (ORDER BY mom_growth_pct DESC NULLS LAST) AS growth_rank_desc,
        RANK() OVER (ORDER BY mom_growth_pct ASC NULLS LAST)  AS growth_rank_asc
    FROM mom
)
SELECT sales_month, current_month_revenue, mom_growth_pct,
       revenue_rank_desc, revenue_rank_asc, growth_rank_desc, growth_rank_asc
FROM ranked
WHERE revenue_rank_desc = 1   -- highest revenue month
   OR revenue_rank_asc = 1    -- lowest revenue month
   OR growth_rank_desc = 1    -- best MoM growth month
   OR growth_rank_asc = 1     -- worst MoM growth month
ORDER BY sales_month;
