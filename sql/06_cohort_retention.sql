-- Day 6: overall repeat-purchase rate (delivered orders, by customer_unique_id)
CREATE OR REPLACE TABLE repeat_summary AS
WITH per_customer AS (
  SELECT customer_unique_id, COUNT(*) AS n_orders
  FROM order_level
  WHERE order_status = 'delivered'
  GROUP BY 1
)
SELECT COUNT(*) AS customers,
       SUM(CASE WHEN n_orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN n_orders >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_pct,
       ROUND(AVG(n_orders), 3) AS avg_orders_per_customer
FROM per_customer;

-- Day 6: monthly cohort retention (cohorts Jan 2017 to Aug 2018)
CREATE OR REPLACE TABLE cohort_retention AS
WITH delivered AS (
  SELECT customer_unique_id,
         DATE_TRUNC('month', order_purchase_timestamp) AS order_month
  FROM order_level
  WHERE order_status = 'delivered'
),
first_order AS (
  SELECT customer_unique_id, MIN(order_month) AS cohort_month
  FROM delivered
  GROUP BY 1
),
activity AS (
  SELECT DISTINCT customer_unique_id, order_month
  FROM delivered
),
counts AS (
  SELECT f.cohort_month,
         DATE_DIFF('month', f.cohort_month, a.order_month) AS months_since,
         COUNT(DISTINCT a.customer_unique_id) AS customers
  FROM first_order f
  JOIN activity a USING (customer_unique_id)
  GROUP BY 1, 2
),
sizes AS (
  SELECT cohort_month, customers AS cohort_size
  FROM counts
  WHERE months_since = 0
),
grid AS (
  SELECT s.cohort_month, s.cohort_size, m.months_since
  FROM sizes s
  CROSS JOIN (SELECT UNNEST(range(0, 20)) AS months_since) m
  WHERE s.cohort_month BETWEEN DATE '2017-01-01' AND DATE '2018-08-01'
    AND m.months_since <= DATE_DIFF('month', s.cohort_month, DATE '2018-08-01')
)
SELECT g.cohort_month,
       g.months_since,
       COALESCE(c.customers, 0) AS customers,
       g.cohort_size,
       ROUND(100.0 * COALESCE(c.customers, 0) / g.cohort_size, 2) AS retention_pct
FROM grid g
LEFT JOIN counts c
  ON c.cohort_month = g.cohort_month AND c.months_since = g.months_since
ORDER BY 1, 2;

-- Day 6: average retention by months since first order
CREATE OR REPLACE TABLE avg_retention AS
SELECT months_since,
       SUM(customers) AS customers,
       SUM(cohort_size) AS cohort_size_total,
       ROUND(100.0 * SUM(customers) / SUM(cohort_size), 2) AS retention_pct
FROM cohort_retention
WHERE months_since <= 6
GROUP BY 1
ORDER BY 1;