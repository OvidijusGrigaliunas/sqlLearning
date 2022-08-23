WITH aaa AS (SELECT DISTINCT (ad1.airport_name ->> 'en') AS departure_airport,
                             (ad2.airport_name ->> 'en') AS arrival_airport
             FROM flights as f
                      INNER JOIN airports_data ad1 on ad1.airport_code = f.arrival_airport
                      INNER JOIN airports_data ad2 on ad2.airport_code = f.departure_airport)
SELECT a.departure_airport, a.arrival_airport, point_distance(ad1.coordinates,ad2.coordinates)
FROM aaa as a
         INNER JOIN airports_data ad1 on (ad1.airport_name ->> 'en') = a.arrival_airport
         INNER JOIN airports_data ad2 on (ad2.airport_name ->> 'en') = a.departure_airport