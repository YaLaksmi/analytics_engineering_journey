-- =============================================================================
-- НАЗВАНИЕ: RFM-сегментация клиентов
-- АВТОР: Курзыбова Яна
-- ЗАДАЧА: разделить клиентов на сегменты по Recency, Frequency, Monetary
-- =============================================================================

WITH 
customer_rfm AS (
    SELECT 
        customer_id,
        -- Recency: сколько дней прошло с последнего платежа
        EXTRACT(DAY FROM (CURRENT_DATE - MAX(payment_date))) AS recency_days,
        -- Frequency: количество платежей
        COUNT(payment_id) AS frequency,
        -- Monetary: общая сумма
        SUM(amount) AS monetary
    FROM payment
    GROUP BY customer_id
),

rfm_scores AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary,
        -- NTILE(5) разбивает на 5 групп: 5 — лучшие, 1 — худшие
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_rfm
),

rfm_segments AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary,
        recency_score,
        frequency_score,
        monetary_score,
        (recency_score + frequency_score + monetary_score) AS rfm_total,
        CONCAT(recency_score, frequency_score, monetary_score) AS rfm_cell,
        CASE 
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions (чемпионы)'
            WHEN recency_score >= 4 AND frequency_score >= 3 THEN 'Loyal (лояльные)'
            WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Potential (потенциальные)'
            WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'At Risk (риск оттока)'
            WHEN recency_score = 1 AND frequency_score <= 2 THEN 'Churned (ушедшие)'
            WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New (новые)'
            ELSE 'Regular (обычные)'
        END AS segment
    FROM rfm_scores
)

SELECT 
    segment,
    COUNT(customer_id) AS customers_count,
    ROUND(100.0 * COUNT(customer_id) / SUM(COUNT(customer_id)) OVER (), 2) AS percent_of_total,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM rfm_segments
GROUP BY segment
ORDER BY avg_monetary DESC;