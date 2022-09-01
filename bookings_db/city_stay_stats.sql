SELECT rss.arrival_city                                 AS city,
       cp.pop_2021                                      AS population,
       SUM(rss.tickets_bought)                          AS tickets_bought,
       SUM(rss.stayed_for_time_period)                  AS stayed_for_time_period,
       ROUND(AVG(rss.average_stay_duration_in_days), 2) AS average_stay_duration_in_days
FROM route_stay_stats AS rss
         LEFT JOIN city_pop AS cp ON rss.arrival_city = cp.city
GROUP BY rss.arrival_city, cp.pop_2021;