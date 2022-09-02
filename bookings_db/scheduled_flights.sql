SELECT flight_id, flight_no, departure_airport, arrival_airport, scheduled_departure, scheduled_arrival, aircraft_code
FROM flights
WHERE departure_airport = 'DME'
  AND arrival_airport = 'TBW'
  AND status = 'Scheduled'
ORDER BY scheduled_departure;