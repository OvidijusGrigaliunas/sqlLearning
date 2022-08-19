/* Šitas query surenką skrydžių informacija kaip išvykimo, atvykimo datas, oro uostų id. Pagal skydžio
   id surandame bilietio id, pagal kurį žinome, kuris keleivis jį pirko. Pagal tai galėsime sužinoti kiek
   keleivių pirko bilietą atgal  */
WITH route_popularity AS (SELECT f.departure_airport,
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
                                   t.passenger_id)
SELECT (ad1.airport_name ->> 'en') AS arrival_airport,
       (ad2.airport_name ->> 'en') AS departure_airport,
       rp2.tickets_bought,
       rp2.return_tickets_bought,
       rp2.return_percentage
FROM (
/* Šitas subquery nustato kiek bilietų buvo pirktą skristi šia kryptimi ir kiek buvo pirktą bilietų grižti atgal */
         SELECT rp1.arrival_airport,
                rp1.departure_airport,
                sum(COALESCE(rp1.tickets_bought, 0)) AS tickets_bought,
                sum(COALESCE(rp2.tickets_bought, 0)) AS return_tickets_bought,
                round((CAST(sum(COALESCE(rp2.tickets_bought, 0)) AS NUMERIC) /
                       NULLIF(sum(COALESCE(rp1.tickets_bought, 0)), 0)) *
                      100, 2)                        AS return_percentage
         FROM route_popularity AS rp1
                  LEFT JOIN route_popularity AS rp2
             /* Tikriname ar yra skrydžių su tą pačia kryptimi, kurio bilietą pirk tas pats žmogus velesnę dieną*/
                            ON rp1.departure_airport = rp2.arrival_airport AND
                               rp1.arrival_airport = rp2.departure_airport AND
                               rp1.passenger_id = rp2.passenger_id AND rp1.scheduled_arrival < rp2.scheduled_departure
         GROUP BY rp1.arrival_airport, rp1.departure_airport) AS rp2
/* Oro uosto id pakeičiame į jo pavadinimą*/
         INNER JOIN airports_data ad1 ON ad1.airport_code = rp2.arrival_airport
         INNER JOIN airports_data ad2 ON ad2.airport_code = rp2.departure_airport
ORDER BY rp2.tickets_bought DESC;