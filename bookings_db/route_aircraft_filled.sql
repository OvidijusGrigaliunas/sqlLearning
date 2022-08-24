SELECT DISTINCT f.year,
                f.month,
                f.route,
                f.flight_num               AS total_flights,
                f.flight_num * sc.seat_num AS total_seats,
                count(tf.ticket_no) OVER (PARTITION BY f.month,f.year,route)  AS total_seats_used,
                round(cast(count(tf.ticket_no) OVER (PARTITION BY f.month,f.year,route) AS NUMERIC) /
                      (f.flight_num * sc.seat_num) *
                      100, 2)              AS percentage_filled
FROM (SELECT flight_id,
             concat(arrival_airport, '-', departure_airport)      AS route,
             aircraft_code,
             count(flight_id)
             OVER (PARTITION BY extract(YEAR FROM scheduled_departure),
                 extract(MONTH FROM scheduled_departure) ,
                 concat(arrival_airport, '-', departure_airport)) AS flight_num,
             extract(YEAR FROM scheduled_departure)               AS year,
             extract(MONTH FROM scheduled_departure)              AS month
      FROM flights) AS f
         LEFT JOIN ticket_flights AS tf
                   ON f.flight_id = tf.flight_id
         LEFT JOIN (SELECT f.flight_id, count(s.seat_no) AS seat_num
                    FROM flights AS f
                             LEFT JOIN seats AS s ON f.aircraft_code = s.aircraft_code
                    GROUP BY f.flight_id) AS sc ON f.flight_id = sc.flight_id
ORDER BY route;
