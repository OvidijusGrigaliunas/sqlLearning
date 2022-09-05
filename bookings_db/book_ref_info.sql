WITH info
         AS (SELECT b.book_ref,
                    b.book_date,
                    b.total_amount,
                    t.passenger_name,
                    t.ticket_no,
                    (t.contact_data ->> 'phone')                AS phone,
                    (t.contact_data ->> 'email')                AS email,
                    tf.amount                                   AS ticket_price,
                    tf.fare_conditions,
                    f.flight_no,
                    f.scheduled_departure,
                    f.scheduled_arrival,
                    f.scheduled_arrival - f.scheduled_departure AS flight_duration,
                    f.arrival_airport,
                    f.departure_airport,
                    f.aircraft_code,
                    bp.seat_no
             FROM (SELECT bo.book_ref, bo.book_date, bo.total_amount
                   FROM bookings AS bo
                   LIMIT 500) AS b
                      INNER JOIN tickets AS t ON b.book_ref = t.book_ref
                      INNER JOIN ticket_flights AS tf ON t.ticket_no = tf.ticket_no
                      INNER JOIN flights AS f ON tf.flight_id = f.flight_id
                      INNER JOIN boarding_passes AS bp ON tf.ticket_no = bp.ticket_no AND tf.flight_id = bp.flight_id)
SELECT dat.book_ref,
       dat.book_date,
       dat.total_amount,
       dat.passenger_name,
       dat.ticket_no,
       dat.phone,
       dat.email,
       dat.ticket_price,
       dat.fare_conditions,
       (acd.model ->> 'en')                            AS aircraft,
       dat.seat_no,
       dat.flight_no,
       dat.scheduled_departure,
       dat.scheduled_arrival,
       dat.scheduled_arrival - dat.scheduled_departure AS flight_duration,
       (ad1.airport_name ->> 'en')                     AS departure_airport,
       (ad2.airport_name ->> 'en')                     AS arrival_airport
FROM info AS dat
         INNER JOIN airports_data ad1 ON dat.arrival_airport = ad1.airport_code
         INNER JOIN airports_data ad2 ON dat.departure_airport = ad2.airport_code
         INNER JOIN aircrafts_data acd ON dat.aircraft_code = acd.aircraft_code;
