-- V2 versija yra apie 3-4 kart greitesnė
-- Užtrunka vidutiniškai 2 min 50 sec, o V2 50sec
-- Kažkodėl padidėja ticket_boughts keičiant data, nors įtakos neturėtų būti

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
        /* Surikiuoja informacija pagal keleivį. Pagreitina join kitose query dalyse. */
    ORDER BY passenger_id, scheduled_departure);
CREATE TEMPORARY TABLE temp_table_return
AS (SELECT (ad1.airport_name ->> 'en') AS arrival_airport,
           (ad2.airport_name ->> 'en') AS departure_airport,
           rp2.tickets_bought,
           rp2.return_tickets_bought
    FROM (
/* Šitas subquery nustato kiek bilietų buvo pirktą skristi šia kryptimi ir kiek buvo pirktą bilietų grižti atgal */
             SELECT rp1.arrival_airport,
                    rp1.departure_airport,
                    COUNT(rp1.scheduled_departure) AS tickets_bought,
                    COUNT(rp2.scheduled_departure) AS return_tickets_bought
             FROM route_popularity AS rp1
                      LEFT JOIN route_popularity AS rp2
                 /* Tikriname ar yra skrydžių su priešinga kryptimi. Ir tikriname ar keleivis prabuvo tam tikrą laiko tarpą vietovėje*/
                                ON rp1.passenger_id = rp2.passenger_id AND
                                   rp1.arrival_airport = rp2.departure_airport AND
                                   rp1.scheduled_arrival - rp2.scheduled_departure BETWEEN
                                       '0 years 0 mons -9 days 0 hours 0 mins 0.0 secs' AND '0 years 0 mons -2 days 0 hours 0 mins 0.0 secs'
             GROUP BY rp1.arrival_airport, rp1.departure_airport) AS rp2
             /* Oro uosto id pakeičiame į jo pavadinimą*/
             INNER JOIN airports_data ad1 ON ad1.airport_code = rp2.arrival_airport
             INNER JOIN airports_data ad2 ON ad2.airport_code = rp2.departure_airport);

CREATE TEMPORARY TABLE calc_distances
AS (SELECT a.departure_airport,
           a.arrival_airport,
           a.departure_city,
           a.arrival_city,
           point_distance(ad1.coordinates, ad2.coordinates) * 111 AS distance
    FROM (SELECT DISTINCT (ad1.airport_name ->> 'en') AS departure_airport,
                          (ad2.airport_name ->> 'en') AS arrival_airport,
                          (ad1.city ->> 'en')         AS departure_city,
                          (ad2.city ->> 'en')         AS arrival_city
          FROM flights AS f
                   INNER JOIN airports_data ad1 ON ad1.airport_code = f.arrival_airport
                   INNER JOIN airports_data ad2 ON ad2.airport_code = f.departure_airport) AS a
             INNER JOIN airports_data ad1 ON (ad1.airport_name ->> 'en') = a.departure_airport
             INNER JOIN airports_data ad2 ON (ad2.airport_name ->> 'en') = a.arrival_airport);

DROP TABLE week_stay;

CREATE TABLE week_stay
AS (SELECT ttr1.departure_airport,
           ttr1.arrival_airport,
           cd.departure_city,
           cp1.pop_2021        AS departure_city_pop,
           cd.arrival_city,
           cp2.pop_2021        AS arrival_city_pop,
           cd.distance,
           ttr1.tickets_bought AS tickets_bought,
           ttr1.return_tickets_bought,
           round((CAST(COALESCE(ttr1.return_tickets_bought, 0) AS NUMERIC) /
                  NULLIF(ttr1.tickets_bought, 0)) *
                 100, 2)       AS return_percentage
    FROM temp_table_return AS ttr1
             LEFT JOIN temp_table_return AS ttr2
                       ON ttr1.departure_airport = ttr2.arrival_airport AND
                          ttr1.arrival_airport = ttr2.departure_airport
             LEFT JOIN calc_distances AS cd
                       ON ttr1.departure_airport = cd.departure_airport AND
                          ttr1.arrival_airport = cd.arrival_airport
             LEFT JOIN city_pop AS cp1
                       ON cd.departure_city = cp1.city
             LEFT JOIN city_pop AS cp2
                       ON cd.arrival_city = cp2.city
    ORDER BY COALESCE(ttr1.tickets_bought - ttr2.return_tickets_bought, 0) DESC);

DROP TABLE route_popularity;
DROP TABLE temp_table_return;
DROP TABLE calc_distances;
