WITH aircraft_stats AS (SELECT ad.aircraft_code, ad.model, ad.total_seats, count(f.flight_id) as total_flights
                        FROM (SELECT ad.aircraft_code,
                                     (ad.model ->> 'en') AS model,
                                     count(s.seat_no)    as total_seats
                              FROM aircrafts_data as ad
                                       LEFT JOIN seats s
                                                 on ad.aircraft_code = s.aircraft_code
                              GROUP BY ad.model, ad.aircraft_code) as ad
                                 LEFT JOIN flights f
                                           on ad.aircraft_code = f.aircraft_code
                        GROUP BY ad.aircraft_code, ad.model, ad.total_seats)
SELECT stats.aircraft_code,
       stats.model,
       stats.total_seats,
       stats.total_flights,
       a.tickets_bought,
       round(cast(a.tickets_bought as numeric) / (stats.total_flights * total_seats) * 100, 2) AS percentage_filled_avg
FROM aircraft_stats as stats
         LEFT JOIN (SELECT ad2.aircraft_code, count(tf.ticket_no) AS tickets_bought
                    FROM aircrafts_data as ad2
                             INNER JOIN flights f2 on ad2.aircraft_code = f2.aircraft_code
                             INNER JOIN ticket_flights tf on f2.flight_id = tf.flight_id
                    GROUP BY ad2.aircraft_code) AS a ON a.aircraft_code = stats.aircraft_code;