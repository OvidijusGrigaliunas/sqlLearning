CREATE TEMPORARY TABLE aaa
AS (WITH not_empty_seats AS (SELECT f.flight_id, f.aircraft_code, COUNT(bp.seat_no) AS seat_count
                             FROM flights AS f
                                      LEFT JOIN boarding_passes bp ON f.flight_id = bp.flight_id
                             WHERE f.departure_airport = 'OVB'
                               AND f.arrival_airport = 'SVO'
                               AND f.status = 'Scheduled'
                             GROUP BY f.flight_id, f.aircraft_code)
    SELECT nes.flight_id, nes.aircraft_code, COUNT(s.seat_no) - nes.seat_count as empty_seats
    FROM seats AS s
             INNER JOIN not_empty_seats AS nes ON s.aircraft_code = nes.aircraft_code
    GROUP BY nes.flight_id, nes.aircraft_code, nes.seat_count);

SELECT f.flight_id, f.flight_no, f.departure_airport, f.arrival_airport, f.scheduled_departure, f.scheduled_arrival, f.aircraft_code, a.empty_seats
FROM aaa as a
LEFT JOIN flights f ON a.flight_id = f.flight_id
ORDER BY scheduled_departure;

DROP TABLE aaa;