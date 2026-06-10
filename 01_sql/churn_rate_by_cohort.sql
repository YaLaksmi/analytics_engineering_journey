-- =============================================================================
-- НАЗВАНИЕ: Churn Rate по когортам
-- АВТОР: Курзыбова Яна
-- ЗАДАЧА: рассчитать отток клиентов по месяцам жизни когорты
-- =============================================================================

WITH 
-- нормализуем месяцы платежей
payment_months AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', payment_date)::timestamp AS payment_month
    FROM payment
),

-- когорта = месяц первого платежа
cohorts AS (
    SELECT 
        customer_id,
        MIN(payment_month) AS cohort_month
    FROM payment_months
    GROUP BY customer_id
),

-- последний платёж каждого клиента
last_payments AS (
    SELECT 
        customer_id,
        MAX(payment_month) AS last_payment_month
    FROM payment_months
    GROUP BY customer_id
),

-- объединяем когорту и последний платёж
cohort_churn AS (
    SELECT 
        c.customer_id,
        c.cohort_month,
        lp.last_payment_month,
        (EXTRACT(YEAR FROM AGE(lp.last_payment_month, c.cohort_month)) * 12)
        + EXTRACT(MONTH FROM AGE(lp.last_payment_month, c.cohort_month)) AS churn_month_live_time
    FROM cohorts c
    JOIN last_payments lp ON c.customer_id = lp.customer_id
),

-- считаем ушедших по когортам и месяцам
churn_stats AS (
    SELECT 
        cohort_month,
        churn_month_live_time,
        COUNT(customer_id) AS churned_customers
    FROM cohort_churn
    WHERE churn_month_live_time IS NOT NULL
    GROUP BY cohort_month, churn_month_live_time
),

-- размер когорт
cohort_size AS (
    SELECT 
        cohort_month,
        COUNT(customer_id) AS total_customers
    FROM cohorts
    GROUP BY cohort_month
)

-- финальный результат
SELECT 
    cs.cohort_month,
    cs.total_customers,
    cstats.churn_month_live_time AS month_live_time,
    cstats.churned_customers,
    ROUND(100.0 * cstats.churned_customers / cs.total_customers, 2) AS churn_rate_percent
FROM churn_stats cstats
JOIN cohort_size cs ON cstats.cohort_month = cs.cohort_month
ORDER BY cs.cohort_month, cstats.churn_month_live_time;