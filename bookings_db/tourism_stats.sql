WITH avg_city_stats AS (SELECT rs.arrival_city                  AS city,
                               rs.arrival_city_pop              AS population,
                               sum(rs.tickets_bought)           AS tickets_bought,
                               round(avg(return_percentage), 3) AS average_percentage
                        FROM week_stay AS rs
                        GROUP BY rs.arrival_city, rs.arrival_city_pop
                        ORDER BY coalesce(arrival_city_pop, 0) DESC)

SELECT *,
       round(acs.average_percentage / 100 * acs.tickets_bought, 0) AS stayed_under_2_weeks
FROM avg_city_stats as acs;
