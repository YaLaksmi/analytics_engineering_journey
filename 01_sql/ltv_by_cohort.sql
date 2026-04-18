-- =============================================================================
-- НАЗВАНИЕ: LTV по когортам (Lifetime Value)
-- АВТОР: Курзыбова Яна
-- ЗАДАЧА: рассчитать среднюю выручку на клиента для каждой когорты
-- =============================================================================

WITH 
payment_months AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', payment_date)::timestamp AS payment_month,
        amount
    FROM payment
),

cohorts AS (
    SELECT 
        customer_id,
        MIN(payment_month) AS cohort_month
    FROM payment_months
    GROUP BY customer_id
),

customer_ltv AS (
    SELECT 
        c.customer_id,
        c.cohort_month,
        SUM(p.amount) AS ltv
    FROM cohorts c
    JOIN payment_months p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.cohort_month
)

SELECT 
    cohort_month,
    COUNT(customer_id) AS cohort_size,
    ROUND(SUM(ltv), 2) AS total_revenue,
    ROUND(AVG(ltv), 2) AS avg_ltv,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ltv), 2) AS median_ltv
FROM customer_ltv
GROUP BY cohort_month
ORDER BY cohort_month;