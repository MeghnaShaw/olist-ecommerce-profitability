# olist-ecommerce-profitability
## Data

- Dataset: Brazilian E-Commerce Public Dataset by Olist
- Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- Licence: CC BY-NC-SA 4.0
- The raw CSV files are not included in this repo. Download them from Kaggle and place them in the `data/` folder.
## Definitions
- Revenue: sum of item price for orders with order_status = 'delivered' (excludes freight and cancelled orders).
- Customer: identified by customer_unique_id, not customer_id.

## Data checks (Day 3)
- order_level has 99,441 rows, equal to the orders table, with one row per order.
- item_level has 112,650 rows, equal to order_items.
- Total item revenue matches the source in all three tables: 13,591,643.70.
- Total freight matches the source: 2,251,909.54.
- Orders and items are aggregated before joining to avoid double-counting (fan-out).
- Some orders have no items (775), no review (768) or no delivery date (2,965). These are expected and are handled in later analysis.
## Method
- Monthly analysis uses complete months only (Jan 2017 to Aug 2018). Late 2016 and the final months of 2018 are excluded because volumes are too small or cut off.
- The order funnel uses order timestamps (created, approved, shipped, delivered) because Olist has no web clickstream. It covers all orders in the dataset.
- Customers are identified by customer_unique_id, not customer_id, because customer_id changes with every order. Cohort retention uses delivered orders and cohorts from Jan 2017 to Aug 2018, where a cohort is the month of a customer's first delivered order. Repeat orders placed in the same month as the first order count as month 0, not as retention.
- Category economics use delivered orders only and categories with at least 100 delivered orders. Freight share of price = total freight / total item price per category. Categories without an English translation use their Portuguese name, and items with no category are labelled 'unknown'. The data has no product costs, so this shows where shipping weighs on customers, not true profit.
- Delivery analysis uses delivered orders that have a recorded delivery date. An order is late if its delivery date (date only, not time) is after the estimated delivery date; delivery on the estimated day counts as on time. State rankings use states with at least 100 delivered orders. Review comparisons show association, not proof of cause.
