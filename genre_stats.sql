WITH shows_genre_split AS (SELECT s.tconst,
                                  regexp_split_to_table(s.genres, E',') as genre
                           FROM shows as s
                           WHERE s."titleType" = 'movie')
SELECT s.genre,
       round(avg(coalesce(r."averageRating", 0)), 2) AS ratings_average,
       round(sum(coalesce(r."numVotes", 0)), 2) AS total_votes,
       count(s.tconst) AS show_count
FROM shows_genre_split as s
         LEFT JOIN ratings as r on s.tconst = r.tconst
GROUP BY s.genre
ORDER BY s.genre;
