CREATE TEMPORARY TABLE filtered_flights
AS ((SELECT DISTINCT ON (t.ticket_no) t.ticket_no,
                                      tf.flight_id,
                                      f.scheduled_departure,
                                      f.departure_airport,
                                      f.arrival_airport
     FROM tickets AS t
              LEFT JOIN ticket_flights tf on t.ticket_no = tf.ticket_no
              LEFT JOIN flights f on f.flight_id = tf.flight_id
     ORDER BY ticket_no ASC, scheduled_departure ASC)
    UNION
    (SELECT DISTINCT ON (t.ticket_no) t.ticket_no,
                                      tf.flight_id,
                                      f.scheduled_departure,
                                      f.departure_airport,
                                      f.arrival_airport
     FROM tickets AS t
              LEFT JOIN ticket_flights tf on t.ticket_no = tf.ticket_no
              LEFT JOIN flights f on f.flight_id = tf.flight_id
     ORDER BY ticket_no ASC, scheduled_departure DESC));
SELECT a.ticket_no, a.flight_id, a.departure_airport, a.arrival_airport
FROM (SELECT *,
             lag(departure_airport) OVER (partition by ticket_no ORDER BY ticket_no, scheduled_departure) as aaa,
             lag(arrival_airport) OVER (partition by ticket_no ORDER BY ticket_no, scheduled_departure)   as aa,
             lag(arrival_airport) OVER (partition by ticket_no ORDER BY ticket_no, scheduled_departure)   as a
      FROM filtered_flights) as a
WHERE (a.departure_airport = a.aaa AND a.arrival_airport = a.aa)
   OR a.ticket_no <> a.a;

DROP TABLE filtered_flights;