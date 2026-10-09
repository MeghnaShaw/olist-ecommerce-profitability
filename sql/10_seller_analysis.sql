-- Day 10: seller revenue ranking (delivered orders), Pareto columns included
CREATE OR REPLACE TABLE seller_revenue AS
WITH s AS (
  SELECT seller_id,
         COUNT(DISTINCT order_id) AS orders,
         ROUND(SUM(price), 2) AS revenue
  FROM item_level
  WHERE order_status = 'delivered'
  GROUP BY 1
),
r AS (
  SELECT *,
         ROW_NUMBER() OVER (ORDER BY revenue DESC, seller_id) AS rnk,
         COUNT(*) OVER () AS total_sellers,
         SUM(revenue) OVER () AS total_revenue,
         SUM(revenue) OVER (ORDER BY revenue DESC, seller_id
                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue
  FROM s
)
SELECT seller_id, orders, revenue, rnk, total_sellers,
       ROUND(total_revenue, 2) AS total_revenue,
       ROUND(100.0 * rnk / total_sellers, 2) AS pct_sellers,
       ROUND(100.0 * revenue / total_revenue, 3) AS revenue_share_pct,
       ROUND(100.0 * cum_revenue / total_revenue, 2) AS cum_revenue_pct
FROM r
ORDER BY rnk;

-- Day 10: concentration summary
CREATE OR REPLACE TABLE seller_concentration AS
SELECT MAX(total_sellers) AS sellers,
       MAX(total_revenue) AS total_revenue,
       MAX(CASE WHEN rnk <= 10 THEN cum_revenue_pct END) AS top10_sellers_revenue_pct,
       CAST(CEIL(0.10 * MAX(total_sellers)) AS INTEGER) AS top10pct_seller_count,
       MAX(CASE WHEN rnk <= CEIL(0.10 * total_sellers) THEN cum_revenue_pct END) AS top10pct_revenue_pct,
       MAX(CASE WHEN rnk <= CEIL(0.20 * total_sellers) THEN cum_revenue_pct END) AS top20pct_revenue_pct,
       MIN(CASE WHEN cum_revenue_pct >= 80 THEN rnk END) AS sellers_for_80pct,
       ROUND(100.0 * MIN(CASE WHEN cum_revenue_pct >= 80 THEN rnk END) / MAX(total_sellers), 2) AS sellers_for_80pct_share
FROM seller_revenue;

-- Day 10: marketplace benchmark (needs delivery_orders from Day 9)
CREATE OR REPLACE TABLE seller_benchmark AS
SELECT COUNT(*) AS delivered_orders,
       ROUND(100.0 * SUM(CASE WHEN days_late > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct,
       ROUND(100.0 * SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(review_score), 2) AS low_review_pct,
       ROUND(AVG(review_score), 2) AS avg_review
FROM delivery_orders;

-- Day 10: seller quality (sellers with 30+ delivered orders)
CREATE OR REPLACE TABLE seller_quality AS
WITH so AS (
  SELECT DISTINCT seller_id, order_id
  FROM item_level
  WHERE order_status = 'delivered'
),
j AS (
  SELECT so.seller_id, d.order_id, d.days_late, d.review_score
  FROM so
  JOIN delivery_orders d USING (order_id)
),
q AS (
  SELECT seller_id,
         COUNT(*) AS orders,
         SUM(CASE WHEN days_late > 0 THEN 1 ELSE 0 END) AS late_orders,
         ROUND(100.0 * SUM(CASE WHEN days_late > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct,
         COUNT(review_score) AS reviewed_orders,
         ROUND(AVG(review_score), 2) AS avg_review,
         ROUND(100.0 * SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(review_score), 2) AS low_review_pct
  FROM j
  GROUP BY 1
  HAVING COUNT(*) >= 30
)
SELECT q.*,
       r.revenue,
       r.revenue_share_pct,
       COALESCE(q.late_pct > b.late_pct AND q.low_review_pct >= 2 * b.low_review_pct, FALSE) AS flagged
FROM q
LEFT JOIN seller_revenue r USING (seller_id)
CROSS JOIN seller_benchmark b
ORDER BY q.low_review_pct DESC;

-- Day 10: what the flagged sellers represent
CREATE OR REPLACE TABLE seller_impact AS
WITH f AS (
  SELECT seller_id FROM seller_quality WHERE flagged
),
fo AS (
  SELECT DISTINCT i.order_id
  FROM item_level i
  JOIN f USING (seller_id)
  WHERE i.order_status = 'delivered'
)
SELECT (SELECT COUNT(*) FROM f) AS flagged_sellers,
       (SELECT COUNT(*) FROM seller_quality) AS sellers_30plus,
       COALESCE((SELECT ROUND(SUM(revenue_share_pct), 2) FROM seller_quality WHERE flagged), 0) AS flagged_revenue_share_pct,
       (SELECT COUNT(*) FROM delivery_orders d JOIN fo USING (order_id) WHERE d.days_late > 0) AS flagged_late_orders,
       (SELECT COUNT(*) FROM delivery_orders WHERE days_late > 0) AS all_late_orders,
       (SELECT COUNT(*) FROM delivery_orders d JOIN fo USING (order_id) WHERE d.review_score <= 2) AS flagged_low_orders,
       (SELECT COUNT(*) FROM delivery_orders WHERE review_score <= 2) AS all_low_orders;
       