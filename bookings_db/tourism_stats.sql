SELECT rs.arrival_city                  AS city,
       rs.arrival_city_pop              AS population,
       sum(rs.tickets_bought)           AS tickets_bought,
       round(avg(return_percentage), 3) AS average_percentage,
       round(sum(rs.tickets_bought) * (avg(return_percentage) / 100))
FROM week_stay AS rs
GROUP BY rs.arrival_city, rs.arrival_city_pop
ORDER BY coalesce(arrival_city_pop, 0) DESC;

