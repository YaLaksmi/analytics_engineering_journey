-- =============================================================================
-- НАЗВАНИЕ: Поиск рейсов с максимальным опозданием (медленный)
-- ЗАДАЧА: найти 10 рейсов с наибольшей задержкой вылета
-- ПРОБЛЕМА: многократное сканирование, отсутствие индексов
-- =============================================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    flight_id,
    route_no,
    scheduled_departure,
    actual_departure,
    EXTRACT(EPOCH FROM (actual_departure - scheduled_departure)) / 60 AS delay_minutes
FROM flights
WHERE actual_departure IS NOT NULL
    AND actual_departure > scheduled_departure
ORDER BY delay_minutes DESC
LIMIT 10;