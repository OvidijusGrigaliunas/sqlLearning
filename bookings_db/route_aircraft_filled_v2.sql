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
CREATE TEMPORARY TABLE seat_stats
AS (SELECT fc.year,
           fc.month,
           fc.route,
           SUM(fc.flight_num)               AS total_flights,
           SUM(fc.flight_num * sc.seat_num) AS total_seats,
           SUM(tc2.tickets_bought)          AS total_seats_used
    FROM flight_count AS fc
             INNER JOIN ticket_count tc2
                        ON fc.aircraft_code = tc2.aircraft_code AND fc.year = tc2.year AND fc.month = tc2.month AND
                           fc.route = tc2.route
             INNER JOIN seat_count sc ON fc.aircraft_code = sc.aircraft_code
    GROUP BY fc.year, fc.month, fc.route);
-- Atvaizdavimas
SELECT ss.year,
       ss.month,
       ss.route,
       ss.total_flights,
       ss.total_seats,
       ss.total_seats_used,
       ROUND(CAST(ss.total_seats_used AS NUMERIC) / NULLIF(total_seats, 0) * 100, 2) AS percentage_filled
FROM seat_stats AS ss
ORDER BY route, ss.year, ss.month;

DROP TABLE flight_count;
DROP TABLE ticket_count;
DROP TABLE seat_count;
DROP TABLE seat_stats;
