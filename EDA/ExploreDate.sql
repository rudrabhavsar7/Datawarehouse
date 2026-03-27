-- Find the date of the first and last order
-- How Many years of sales are available
SELECT
MIN(order_date) first_order_date,
MAX(order_date) last_order_date,
DATEDIFF(year,MIN(order_date),MAX(order_date)) AS order_range_months
FROM gold.fact_sales

--Find the youngest and the oldest customer
SELECT
MIN(birthdate) oldest_birthdate,
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
MAX(birthdate) youngest_birthdate,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers


