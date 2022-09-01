-- Senas query, antra versija yra apie 8-9 kartus greitesnė
CREATE TEMPORARY TABLE testas
AS (SELECT DISTINCT f.year,
                    f.month,
                    f.route,
                    f.flight_num                                                 AS total_flights,
                    f.flight_num * sc.seat_num                                   AS total_seats,
                    COUNT(tf.ticket_no) OVER (PARTITION BY f.month,f.year,route) AS total_seats_used
    FROM (SELECT flight_id,
                 CONCAT(arrival_airport, '-', departure_airport)      AS route,
                 aircraft_code,
                 COUNT(flight_id)
                 OVER (PARTITION BY EXTRACT(YEAR FROM scheduled_departure),
                     EXTRACT(MONTH FROM scheduled_departure) ,
                     CONCAT(arrival_airport, '-', departure_airport)) AS flight_num,
                 EXTRACT(YEAR FROM scheduled_departure)               AS year,
                 EXTRACT(MONTH FROM scheduled_departure)              AS month
          FROM flights) AS f
             LEFT JOIN ticket_flights AS tf
                       ON f.flight_id = tf.flight_id
             LEFT JOIN (SELECT f.flight_id, COUNT(s.seat_no) AS seat_num
                        FROM flights AS f
                                 LEFT JOIN seats AS s ON f.aircraft_code = s.aircraft_code
                        GROUP BY f.flight_id) AS sc ON f.flight_id = sc.flight_id);
SELECT a.year,
       a.month,
       a.route,
       a.total_flights,
       a.total_seats,
       a.total_seats_used,
       ROUND(CAST(a.total_seats_used AS NUMERIC) / NULLIF(total_seats, 0) * 100, 2) AS percentage_filled
FROM testas AS a
ORDER BY route, a.year, a.month;

DROP TABLE testas;
