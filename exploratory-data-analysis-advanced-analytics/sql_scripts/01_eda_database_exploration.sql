SELECT *
FROM INFORMATION_SCHEMA.TABLES

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

SELECT 
  TABLE_SCHEMA, 
  TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'gold';

SELECT 'fact_sales' AS table_name, COUNT(*) AS total_records FROM gold.fact_sales 
UNION ALL 
SELECT 'dim_customers', COUNT(*) FROM gold.dim_customers 
UNION ALL 
SELECT 'dim_products', COUNT(*) FROM gold.dim_products;


SELECT * FROM gold.fact_sales 
WHERE order_number IS NULL 
OR order_date IS NULL 
OR sales_amount IS NULL;

SELECT 
MIN(order_date) AS start_date, 
MAX(order_date) AS end_date 
FROM gold.fact_sales;
