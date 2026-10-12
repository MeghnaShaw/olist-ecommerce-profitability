-- Day 12: free-shipping threshold and freight exposure, measured from delivered orders
-- (the visitor and conversion simulation itself lives in 12_ab_test.ipynb)
CREATE OR REPLACE TABLE ab_threshold AS
WITH t AS (
  SELECT QUANTILE_CONT(item_revenue, 0.75) AS threshold
  FROM order_level
  WHERE order_status = 'delivered' AND item_revenue IS NOT NULL
)
SELECT ROUND(t.threshold, 2) AS threshold,
       COUNT(*) AS delivered_orders,
       SUM(CASE WHEN o.item_revenue >= t.threshold THEN 1 ELSE 0 END) AS eligible_orders,
       ROUND(100.0 * SUM(CASE WHEN o.item_revenue >= t.threshold THEN 1 ELSE 0 END) / COUNT(*), 2) AS eligible_pct,
       ROUND(SUM(CASE WHEN o.item_revenue >= t.threshold THEN o.freight ELSE 0 END), 2) AS freight_absorbed,
       ROUND(AVG(CASE WHEN o.item_revenue >= t.threshold THEN o.freight END), 2) AS avg_freight_eligible,
       ROUND(AVG(CASE WHEN o.item_revenue >= t.threshold THEN o.item_revenue END), 2) AS avg_value_eligible,
       ROUND(SUM(o.item_revenue), 2) AS revenue
FROM order_level o
CROSS JOIN t
WHERE o.order_status = 'delivered' AND o.item_revenue IS NOT NULL
GROUP BY t.threshold;