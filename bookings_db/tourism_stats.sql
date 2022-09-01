SELECT rs.arrival_city                                                AS city,
       rs.arrival_city_pop                                            AS population,
       SUM(rs.tickets_bought)                                         AS tickets_bought,
       ROUND(AVG(return_percentage), 3)                               AS average_percentage,
       ROUND(SUM(rs.tickets_bought) * (AVG(return_percentage) / 100)) AS avg_tickets
FROM week_stay AS rs
GROUP BY rs.arrival_city, rs.arrival_city_pop
ORDER BY COALESCE(arrival_city_pop, 0) DESC;

