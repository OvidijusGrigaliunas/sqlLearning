SELECT t.passenger_id,
       t.ticket_no,
       b.book_ref,
       b.book_date,
       tf.fare_conditions,
       tf.amount,
       CONCAT(f.departure_airport, '-', f.arrival_airport) AS route,
       f.scheduled_departure,
       f.scheduled_arrival,
       f.status,
       SUM(tf.amount) OVER (PARTITION BY t.ticket_no)      AS total_amount
FROM (SELECT passenger_id,
             ticket_no,
             book_ref
      FROM tickets
      WHERE passenger_id = '0000 004609') AS t
         INNER JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
         INNER JOIN flights f ON f.flight_id = tf.flight_id
         INNER JOIN bookings b ON t.book_ref = b.book_ref
ORDER BY t.ticket_no, f.scheduled_departure;
