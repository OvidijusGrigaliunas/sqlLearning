SELECT a.flight_no, (ad1.airport_name ->> 'en') AS departure, (ad2.airport_name ->> 'en') AS arrival, a.tickets_bought
FROM (SELECT f.flight_no, f.departure_airport, f.arrival_airport, COUNT(tf.flight_id) AS tickets_bought
      FROM flights AS f
               LEFT JOIN ticket_flights tf ON f.flight_id = tf.flight_id
      GROUP BY f.flight_no, f.departure_airport, f.arrival_airport
      ORDER BY f.flight_no DESC) AS a
         LEFT JOIN airports_data AS ad1 ON a.departure_airport = ad1.airport_code
         LEFT JOIN airports_data AS ad2 ON a.arrival_airport = ad2.airport_code;