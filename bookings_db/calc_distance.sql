WITH aaa AS (SELECT DISTINCT departure_airport,
                             arrival_airport
             FROM flights AS f)
SELECT (ad1.airport_name ->> 'en')                            AS departure_airport,
       (ad2.airport_name ->> 'en')                            AS arrival_airport,
       point_distance(ad1.coordinates, ad2.coordinates) * 111 AS distance_km
FROM aaa AS a
         INNER JOIN airports_data ad1 ON a.departure_airport = ad1.airport_code
         INNER JOIN airports_data ad2 ON a.arrival_airport = ad2.airport_code;