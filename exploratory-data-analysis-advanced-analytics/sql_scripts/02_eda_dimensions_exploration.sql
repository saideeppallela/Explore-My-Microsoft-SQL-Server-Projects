----Query 1 — Customer countries
SELECT DISTINCT country FROM gold.dim_customers

--Query 2 — Product hierarchy exploration
SELECT DISTINCT category , subcategory , product_name FROM gold.dim_products
ORDER BY 1,2,3
