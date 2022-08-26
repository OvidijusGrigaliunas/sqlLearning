SELECT t.passenger_id,
       t.ticket_no,
       tf.fare_conditions,
       tf.amount,
       concat(f.departure_airport, '-', f.arrival_airport) AS route,
       f.scheduled_departure,
       f.scheduled_arrival,
       f.status,
       sum(tf.amount) OVER (PARTITION BY t.ticket_no)      AS total_amount
FROM (SELECT passenger_id,
             ticket_no
      FROM tickets
      WHERE passenger_id = '0000 004609') AS t
         INNER JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
         INNER JOIN flights f ON f.flight_id = tf.flight_id
ORDER BY t.ticket_no, f.scheduled_departure;
