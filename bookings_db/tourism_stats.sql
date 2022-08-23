WITH avg_city_stats AS (SELECT rs.arrival_city                  AS city,
                               rs.arrival_city_pop              as population,
                               sum(rs.tickets_bought)           as tickets_bought,
                               round(avg(return_percentage), 3) AS average_return_rate
                        FROM return_stats AS rs
                        GROUP BY rs.arrival_city, rs.arrival_city_pop
                        ORDER BY coalesce(arrival_city_pop, 0) DESC)

SELECT *,
       round(acs.average_return_rate / 100 * acs.tickets_bought, 0)                      AS short_stay_tickets,
       acs.tickets_bought - round(acs.average_return_rate / 100 * acs.tickets_bought, 0) AS long_stay_tickets
FROM avg_city_stats as acs;