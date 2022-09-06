-- gražina visas galimas skrydžio sedines ir jų užimtumą.
WITH not_empty_seats AS (SELECT f.aircraft_code, bp.seat_no
                         FROM flights AS f
                                  LEFT JOIN boarding_passes bp ON f.flight_id = bp.flight_id
                         WHERE f.flight_id = '4383')
SELECT s2.seat_no,
       s2.aircraft_code,
       s2.fare_conditions,
       CASE
           WHEN nes2.seat_no IS NULL THEN 'empty'
           ELSE 'occupied' END AS status
FROM (SELECT s3.seat_no, s3.fare_conditions, s3.aircraft_code
      FROM seats AS s3
               INNER JOIN (SELECT aircraft_code FROM flights WHERE flight_id = '4383') AS nes
                          ON nes.aircraft_code = s3.aircraft_code) AS s2
         LEFT JOIN not_empty_seats AS nes2 ON s2.seat_no = nes2.seat_no AND s2.aircraft_code = nes2.aircraft_code
ORDER BY s2.seat_no;