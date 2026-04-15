/*1.Identify the top 5 cities with the highest credit card spending and 
calculate their percentage contribution to the overall spend.*/

WITH city_spend AS (
    SELECT 
        city,
        SUM(amount) AS total_spend
    FROM credit_card_transactions
    GROUP BY city
),
overall_spend AS (
    SELECT SUM(amount) AS total_amount
    FROM credit_card_transactions
)
SELECT TOP 5
    cs.city,
    cs.total_spend,
    CAST(ROUND(cs.total_spend * 100.0 / os.total_amount, 2) AS DECIMAL(5,2)) AS percentage_contribution
FROM city_spend cs
CROSS JOIN overall_spend os
ORDER BY cs.total_spend DESC;


/* 2- write a query to print highest spend month and amount spent in that month for each card type*/

WITH monthly_spend AS (
    SELECT 
        card_type,
        FORMAT(transaction_date, 'yyyy-MM') AS year_month,
        SUM(amount) AS total_spend
    FROM credit_card_transactions
    GROUP BY 
        card_type,
        FORMAT(transaction_date, 'yyyy-MM')
),
ranked_spend AS (
    SELECT *,
           RANK() OVER (PARTITION BY card_type ORDER BY total_spend DESC) AS rank_num
    FROM monthly_spend
)
SELECT 
    card_type,
    year_month,
    total_spend
FROM ranked_spend
WHERE rank_num = 1;


--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of  1,000,000 total spends(We should have 4 rows in the o/p one for each card type)


WITH cumulative_spend AS (
    SELECT 
        *,
        SUM(amount) OVER (
            PARTITION BY card_type 
            ORDER BY transaction_date, transaction_id
        ) AS running_total
    FROM credit_card_transactions
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY card_type 
               ORDER BY running_total
           ) AS rn
    FROM cumulative_spend
    WHERE running_total >= 1000000
) t
WHERE rn = 1;

--4- write a query to find city which had lowest percentage spend for gold card type

WITH gold_city_spend AS (
    SELECT 
        city,
        SUM(amount) AS gold_spend
    FROM credit_card_transactions
    WHERE card_type = 'Gold'
    GROUP BY city
),
total_gold_spend AS (
    SELECT SUM(amount) AS total_spend
    FROM credit_card_transactions
    WHERE card_type = 'Gold'
)
SELECT TOP 1
    gcs.city,
    CAST(ROUND(gcs.gold_spend * 100.0 / tgs.total_spend, 2) AS DECIMAL(5,2)) AS percentage_contribution
FROM gold_city_spend gcs
CROSS JOIN total_gold_spend tgs
ORDER BY percentage_contribution ASC;


----5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type 
---(example format : Delhi , bills, Fuel)


WITH city_expense AS (
    SELECT 
        city,
        exp_type,
        SUM(amount) AS total_amount
    FROM credit_card_transactions
    GROUP BY city, exp_type
),
ranked_expense AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY total_amount DESC) AS rn_high,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY total_amount ASC) AS rn_low
    FROM city_expense
)
SELECT 
    city,
    MAX(CASE WHEN rn_high = 1 THEN exp_type END) AS highest_expense_type,
    MAX(CASE WHEN rn_low = 1 THEN exp_type END) AS lowest_expense_type
FROM ranked_expense
GROUP BY city;

--6- write a query to find percentage contribution of spends by females for each expense type

SELECT 
    exp_type,
    CAST(
        ROUND(
            SUM(CASE WHEN gender = 'F' THEN amount ELSE 0 END) * 100.0 
            / SUM(amount), 
        2) 
    AS DECIMAL(5,2)) AS female_percentage_contribution
FROM credit_card_transactions
GROUP BY exp_type
ORDER BY female_percentage_contribution DESC;


--7- which card and expense type combination saw highest month over month growth in Jan-2014

WITH monthly_spend AS (
    SELECT 
        card_type,
        exp_type,
        FORMAT(transaction_date, 'yyyy-MM') AS year_month,
        SUM(amount) AS total_spend
    FROM credit_card_transactions
    GROUP BY 
        card_type,
        exp_type,
        FORMAT(transaction_date, 'yyyy-MM')
),
mom_calculation AS (
    SELECT *,
           LAG(total_spend) OVER (
               PARTITION BY card_type, exp_type 
               ORDER BY year_month
           ) AS prev_month_spend
    FROM monthly_spend
)
SELECT TOP 1
    card_type,
    exp_type,
    year_month,
    total_spend,
    prev_month_spend,
    (total_spend - prev_month_spend) AS mom_growth
FROM mom_calculation
WHERE year_month = '2014-01'
  AND prev_month_spend IS NOT NULL
ORDER BY mom_growth DESC;


--8- during weekends which city has highest total spend to total no of transcations ratio 
SELECT TOP 1
    city,
    CAST(
        ROUND(
            SUM(amount) * 1.0 / COUNT(*), 
        2) 
    AS DECIMAL(10,2)) AS spend_per_transaction
FROM credit_card_transactions
WHERE DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday')
GROUP BY city
ORDER BY spend_per_transaction DESC;

--9- which city took least number of days to reach its
--500th transaction after the first transaction in that city;

WITH ranked_transactions AS (
    SELECT 
        city,
        transaction_date,
        ROW_NUMBER() OVER (
            PARTITION BY city 
            ORDER BY transaction_date, transaction_id
        ) AS rn
    FROM credit_card_transactions
),
first_500_transactions AS (
    SELECT 
        city,
        MIN(transaction_date) AS first_transaction_date,
        MAX(transaction_date) AS transaction_500_date
    FROM ranked_transactions
    WHERE rn IN (1, 500)
    GROUP BY city
    HAVING COUNT(*) = 2
)
SELECT TOP 1
    city,
    DATEDIFF(
        DAY, 
        first_transaction_date, 
        transaction_500_date
    ) AS days_to_500_transactions
FROM first_500_transactions
ORDER BY days_to_500_transactions ASC;