CREATE TEMPORARY TABLE flights_month
AS (SELECT scheduled_departure, departure_airport, arrival_airport, flight_id
    FROM flights
    WHERE extract(YEARS FROM scheduled_departure) = 2017
      AND extract(MONTH FROM scheduled_departure) = 6);

CREATE TEMPORARY TABLE tickets_bought_time_of_day
AS (SELECT f.departure_airport,
           f.arrival_airport,
           COUNT(CASE
                     WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 0 AND 3
                         THEN 1 END) AS tickets_between_0_and_4,
           COUNT(CASE
                     WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 4 AND 7
                         THEN 1 END) AS tickets_between_4_and_8,
           COUNT(CASE
                     WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 8 AND 11
                         THEN 1 END) AS tickets_between_8_and_12,
           COUNT(CASE
                     WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 12 AND 15
                         THEN 1 END) AS tickets_between_12_and_16,
           COUNT(CASE
                     WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 16 AND 19
                         THEN 1 END) AS tickets_between_16_and_20,
           COUNT(CASE
                     WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 20 AND 23
                         THEN 1 END) AS tickets_between_20_and_24
    FROM flights_month AS f
             INNER JOIN ticket_flights tf ON f.flight_id = tf.flight_id
    GROUP BY f.departure_airport, f.arrival_airport);
CREATE TEMPORARY TABLE flights_time_of_day
AS (SELECT a.*
    FROM (SELECT f.departure_airport,
                 f.arrival_airport,
                 COUNT(CASE
                           WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 0 AND 3
                               THEN 1 END) AS flights_between_0_and_4,
                 COUNT(CASE
                           WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 4 AND 7
                               THEN 1 END) AS flights_between_4_and_8,
                 COUNT(CASE
                           WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 8 AND 11
                               THEN 1 END) AS flights_between_8_and_12,
                 COUNT(CASE
                           WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 12 AND 15
                               THEN 1 END) AS flights_between_12_and_16,
                 COUNT(CASE
                           WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 16 AND 19
                               THEN 1 END) AS flights_between_16_and_20,
                 COUNT(CASE
                           WHEN extract(HOURS FROM f.scheduled_departure) BETWEEN 20 AND 23
                               THEN 1 END) AS flights_between_20_and_24
          FROM flights_month AS f
          GROUP BY f.departure_airport, f.arrival_airport) AS a);
SELECT f.departure_airport,
       f.arrival_airport,
       f.flights_between_0_and_4,
       t.tickets_between_0_and_4,
       f.flights_between_4_and_8,
       t.tickets_between_4_and_8,
       f.flights_between_8_and_12,
       t.tickets_between_8_and_12,
       f.flights_between_12_and_16,
       t.tickets_between_12_and_16,
       f.flights_between_16_and_20,
       t.tickets_between_16_and_20,
       f.flights_between_20_and_24,
       t.tickets_between_20_and_24
FROM flights_time_of_day AS f
         LEFT JOIN tickets_bought_time_of_day t
                   ON f.arrival_airport = t.arrival_airport AND f.departure_airport = t.departure_airport;
DROP TABLE flights_time_of_day, tickets_bought_time_of_day, flights_month;