-- Day 3: order-level table (one row per order)
CREATE OR REPLACE TABLE order_level AS
WITH items AS (
  SELECT order_id,
         SUM(price) AS item_revenue,
         SUM(freight_value) AS freight,
         COUNT(*) AS n_items
  FROM order_items
  GROUP BY order_id
),
pay AS (
  SELECT order_id, SUM(payment_value) AS paid
  FROM order_payments
  GROUP BY order_id
),
rev AS (
  SELECT order_id, AVG(review_score) AS review_score
  FROM order_reviews
  GROUP BY order_id
)
SELECT o.*,
       c.customer_unique_id,
       c.customer_state,
       i.item_revenue,
       i.freight,
       i.n_items,
       p.paid,
       r.review_score
FROM orders o
LEFT JOIN customers c USING (customer_id)
LEFT JOIN items i USING (order_id)
LEFT JOIN pay p USING (order_id)
LEFT JOIN rev r USING (order_id);

-- Day 3: item-level table (one row per item sold)
CREATE OR REPLACE TABLE item_level AS
SELECT oi.*,
       p.product_category_name,
       t.product_category_name_english AS category,
       o.order_status,
       o.order_purchase_timestamp
FROM order_items oi
LEFT JOIN products p USING (product_id)
LEFT JOIN category_translation t USING (product_category_name)
LEFT JOIN orders o USING (order_id);