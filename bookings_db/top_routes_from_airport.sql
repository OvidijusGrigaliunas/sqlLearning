CREATE TEMPORARY TABLE rpop
AS (SELECT DISTINCT (ad1.airport_name ->> 'en') AS departure_airport,
                    (ad2.airport_name ->> 'en') AS arrival_airport,
                    count(tf.ticket_no)         AS tickets_bought
    FROM flights AS f
             INNER JOIN airports_data ad1 ON ad1.airport_code = f.arrival_airport
             INNER JOIN airports_data ad2 ON ad2.airport_code = f.departure_airport
             LEFT JOIN ticket_flights tf ON f.flight_id = tf.flight_id
    GROUP BY ad1.airport_name, ad2.airport_name
    ORDER BY count(tf.ticket_no) DESC);

SELECT *
FROM rpop as rp
WHERE 3 > (select count(rp2.tickets_bought)
           from rpop as rp2
           where rp2.tickets_bought > rp.tickets_bought
             AND rp.departure_airport = rp2.departure_airport)
ORDER BY rp.departure_airport, rp.tickets_bought DESC;

DROP table rpop;