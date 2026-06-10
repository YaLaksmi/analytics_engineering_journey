-- Размер базы
SELECT pg_size_pretty(pg_database_size('demo')) AS db_size;

-- Количество строк в ключевых таблицах
SELECT 'boarding_passes' AS table_name, COUNT(*) FROM boarding_passes
UNION ALL
SELECT 'flights', COUNT(*) FROM flights
UNION ALL
SELECT 'tickets', COUNT(*) FROM tickets
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings;


-- Найти все посадочные талоны для конкретного рейса
EXPLAIN (ANALYZE, BUFFERS, verbose, TIMING)
SELECT * FROM boarding_passes
WHERE flight_id = 12345;


-- =============================================================================
-- НАЗВАНИЕ: Коррелированный подзапрос (очень медленный)
-- ЗАДАЧА: для каждого бронирования посчитать количество билетов
-- ПРОБЛЕМА: подзапрос выполняется для каждой строки bookings (миллионы раз)
-- =============================================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    b.book_ref,
    b.book_date,
    b.total_amount,
    (SELECT COUNT(*) FROM tickets t WHERE t.book_ref = b.book_ref) AS ticket_count
FROM bookings b
limit 100;


EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    b.book_ref,
    b.book_date,
    b.total_amount,
    SUM(1) AS cnt
FROM bookings b
GROUP BY b.book_ref, b.book_date, b.total_amount
limit 100;

-- >>> ВЫВОДЫ:
-- >>> Ускорение в 842 раза (1127 мс → 1.339 мс)
-- >>> Используется Index Scan (bookings_pkey) вместо Seq Scan
-- >>> Подзапросы устранены (loops=0)