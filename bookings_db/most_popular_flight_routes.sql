SELECT DISTINCT (ad1.airport_name ->> 'en') AS departure_airport,
                (ad2.airport_name ->> 'en') AS arrival_airport,
                count(tf.ticket_no)         AS tickets_bought
FROM flights as f
         INNER JOIN airports_data ad1 on ad1.airport_code = f.arrival_airport
         INNER JOIN airports_data ad2 on ad2.airport_code = f.departure_airport
         LEFT JOIN ticket_flights tf on f.flight_id = tf.flight_id
GROUP BY ad1.airport_name, ad2.airport_name
ORDER BY count(tf.ticket_no) DESC;
