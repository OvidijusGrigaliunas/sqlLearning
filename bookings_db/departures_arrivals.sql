WITH departures AS (SELECT (ad.airport_name ->> 'en') AS airport_name,
                           (ad.city ->> 'en')         as city,
                           ad.airport_code,
                           count(f1.flight_id)        as departures
                    FROM airports_data AS ad
                             LEFT JOIN flights f1 on ad.airport_code = f1.departure_airport
                    GROUP BY ad.airport_name, ad.airport_code)
SELECT d.airport_name, d.city, d.departures, count(f1.flight_id) as arrivals
FROM departures AS d
         LEFT JOIN flights f1 on d.airport_code = f1.arrival_airport
GROUP BY d.airport_name, d.departures, d.city
ORDER BY d.airport_name;