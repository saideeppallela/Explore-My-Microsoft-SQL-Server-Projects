
/*

Question:
Create a Customer Report that:

1. Retrieves essential customer information (such as customer name, age, and transaction details).
2. Segments customers into VIP, Regular, and New categories, and classifies them into age groups.
3. Calculates customer-level metrics including:
   - Total Orders
   - Total Sales
   - Total Quantity Purchased
   - Total Products Purchased
   - Customer Lifespan (in months)
4. Computes the following KPIs:
   - Recency (months since last order)
   - Average Order Value
   - Average Monthly Spend

*/

CREATE VIEW gold.report_customers AS
WITH base_query AS
/*
----------------------------------------------------------------------------------------
1) Base Query: Retrieves core customer and sales data for further analysis.
----------------------------------------------------------------------------------------
*/
(
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL
)
, customer_aggregation AS (
/*
----------------------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
----------------------------------------------------------------------------------------
*/
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
    customer_key,
    customer_number,
    customer_name,
    age
)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group, 
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(MONTH, last_order_date , GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    ---computate average order value (AVO)
    CASE 
        WHEN total_orders = 0 THEN 0
    ELSE total_sales/total_orders 
    END AS avg_order_value,
    ---computate average monthly spend
   CASE 
       WHEN lifespan = 0 then total_sales
       ELSE total_sales / lifespan
   END AS avg_montly_spend
FROM Customer_aggregation;

SELECT * FROM gold.report_customers