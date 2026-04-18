# SQL портфолио

Все запросы написаны для базы `dvdrental` (PostgreSQL).

## Когортный анализ удержания (3 подхода)
| Файл | Описание | Ключевые теги |
|------|----------|----------------|
| `cohort_retention_by_registration.sql` | Когорты по дате регистрации | #оконные_функции #CTE #маркетинг |
| `cohort_retention_by_first_payment.sql` | Когорты по первому платежу | #оконные_функции #CTE #монетизация |
| `cohort_retention_comparison.sql` | Сравнение двух подходов | #анализ #конверсия |

## Остальные запросы
| Файл | Описание | Ключевые теги |
|------|----------|----------------|
| `ltv_by_cohort.sql` | LTV по когортам | #агрегации #перцентили |
| `churn_rate.sql` | Отток клиентов | #подзапросы |
| `arpu_trend.sql` | ARPU + скользящее среднее | #временные_ряды |
| `top_clients_running_total.sql` | Топ-10 клиентов с накопительным итогом | #running_total |
| `funnel_analysis.sql` | Конверсионная воронка | #воронка |
| `rfm_segmentation.sql` | RFM-сегментация | #сегментация |
| `late_returns_financial_impact.sql` | Финансовые потери от просрочек | #финансы |
| `query_optimization_demo.sql` | EXPLAIN ANALYZE + индексы | #оптимизация |
| `product_mart.sql` | Витрина данных | #витрина |