-- Day 5: order lifecycle funnel (all orders)
CREATE OR REPLACE TABLE funnel AS
WITH counts AS (
  SELECT 1 AS step, 'Created' AS stage, COUNT(*) AS orders FROM orders
  UNION ALL
  SELECT 2, 'Approved', COUNT(order_approved_at) FROM orders
  UNION ALL
  SELECT 3, 'Shipped (handed to carrier)', COUNT(order_delivered_carrier_date) FROM orders
  UNION ALL
  SELECT 4, 'Delivered to customer', COUNT(order_delivered_customer_date) FROM orders
)
SELECT step, stage, orders,
       ROUND(100.0 * orders / FIRST_VALUE(orders) OVER (ORDER BY step), 2) AS pct_of_created,
       ROUND(100.0 * orders / LAG(orders) OVER (ORDER BY step), 2) AS pct_of_previous
FROM counts
ORDER BY step;

-- Day 5: order status breakdown
CREATE OR REPLACE TABLE order_status_summary AS
SELECT order_status,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_orders
FROM orders
GROUP BY 1
ORDER BY orders DESC;