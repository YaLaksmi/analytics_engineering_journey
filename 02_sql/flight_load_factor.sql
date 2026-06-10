-- =============================================================================
-- НАЗВАНИЕ: Анализ загрузки рейсов (оптимизированный)
-- ЗАДАЧА: найти рейсы с загрузкой < 50%
-- ПРИМЕЧАНИЕ: общее количество мест определяется по route_no (через другие таблицы)
-- =============================================================================

EXPLAIN (ANALYZE, BUFFERS)
WITH 
-- 1. Занятые места по рейсам
flight_occupancy AS (
    SELECT 
        flight_id,
        COUNT(*) AS occupied_seats
    FROM boarding_passes
    GROUP BY flight_id
)

SELECT 
    f.flight_id,
    f.route_no,
    f.scheduled_departure,
    COALESCE(occ.occupied_seats, 0) AS occupied_seats
FROM flights f
LEFT JOIN flight_occupancy occ ON f.flight_id = occ.flight_id
ORDER BY occupied_seats ASC
LIMIT 20;

-- >>> ВЫВОДЫ:
-- >>> Ускорение: GROUP BY вместо коррелированных подзапросов
-- >>> Рекомендуемый индекс: CREATE INDEX ON boarding_passes(flight_id);