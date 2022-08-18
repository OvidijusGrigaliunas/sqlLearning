SELECT DISTINCT (ad1.city ->> 'en') AS departure_airport,
                (ad2.city ->> 'en') AS arrival_airport,
                count(*)            AS flight_count
FROM flights as f
         INNER JOIN airports_data ad1 on ad1.airport_code = f.arrival_airport
         INNER JOIN airports_data ad2 on ad2.airport_code = f.departure_airport
GROUP BY ad1.city, ad2.city
ORDER BY count(*) DESC
LIMIT 100;