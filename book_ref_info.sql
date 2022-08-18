SELECT b.book_ref,
       b.total_amount,
       t.passenger_name,
       t.ticket_no,
       (t.contact_data ->> 'phone') AS phone,
       (t.contact_data ->> 'email') AS email,
       tf.amount                   AS ticket_price,
       tf.fare_conditions,
       bp.seat_no,
       (acd.model ->> 'en')        AS aircraft,
       f.flight_no,
       f.scheduled_departure,
       f.scheduled_arrival,
       f.scheduled_arrival - f.scheduled_departure as flight_duration,
       (ad1.airport_name ->> 'en') AS departure_airport,
       (ad2.airport_name ->> 'en') AS arrival_airport
FROM bookings as b
         INNER JOIN tickets t on b.book_ref = t.book_ref
         INNER JOIN ticket_flights tf on t.ticket_no = tf.ticket_no
         INNER JOIN flights f on f.flight_id = tf.flight_id
         INNER JOIN airports_data ad1 on f.arrival_airport = ad1.airport_code
         INNER JOIN airports_data ad2 on f.departure_airport = ad2.airport_code
         INNER JOIN aircrafts_data acd on acd.aircraft_code = f.aircraft_code
         INNER JOIN boarding_passes bp on tf.ticket_no = bp.ticket_no and tf.flight_id = bp.flight_id
ORDER BY book_ref
LIMIT 5000;