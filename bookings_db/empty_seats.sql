-- suranda tuščias vietas skrydyje
WITH not_empty_seats AS (SELECT f.aircraft_code, bp.seat_no
                         FROM flights AS f
                                  LEFT JOIN boarding_passes bp ON f.flight_id = bp.flight_id
                         WHERE f.flight_id = '4385')
SELECT DISTINCT s2.seat_no AS free_seat_no, s2.fare_conditions
FROM (SELECT s.seat_no, s.fare_conditions
      FROM seats AS s,
           not_empty_seats AS nes
      WHERE s.aircraft_code = nes.aircraft_code) AS s2
         LEFT OUTER JOIN not_empty_seats AS nes2 ON s2.seat_no = nes2.seat_no
WHERE nes2.seat_no IS NULL
ORDER BY free_seat_no;