SELECT b.book_ref,
       b.book_date,
       b.total_amount,
       t.passenger_name,
       t.ticket_no,
       (t.contact_data ->> 'phone')                AS phone,
       (t.contact_data ->> 'email')                AS email,
       tf.amount                                   AS ticket_price,
       tf.fare_conditions,
       bp.seat_no,
       (acd.model ->> 'en')                        AS aircraft,
       f.flight_no,
       f.scheduled_departure,
       f.scheduled_arrival,
       f.scheduled_arrival - f.scheduled_departure AS flight_duration,
       (ad1.airport_name ->> 'en')                 AS departure_airport,
       (ad2.airport_name ->> 'en')                 AS arrival_airport
FROM (SELECT *
      FROM bookings
      LIMIT 500) as b
         INNER JOIN tickets t ON b.book_ref = t.book_ref
         INNER JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
         INNER JOIN flights f ON tf.flight_id = f.flight_id
         INNER JOIN airports_data ad1 ON f.arrival_airport = ad1.airport_code
         INNER JOIN airports_data ad2 ON f.departure_airport = ad2.airport_code
         INNER JOIN aircrafts_data acd ON f.aircraft_code = acd.aircraft_code
         INNER JOIN boarding_passes bp ON tf.ticket_no = bp.ticket_no AND tf.flight_id = bp.flight_id;
