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
- Answer: Between Jan 2017 and Aug 2018, monthly revenue grew from 111,798 to 838,577 and monthly orders from 750 to 6,351. Comparing the first 3 and last 3 complete months, orders rose 276.0% while average order value changed -4.3%, so growth came from more orders, not larger baskets. Year-over-year (Jan-Aug 2018 vs Jan-Aug 2017), revenue rose 141.1% and orders rose 139.9%. During Jan-Aug 2018 monthly revenue stayed between 826,437 and 977,545, so growth flattened. The peak month was Nov 2017 (987,765), likely a seasonal effect such as Black Friday.

### Q2. At which stage of the order lifecycle are orders lost, and what is the cancellation rate?
- Metrics: share of orders reaching each stage (created, approved, shipped, delivered); cancellation rate
- Decision: where operations should focus to protect revenue
- Answer: Of 99,441 orders, 99.84% were approved, 98.21% were handed to the carrier and 97.02% reached the customer. The largest step-to-step drop is from Approved to Shipped (handed to carrier) (1.63% of orders lost at that step). 625 orders were cancelled (0.63%) and 609 were marked unavailable (0.61%). 97.02% of orders have the status delivered; the rest are cancelled, unavailable or still in progress when the data was collected.

---

## Customers

### Q3. What share of customers place a second order, and how does retention differ across cohorts?
- Metrics: repeat purchase rate; monthly cohort retention (using customer_unique_id)
- Decision: whether growth depends on acquisition or loyalty
- Answer: Of 93,358 customers with a delivered order, 2,801 (3.0%) ordered more than once, with an average of 1.033 orders per customer. Averaged across the Jan 2017 to Aug 2018 cohorts, 0.48% of customers bought again one month after their first order, 0.26% after three months and 0.23% after six months. Repeat purchase is very low, so growth depends on acquiring new customers rather than on loyalty. Later cohorts have fewer months of history, so their retention can only be measured over a shorter period.
- Note (Day 2): 99,441 customer_ids but only 96,096 customer_unique_ids, so some customers ordered more than once.

---

## Unit Economics

### Q4. Which product categories carry the highest freight cost relative to item price, and how much revenue do they represent?
- Metrics: freight as a share of item price by category; category revenue
- Decision: which categories need shipping-cost, pricing or seller changes
- Answer: Across delivered orders, freight equals 16.63% of item price overall. Among the 52 categories with at least 100 delivered orders, the highest freight shares are christmas_supplies (36.52% of price, average item price 58.25), signaling_and_security (30.39% of price, average item price 108.2), electronics (29.46% of price, average item price 56.81). The three largest categories by revenue are health_beauty (9.33% of revenue, freight 14.51% of price), watches_gifts (8.82% of revenue, freight 8.42% of price), bed_bath_table (7.74% of revenue, freight 19.72% of price). 12 categories are both above-median in revenue and above the marketplace freight share; the largest by total freight are bed_bath_table (revenue 1,023,435, freight 19.72% of price), furniture_decor (revenue 711,928, freight 23.65% of price), sports_leisure (revenue 954,853, freight 17.11% of price). These categories are candidates for shipping-cost, pricing or seller changes.

---

## Operations and Customer Experience

### Q5. How often are orders delivered later than the estimated date, and in which regions is this worst?
- Metrics: late delivery rate overall and by customer state; average days late
- Decision: where to improve logistics or set more realistic delivery promises
- Answer: Of 96,470 delivered orders with a delivery date, 6,534 (6.77%) arrived after the estimated date, and late orders were on average 10.6 days late. Orders took 12.5 days on average against 24.4 days estimated. Among states with at least 100 delivered orders, the highest late rates are AL (21.41%), MA (17.43%), SE (15.22%); the lowest is AM (2.76%).


### Q6. How much does late delivery reduce review scores?
- Metrics: average review score and share of 1-2 star reviews, late versus on-time orders
- Decision: how much customer satisfaction is worth fixing through delivery
- Answer: Late orders average a review score of 2.27 against 4.29 for on-time orders, a gap of 2.02 points, and 62.36% of late orders have a 1-2 star review against 9.23% of on-time orders. Orders delivered 15+ days late average 1.73. This shows a strong association between lateness and low reviews; it does not prove that lateness alone causes them.


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