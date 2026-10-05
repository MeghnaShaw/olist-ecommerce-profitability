# Business Questions

Project: Olist E-commerce Profitability and Growth
Dataset: Brazilian E-Commerce Public Dataset by Olist (about 100k orders, 2016-2018)
Note: The data has revenue and freight but no product costs, so this is a revenue and freight analysis, not true profit.

Business problem: Where is the marketplace losing revenue or customers, and which three fixes would matter most?

---

## Growth

### Q1. Is monthly revenue growing sustainably, and is the growth driven by more orders or higher order value?
- Metrics: monthly revenue, order count, average order value, month-over-month growth (complete months only)
- Decision: invest in customer acquisition or in raising basket size
- Answer: to be completed (Day 4)

### Q2. At which stage of the order lifecycle are orders lost, and what is the cancellation rate?
- Metrics: share of orders reaching each stage (created, approved, shipped, delivered); cancellation rate
- Decision: where operations should focus to protect revenue
- Answer: to be completed (Day 5)

---

## Customers

### Q3. What share of customers place a second order, and how does retention differ across cohorts?
- Metrics: repeat purchase rate; monthly cohort retention (using customer_unique_id)
- Decision: whether growth depends on acquisition or loyalty
- Answer: to be completed (Day 6)
- Note (Day 2): 99,441 customer_ids but only 96,096 customer_unique_ids, so some customers ordered more than once.

---

## Unit Economics

### Q4. Which product categories carry the highest freight cost relative to item price, and how much revenue do they represent?
- Metrics: freight as a share of item price by category; category revenue
- Decision: which categories need shipping-cost, pricing or seller changes
- Answer: to be completed (Day 8)

---

## Operations and Customer Experience

### Q5. How often are orders delivered later than the estimated date, and in which regions is this worst?
- Metrics: late delivery rate overall and by customer state; average days late
- Decision: where to improve logistics or set more realistic delivery promises
- Answer: to be completed (Day 9)

### Q6. How much does late delivery reduce review scores?
- Metrics: average review score and share of 1-2 star reviews, late versus on-time orders
- Decision: how much customer satisfaction is worth fixing through delivery
- Answer: to be completed (Day 9)

---

## Sellers

### Q7. How concentrated is revenue among sellers?
- Metrics: revenue share of the top 10% of sellers; revenue share of the top 10 sellers
- Decision: seller retention and dependency risk
- Answer: to be completed (Day 10)

### Q8. Which sellers with meaningful volume have the worst late-delivery and low-review rates?
- Metrics: per-seller late rate and 1-2 star rate (sellers with 30+ orders only)
- Decision: seller quality policy: warnings, coaching or removal
- Answer: to be completed (Day 10)

---

## Definitions

- Revenue: sum of item price for orders with order_status = 'delivered' (excludes freight and cancelled orders)
- Complete months: months with normal order volume; partial months at the start and end are excluded
- Late delivery: actual delivery date is later than the estimated delivery date
- Customer: identified by customer_unique_id, not customer_id