WITH shows_genre_split AS (SELECT s.tconst,
                                  REGEXP_SPLIT_TO_TABLE(s.genres, E',') AS genre
                           FROM shows AS s
                           WHERE s."titleType" = 'movie')
SELECT s.genre,
       ROUND(AVG(COALESCE(r."averageRating", 0)), 2) AS ratings_average,
       ROUND(SUM(COALESCE(r."numVotes", 0)), 2)      AS total_votes,
       COUNT(s.tconst)                               AS show_count
FROM shows_genre_split AS s
         LEFT JOIN ratings AS r ON s.tconst = r.tconst
GROUP BY s.genre
ORDER BY s.genre;
