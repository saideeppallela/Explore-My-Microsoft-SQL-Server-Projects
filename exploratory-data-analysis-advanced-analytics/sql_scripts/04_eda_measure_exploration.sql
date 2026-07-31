-- What is the total sales amount generated?

SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- How many items were sold?
SELECT SUM(quantity	) AS total_quantity FROM gold.fact_sales

-- What is the average selling price?
SELECT avg(price) AS avg_price FROM gold.fact_sales

-- What is the total number of orders?
SELECT count(order_number) AS total_orders FROM gold.fact_sales

SELECT count(distinct order_number) AS total_orders FROM gold.fact_sales

-- What is the total number of products?
SELECT count(product_name) AS total_products FROM gold.dim_products
SELECT count(distinct product_name) AS total_products FROM gold.dim_products

-- What is the total number of customers?

SELECT count(distinct customer_key) AS total_customers FROM gold.dim_customers

-- How many customers have placed an order?

SELECT count(distinct customer_key) AS total_customers FROM gold.fact_sales

---Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' as measure_name , SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Quantity' as measure_name , SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Avg  Price' as measure_name , avg(price) FROM gold.fact_sales
UNION ALL 
SELECT'Total Nr. Orders' as measure_name ,count(distinct order_number)FROM gold.fact_sales
UNION ALL 
SELECT'Total Nr. Products ' as measure_name ,count(product_name)FROM gold.dim_products
UNION ALL 
SELECT'Total Nr. Customers ' as measure_name ,count(customer_key)FROM gold.dim_customers


