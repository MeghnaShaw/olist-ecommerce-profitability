-- Day 11: baseline for the metric tree (delivered orders)
CREATE OR REPLACE TABLE baseline AS
SELECT COUNT(DISTINCT customer_unique_id) AS customers,
       COUNT(*) AS orders,
       1.0 * COUNT(*) / COUNT(DISTINCT customer_unique_id) AS orders_per_customer,
       SUM(item_revenue) AS revenue,
       SUM(item_revenue) / COUNT(*) AS aov
FROM order_level
WHERE order_status = 'delivered' AND item_revenue IS NOT NULL;

-- Day 11: does a late first order reduce repeat purchase? (needs delivery_orders from Day 9)
CREATE OR REPLACE TABLE first_order_repeat AS
WITH o AS (
  SELECT customer_unique_id, order_id,
         ROW_NUMBER() OVER (PARTITION BY customer_unique_id
                            ORDER BY order_purchase_timestamp, order_id) AS rn,
         COUNT(*) OVER (PARTITION BY customer_unique_id) AS n_orders
  FROM order_level
  WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
),
f AS (
  SELECT o.customer_unique_id, o.n_orders, d.delivery_status
  FROM o
  JOIN delivery_orders d USING (order_id)
  WHERE o.rn = 1
)
SELECT delivery_status,
       COUNT(*) AS customers,
       SUM(CASE WHEN n_orders >= 2 THEN 1 ELSE 0 END) AS repeaters,
       ROUND(100.0 * SUM(CASE WHEN n_orders >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_pct
FROM f
GROUP BY 1
ORDER BY 1;