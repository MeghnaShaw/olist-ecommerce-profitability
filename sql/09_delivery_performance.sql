-- Day 9: delivery table (delivered orders with a delivery date, one row per order)
CREATE OR REPLACE TABLE delivery_orders AS
WITH d AS (
  SELECT order_id, customer_state, review_score,
         DATE_DIFF('day', CAST(order_estimated_delivery_date AS DATE),
                          CAST(order_delivered_customer_date AS DATE)) AS days_late,
         DATE_DIFF('day', CAST(order_purchase_timestamp AS DATE),
                          CAST(order_delivered_customer_date AS DATE)) AS delivery_days,
         DATE_DIFF('day', CAST(order_purchase_timestamp AS DATE),
                          CAST(order_estimated_delivery_date AS DATE)) AS estimated_days
  FROM order_level
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
)
SELECT *,
       CASE WHEN days_late > 0 THEN 'Late' ELSE 'On time' END AS delivery_status,
       CASE WHEN days_late <= 0  THEN 'On time or early'
            WHEN days_late <= 3  THEN '1-3 days late'
            WHEN days_late <= 7  THEN '4-7 days late'
            WHEN days_late <= 14 THEN '8-14 days late'
            ELSE '15+ days late' END AS lateness_band,
       CASE WHEN days_late <= 0  THEN 0
            WHEN days_late <= 3  THEN 1
            WHEN days_late <= 7  THEN 2
            WHEN days_late <= 14 THEN 3
            ELSE 4 END AS band_order
FROM d;

-- Day 9: overall delivery numbers
CREATE OR REPLACE TABLE delivery_overall AS
SELECT COUNT(*) AS delivered_orders,
       SUM(CASE WHEN days_late > 0 THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * SUM(CASE WHEN days_late > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(CASE WHEN days_late > 0 THEN days_late END), 1) AS avg_days_late_when_late,
       ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
       ROUND(AVG(estimated_days), 1) AS avg_estimated_days
FROM delivery_orders;

-- Day 9: late versus on-time reviews
CREATE OR REPLACE TABLE delivery_status_summary AS
SELECT delivery_status,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_orders,
       COUNT(review_score) AS reviewed_orders,
       ROUND(AVG(review_score), 2) AS avg_review,
       ROUND(100.0 * SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(review_score), 2) AS low_review_pct,
       ROUND(AVG(delivery_days), 1) AS avg_delivery_days
FROM delivery_orders
GROUP BY 1
ORDER BY 1;

-- Day 9: reviews by how late the order was
CREATE OR REPLACE TABLE delivery_by_band AS
SELECT lateness_band, band_order,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_review,
       ROUND(100.0 * SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(review_score), 2) AS low_review_pct
FROM delivery_orders
GROUP BY 1, 2
ORDER BY band_order;

-- Day 9: late rate by customer state (states with 100+ delivered orders)
CREATE OR REPLACE TABLE delivery_by_state AS
SELECT customer_state,
       COUNT(*) AS orders,
       SUM(CASE WHEN days_late > 0 THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * SUM(CASE WHEN days_late > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct,
       ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
       ROUND(AVG(review_score), 2) AS avg_review
FROM delivery_orders
GROUP BY 1
HAVING COUNT(*) >= 100
ORDER BY late_pct DESC;