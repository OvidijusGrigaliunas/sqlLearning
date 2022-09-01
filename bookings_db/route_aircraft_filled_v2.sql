-- skrydžių skaičius pagal kryptį ir lėktuvo modelį
CREATE TEMPORARY TABLE flight_count
AS (SELECT CONCAT(departure_airport, '-', arrival_airport) AS route,
           aircraft_code,
           COUNT(flight_id)                                AS flight_num,
           EXTRACT(YEAR FROM scheduled_departure)          AS year,
           EXTRACT(MONTH FROM scheduled_departure)         AS month
    FROM flights
    GROUP BY CONCAT(departure_airport, '-', arrival_airport), aircraft_code, EXTRACT(YEAR FROM scheduled_departure),
             EXTRACT(MONTH FROM scheduled_departure));
-- nupirktų bilietų kiekis pagal kryptį ir lėktuvo modelį
CREATE TEMPORARY TABLE ticket_count
AS (SELECT CONCAT(departure_airport, '-', arrival_airport) AS route,
           aircraft_code,
           COUNT(tf.ticket_no)                             AS tickets_bought,
           EXTRACT(YEAR FROM scheduled_departure)          AS year,
           EXTRACT(MONTH FROM scheduled_departure)         AS month
    FROM flights
             LEFT JOIN ticket_flights tf ON flights.flight_id = tf.flight_id
    GROUP BY CONCAT(departure_airport, '-', arrival_airport), aircraft_code, EXTRACT(YEAR FROM scheduled_departure),
             EXTRACT(MONTH FROM scheduled_departure));
-- Sedynių skaičius pagal lėktuvo modelį
CREATE TEMPORARY TABLE seat_count
AS (SELECT aircraft_code, COUNT(seat_no) AS seat_num
    FROM seats
    GROUP BY aircraft_code);
-- Susumuoja skrydžių kiekį, galimų sedynių skaičių ir panaudotų sedynių skaičių pagal maršrūtą ir datą.
CREATE TEMPORARY TABLE testas
AS (SELECT t.year,
           t.month,
           t.route,
           SUM(t.flight_num)               AS total_flights,
           SUM(t.flight_num * sc.seat_num) AS total_seats,
           SUM(t2.tickets_bought)          AS total_seats_used
    FROM flight_count AS t
             INNER JOIN ticket_count t2
                        ON t.aircraft_code = t2.aircraft_code AND t.year = t2.year AND t.month = t2.month AND
                           t.route = t2.route
             INNER JOIN seat_count sc ON t.aircraft_code = sc.aircraft_code
    GROUP BY t.year, t.month, t.route, t2.tickets_bought);
-- Atvaizdavimas
SELECT a.year,
       a.month,
       a.route,
       a.total_flights,
       a.total_seats,
       a.total_seats_used,
       ROUND(CAST(a.total_seats_used AS NUMERIC) / NULLIF(total_seats, 0) * 100, 2) AS percentage_filled
FROM testas AS a
ORDER BY route, a.year, a.month;

DROP TABLE flight_count;
DROP TABLE ticket_count;
DROP TABLE seat_count;
DROP TABLE testas;
