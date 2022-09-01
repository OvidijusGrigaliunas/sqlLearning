SELECT *
FROM flights
WHERE departure_airport = 'DME'
  AND arrival_airport = 'TBW'
  AND status = 'Scheduled'
ORDER BY scheduled_departure;