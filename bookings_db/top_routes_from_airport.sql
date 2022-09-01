CREATE TEMPORARY TABLE route_pop
AS (SELECT (ad1.airport_name ->> 'en') AS departure_airport,
           (ad2.airport_name ->> 'en') AS arrival_airport,
           tickets_bought
    FROM (SELECT DISTINCT f.departure_airport,
                          f.arrival_airport,
                          COUNT(tf.ticket_no) AS tickets_bought
          FROM flights AS f
                   LEFT JOIN ticket_flights tf ON f.flight_id = tf.flight_id
          GROUP BY f.departure_airport, f.arrival_airport
          ORDER BY COUNT(tf.ticket_no) DESC) AS a
             INNER JOIN airports_data ad1
                        ON ad1.airport_code = a.arrival_airport
             INNER JOIN airports_data ad2 ON ad2.airport_code = a.departure_airport);

SELECT rp.departure_airport, rp.arrival_airport, rp.tickets_bought
FROM route_pop AS rp
WHERE 2 > (SELECT COUNT(rp2.tickets_bought)
           FROM route_pop AS rp2
           WHERE rp2.tickets_bought > rp.tickets_bought
             AND rp.departure_airport = rp2.departure_airport)
ORDER BY rp.departure_airport, rp.tickets_bought DESC;

DROP TABLE route_pop;