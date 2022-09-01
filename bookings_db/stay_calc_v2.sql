/* Šitas query surenką skrydžių informacija kaip išvykimo, atvykimo datas, oro uostų id. Pagal skydžio
   id surandame bilietio id, pagal kurį žinome, kuris keleivis jį pirko. Pagal tai galėsime sužinoti kiek
   keleivių pirko bilietą atgal  */
CREATE TEMPORARY TABLE route_popularity
AS (SELECT f.departure_airport,
           f.arrival_airport,
           t.passenger_id,
           f.scheduled_departure,
           f.scheduled_arrival
    FROM tickets AS t
             INNER JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
             INNER JOIN flights f ON tf.flight_id = f.flight_id
        /* Surikiuoja informacija pagal keleivį. Kad galėtume naudoti lag funkciją. */
    ORDER BY passenger_id, scheduled_departure);

CREATE TEMPORARY TABLE filtered_by_stay
AS (SELECT departure_airport,
           arrival_airport,
           passenger_id,
           scheduled_departure,
           scheduled_arrival,
           prev_arrival,
           prev_passenger_id,
           rp.scheduled_departure - rp.prev_arrival AS stay_duration
           -- Su lag galime matyti ar prieštai buves skrydis yra to pačio keleivio ir ar sutampma kryptis.
           -- Tokių būdu galima sužinoti kiek laiko jis praleido vietovėje
    FROM (SELECT departure_airport,
                 arrival_airport,
                 passenger_id,
                 scheduled_departure,
                 scheduled_arrival,
                 LAG(scheduled_arrival) OVER () AS prev_arrival,
                 LAG(passenger_id) OVER ()      AS prev_passenger_id,
                 LAG(arrival_airport) OVER ()   AS prev_airport
          FROM route_popularity) AS rp
    WHERE rp.scheduled_departure - rp.prev_arrival BETWEEN
        '0 years 0 mons 0 days 0 hours 0 min 0.0 secs' AND '2 years 0 mons 0 days 0 hours 0 min 0.0 secs'
      AND rp.passenger_id = rp.prev_passenger_id
      AND prev_airport = departure_airport);
-- Apskaičiuoja atstuma tarp dviejų oro uostų.
CREATE TEMPORARY TABLE calc_distances
AS (SELECT DISTINCT (ad1.airport_name ->> 'en')                            AS departure_airport,
                    (ad2.airport_name ->> 'en')                            AS arrival_airport,
                    (ad1.city ->> 'en')                                    AS departure_city,
                    (ad2.city ->> 'en')                                    AS arrival_city,
                    -- Ši funkcija nėra 100% tiksli
                    point_distance(ad1.coordinates, ad2.coordinates) * 111 AS distance
    FROM flights AS f
             INNER JOIN airports_data ad1 ON ad1.airport_code = f.departure_airport
             INNER JOIN airports_data ad2 ON ad2.airport_code = f.arrival_airport);
-- Apskaičiuoja kiek bilietų buvo pirkti maršrutui
CREATE TEMPORARY TABLE tickets_bought_table
AS (SELECT COUNT(scheduled_departure) AS tickets_bought, departure_airport, arrival_airport
    FROM route_popularity AS rp
    GROUP BY departure_airport, arrival_airport);
-- Apskačiuoja kiek žmonių išbūvo tam tikrą laika tarpą(pagal filtered_by_stay where)
-- ir apskaičiuoja vidutinio būvimo trukmę
CREATE TEMPORARY TABLE stay_ticket_table
AS (SELECT (ad1.airport_name ->> 'en') AS departure_airport,
           (ad2.airport_name ->> 'en') AS arrival_airport,
           tbt.tickets_bought,
           stayed_for_time_period,
           average_stay_duration
    FROM (SELECT departure_airport,
                 arrival_airport,
                 COUNT(scheduled_departure) AS stayed_for_time_period,
                 AVG(stay_duration)         AS average_stay_duration
          FROM filtered_by_stay
          GROUP BY departure_airport, arrival_airport) AS fbs
             -- FULL JOIN, nes abu table gali neturėti visų krypčių, tai kad neprarastume duomenų, darome FULL JOIN. :)
             FULL JOIN tickets_bought_table tbt
                       ON tbt.departure_airport = fbs.departure_airport AND tbt.arrival_airport = fbs.arrival_airport
             INNER JOIN airports_data ad1
                        ON ad1.airport_code = fbs.departure_airport OR ad1.airport_code = tbt.departure_airport
             INNER JOIN airports_data ad2
                        ON ad2.airport_code = fbs.arrival_airport OR ad2.airport_code = tbt.arrival_airport);
-- Visos info atvaizdavimas
DROP TABLE route_stay_stats;
CREATE TABLE route_stay_stats AS
SELECT cd.departure_airport,
       cd.arrival_airport,
       cd.departure_city,
       cd.arrival_city,
       cd.distance,
       COALESCE(stt.tickets_bought, 0)                             AS tickets_bought,
       COALESCE(stt.stayed_for_time_period, 0)                     AS stayed_for_time_period,
       COALESCE(ROUND(CAST(stayed_for_time_period AS NUMERIC) / NULLIF(tickets_bought, 0) * 100, 2),
                0)                                                 AS percentage_stayed,
       ROUND(EXTRACT(DAYS FROM stt.average_stay_duration) + EXTRACT(HOURS FROM stt.average_stay_duration) /
                                                            24, 2) AS average_stay_duration_in_days
FROM stay_ticket_table AS stt
         RIGHT JOIN calc_distances cd
                    ON stt.arrival_airport = cd.arrival_airport AND stt.departure_airport = cd.departure_airport
ORDER BY COALESCE(stt.tickets_bought, 0) DESC;

DROP TABLE route_popularity;
DROP TABLE filtered_by_stay;
DROP TABLE calc_distances;
DROP TABLE tickets_bought_table;
DROP TABLE stay_ticket_table;
