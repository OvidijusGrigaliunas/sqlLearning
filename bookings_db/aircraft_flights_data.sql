WITH aircraft_stats AS (SELECT ad.aircraft_code, ad.model, ad.total_seats, COUNT(f.flight_id) AS total_flights
                        FROM (SELECT ad.aircraft_code,
                                     (ad.model ->> 'en') AS model,
                                     COUNT(s.seat_no)    AS total_seats
                              FROM aircrafts_data AS ad
                                       LEFT JOIN seats s
                                                 ON ad.aircraft_code = s.aircraft_code
                              GROUP BY ad.model, ad.aircraft_code) AS ad
                                 LEFT JOIN flights f
                                           ON ad.aircraft_code = f.aircraft_code
                        GROUP BY ad.aircraft_code, ad.model, ad.total_seats)
SELECT stats.aircraft_code,
       stats.model,
       stats.total_seats,
       stats.total_flights,
       a.tickets_bought,
       ROUND(CAST(a.tickets_bought AS NUMERIC) / (stats.total_flights * total_seats) * 100, 2) AS percentage_filled_avg
FROM aircraft_stats AS stats
         LEFT JOIN (SELECT ad2.aircraft_code, COUNT(tf.ticket_no) AS tickets_bought
                    FROM aircrafts_data AS ad2
                             INNER JOIN flights f2 ON ad2.aircraft_code = f2.aircraft_code
                             INNER JOIN ticket_flights tf ON f2.flight_id = tf.flight_id
                    GROUP BY ad2.aircraft_code) AS a ON a.aircraft_code = stats.aircraft_code;