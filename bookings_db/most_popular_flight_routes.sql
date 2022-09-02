-- Populiariausios skrydžių kryptys
SELECT (ad1.airport_name ->> 'en')                                                       AS departure_airport,
       (ad2.airport_name ->> 'en')                                                       AS arrival_airport,
       f2.tickets_bought,
       f2.profit,
       f2.avg_ticket_cost,
       ROUND(CAST(point_distance(ad1.coordinates, ad2.coordinates) * 111 AS NUMERIC), 3) AS distance_km,
       ROUND(CAST(f2.avg_ticket_cost / (point_distance(ad1.coordinates, ad2.coordinates) * 111
           ) AS NUMERIC), 2)                                                             AS price_per_km
FROM (SELECT DISTINCT f.departure_airport,
                      f.arrival_airport,
                      COUNT(tf.ticket_no)         AS tickets_bought,
                      COALESCE(SUM(tf.amount), 0) AS profit,
                      ROUND(AVG(tf.amount), 2)    AS avg_ticket_cost
      FROM flights AS f
               LEFT JOIN ticket_flights tf ON f.flight_id = tf.flight_id
      GROUP BY f.departure_airport, f.arrival_airport) AS f2
         INNER JOIN airports_data ad1 ON f2.arrival_airport = ad1.airport_code
         INNER JOIN airports_data ad2 ON f2.departure_airport = ad2.airport_code
ORDER BY f2.tickets_bought DESC;
