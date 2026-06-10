-- =============================================================================
-- НАЗВАНИЕ: Conversion to Repeat Purchase (конверсия в повторную аренду)
-- АВТОР: Курзыбова Яна
-- ЗАДАЧА: определить, какой процент клиентов делает 2, 3, 4+ аренд
-- =============================================================================

WITH 
customer_rentals AS (
    SELECT 
        customer_id,
        COUNT(rental_id) AS total_rentals,
        COUNT(DISTINCT DATE_TRUNC('month', rental_date)) AS active_months
    FROM rental
    GROUP BY customer_id
),

conversion_stats AS (
    SELECT 
        total_rentals,
        COUNT(customer_id) AS customers_count,
        SUM(COUNT(customer_id)) OVER () AS total_customers
    FROM customer_rentals
    GROUP BY total_rentals
)

SELECT 
    total_rentals,
    customers_count,
    ROUND(100.0 * customers_count / total_customers, 2) AS conversion_rate,
    CASE 
        WHEN total_rentals = 1 THEN '1 аренда'
        WHEN total_rentals = 2 THEN '2 аренды (повторные)'
        WHEN total_rentals BETWEEN 3 AND 5 THEN '3-5 аренд (регулярные)'
        ELSE '6+ аренд (супер-клиенты)'
    END AS customer_type
FROM conversion_stats
ORDER BY total_rentals;