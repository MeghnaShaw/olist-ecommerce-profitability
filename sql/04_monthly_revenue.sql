-- Day 4: monthly revenue, orders, AOV and growth (complete months only)
CREATE OR REPLACE TABLE monthly_summary AS
WITH monthly AS (
  SELECT DATE_TRUNC('month', order_purchase_timestamp) AS month,
         COUNT(*) AS orders,
         ROUND(SUM(item_revenue), 2) AS revenue,
         ROUND(SUM(item_revenue) / COUNT(*), 2) AS aov
  FROM order_level
  WHERE order_status = 'delivered'
    AND item_revenue IS NOT NULL
  GROUP BY 1
),
complete AS (
  SELECT * FROM monthly
  WHERE month BETWEEN DATE '2017-01-01' AND DATE '2018-08-01'
)
SELECT month, orders, revenue, aov,
       ROUND(100 * (revenue / LAG(revenue) OVER (ORDER BY month) - 1), 1) AS revenue_mom_pct,
       ROUND(100 * (orders  / LAG(orders)  OVER (ORDER BY month) - 1), 1) AS orders_mom_pct,
       ROUND(100 * (aov     / LAG(aov)     OVER (ORDER BY month) - 1), 1) AS aov_mom_pct
FROM complete
ORDER BY month;