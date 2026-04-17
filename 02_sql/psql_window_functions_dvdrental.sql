WITH top_customers AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
    ORDER BY total_spent DESC
    LIMIT 3
),
payment_analysis AS (
    SELECT 
        p.customer_id,
        p.payment_date,
        p.amount,
        ROW_NUMBER() OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) AS payment_number,
        SUM(p.amount) OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) AS running_total,
        p.amount - LAG(p.amount, 1, 0) OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) AS diff_from_previous,
        ROUND(AVG(p.amount) OVER (PARTITION BY p.customer_id ORDER BY p.payment_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)::numeric, 2) AS moving_avg_3,
        RANK() OVER (PARTITION BY p.customer_id ORDER BY p.amount DESC) AS amount_rank
    FROM payment p
    INNER JOIN top_customers tc ON p.customer_id = tc.customer_id
)
SELECT 
    customer_id,
    payment_number,
    payment_date,
    amount,
    running_total,
    diff_from_previous,
    moving_avg_3,
    amount_rank
FROM payment_analysis
ORDER BY customer_id, payment_number;