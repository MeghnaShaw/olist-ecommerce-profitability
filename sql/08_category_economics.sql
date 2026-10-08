-- Day 8: unit economics by category (delivered orders, categories with 100+ orders)
CREATE OR REPLACE TABLE category_economics AS
WITH base AS (
  SELECT COALESCE(category, product_category_name, 'unknown') AS category,
         order_id, price, freight_value
  FROM item_level
  WHERE order_status = 'delivered'
),
agg AS (
  SELECT category,
         COUNT(DISTINCT order_id) AS orders,
         COUNT(*) AS items,
         ROUND(SUM(price), 2) AS revenue,
         ROUND(SUM(freight_value), 2) AS freight,
         ROUND(100.0 * SUM(freight_value) / SUM(price), 2) AS freight_pct_of_price,
         ROUND(AVG(price), 2) AS avg_price,
         ROUND(AVG(freight_value), 2) AS avg_freight
  FROM base
  GROUP BY 1
  HAVING COUNT(DISTINCT order_id) >= 100
)
SELECT *,
       ROUND(100.0 * revenue / (SELECT SUM(price) FROM base), 2) AS revenue_share_pct
FROM agg
ORDER BY revenue DESC;

-- Day 8: overall freight benchmark
CREATE OR REPLACE TABLE overall_freight AS
SELECT ROUND(SUM(price), 2) AS revenue,
       ROUND(SUM(freight_value), 2) AS freight,
       ROUND(100.0 * SUM(freight_value) / SUM(price), 2) AS freight_pct_of_price
FROM item_level
WHERE order_status = 'delivered';

-- Day 8: watch list (above-median revenue and above-average freight share)
CREATE OR REPLACE TABLE category_watchlist AS
SELECT *
FROM category_economics
WHERE freight_pct_of_price > (SELECT freight_pct_of_price FROM overall_freight)
  AND revenue >= (SELECT MEDIAN(revenue) FROM category_economics)
ORDER BY freight DESC;