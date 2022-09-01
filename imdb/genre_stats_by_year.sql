WITH shows_genre_split AS (SELECT s.tconst,
                                  REGEXP_SPLIT_TO_TABLE(s.genres, E',') AS genre,
                                  s."startYear"
                           FROM shows AS s
                           WHERE s."titleType" = 'movie'
                             AND s."startYear" BETWEEN 2000 AND 2022)
SELECT s."startYear",
       s.genre,
       ROUND(AVG(r."averageRating"), 2)              AS ratings_average,
       ROUND(SUM(r."numVotes"), 2)                   AS total_votes,
       COUNT(s.tconst)                               AS show_count,
       ROUND(SUM(r."numVotes") / COUNT(s.tconst), 2) AS avg_votes_per_show
FROM shows_genre_split AS s
         LEFT JOIN ratings AS r ON s.tconst = r.tconst
WHERE s.genre = 'Fantasy'
GROUP BY s."startYear", s.genre
ORDER BY s."startYear";
