-- =============================================================================
-- НАЗВАНИЕ: Поиск окон для профилактики (для всех рейсов)
-- ЗАДАЧА: найти окна > 6 часов между последовательными рейсами
-- РЕШЕНИЕ: оконная функция LAG
-- =============================================================================

EXPLAIN (ANALYZE, BUFFERS)
WITH sorted_flights AS (
    SELECT 
        flight_id,
        actual_departure,
        actual_arrival,
        LAG(actual_arrival) OVER (
            ORDER BY actual_departure
        ) AS previous_arrival
    FROM flights
    WHERE actual_departure IS NOT NULL
        AND actual_arrival IS NOT NULL
        AND status = 'Arrived'
)
SELECT 
    previous_arrival,
    actual_departure AS next_departure,
    EXTRACT(EPOCH FROM (actual_departure - previous_arrival)) / 3600 AS gap_hours
FROM sorted_flights
WHERE previous_arrival IS NOT NULL
    AND (actual_departure - previous_arrival) > INTERVAL '6 hours'
ORDER BY gap_hours DESC
LIMIT 10;




WITH sorted_flights AS (
    SELECT 
        actual_departure,
        actual_arrival,
        LAG(actual_arrival) OVER (ORDER BY actual_departure) AS previous_arrival
    FROM flights
    WHERE actual_departure IS NOT NULL
        AND actual_arrival IS NOT NULL
        AND status = 'Arrived'
)
SELECT 
    MAX(EXTRACT(EPOCH FROM (actual_departure - previous_arrival)) / 3600) AS max_gap_hours
FROM sorted_flights
WHERE previous_arrival IS NOT NULL;



-- >>> ВЫВОДЫ:
-- >>> Максимальный разрыв между последовательными рейсами составляет 0.756 часа (~45 минут)
-- >>> Самолёты используются с высокой интенсивностью (коэффициент загрузки близок к 100%)
-- >>> Окна для профилактики длительностью > 6 часов отсутствуют
-- >>> Рекомендация: для технического обслуживания необходимо выделять специальные слоты в расписании