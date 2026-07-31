/*1.Analyze the yearly performance of products by comparing each product's sales 
to both its average sales performance and the previous year's sales.*/


WITH yearly_sales AS
(
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER(PARTITION BY product_name) AS average_sales,
    current_sales-AVG(current_sales) OVER(PARTITION BY product_name) AS average_difference,
    CASE
        WHEN current_sales>AVG(current_sales) OVER(PARTITION BY product_name) THEN 'Above Avg'
        WHEN current_sales<AVG(current_sales) OVER(PARTITION BY product_name) THEN 'Below Avg'
        ELSE 'Average'
    END AS average_status,
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
    current_sales-LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS year_over_year_difference,
    CASE
        WHEN current_sales>LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
        WHEN current_sales<LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
        ELSE 'No Change'
    END AS year_over_year_status
FROM yearly_sales
ORDER BY product_name, order_year;
