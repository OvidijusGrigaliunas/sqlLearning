/* Šitas query surenką skrydžių informacija kaip išvykimo, atvykimo datas, oro uostų id. Pagal skydžio
   id surandame bilietio id, pagal kurį žinome, kuris keleivis jį pirko. Pagal tai galėsime sužinoti kiek
   keleivių pirko bilietą atgal  */
CREATE TEMPORARY TABLE route_popularity AS (SELECT f.departure_airport,
                                                   f.arrival_airport,
                                                   t.passenger_id,
                                                   f.scheduled_departure,
                                                   f.scheduled_arrival,
                                                   count(tf.ticket_no) AS tickets_bought
                                            FROM flights AS f
                                                     INNER JOIN ticket_flights tf ON tf.flight_id = f.flight_id
                                                     INNER JOIN tickets t ON tf.ticket_no = t.ticket_no
                                            GROUP BY f.departure_airport,
                                                     f.arrival_airport,
                                                     f.scheduled_departure,
                                                     f.scheduled_arrival,
                                                     t.passenger_id);
CREATE TEMPORARY TABLE temp_table_return AS
SELECT (ad1.airport_name ->> 'en') AS arrival_airport,
       (ad2.airport_name ->> 'en') AS departure_airport,
       rp2.tickets_bought,
       rp2.return_tickets_bought
FROM (
/* Šitas subquery nustato kiek bilietų buvo pirktą skristi šia kryptimi ir kiek buvo pirktą bilietų grižti atgal */
         SELECT rp1.arrival_airport,
                rp1.departure_airport,
                sum(COALESCE(rp1.tickets_bought, 0)) AS tickets_bought,
                sum(COALESCE(rp2.tickets_bought, 0)) AS return_tickets_bought
         FROM route_popularity AS rp1
                  LEFT JOIN route_popularity AS rp2
             /* Tikriname ar yra skrydžių su tą priešinga kryptimi, kurio bilietą pirk tas pats žmogus velesnę dieną*/
                            ON rp1.departure_airport = rp2.arrival_airport AND
                               rp1.arrival_airport = rp2.departure_airport AND
                               rp1.passenger_id = rp2.passenger_id AND rp1.scheduled_arrival < rp2.scheduled_departure
         GROUP BY rp1.arrival_airport, rp1.departure_airport) AS rp2
/* Oro uosto id pakeičiame į jo pavadinimą*/
         INNER JOIN airports_data ad1 ON ad1.airport_code = rp2.arrival_airport
         INNER JOIN airports_data ad2 ON ad2.airport_code = rp2.departure_airport;
SELECT ttr1.arrival_airport,
       ttr1.departure_airport,
       COALESCE(ttr1.tickets_bought - ttr2.return_tickets_bought,0) AS tickets_bought,
       ttr1.return_tickets_bought,
       round((CAST(COALESCE(ttr1.return_tickets_bought, 0) AS NUMERIC) /
              NULLIF(ttr1.tickets_bought - ttr2.return_tickets_bought, 0)) *
             100, 2)                                    AS return_percentage
FROM temp_table_return AS ttr1
         LEFT JOIN temp_table_return AS ttr2
                   ON ttr1.departure_airport = ttr2.arrival_airport AND ttr1.arrival_airport = ttr2.departure_airport
ORDER BY COALESCE(ttr1.tickets_bought - ttr2.return_tickets_bought,0) DESC;
DROP TABLE route_popularity;
DROP TABLE temp_table_return;

