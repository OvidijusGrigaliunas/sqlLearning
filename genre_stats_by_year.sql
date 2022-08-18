WITH shows_genre_split AS (SELECT s.tconst,
                                  regexp_split_to_table(s.genres, E',') as genre,
                                  s."startYear"
                           FROM shows as s
                           WHERE s."titleType" = 'movie'
                             AND s."startYear" BETWEEN 2000 AND 2022)
SELECT s."startYear",
       s.genre,
       round(avg(r."averageRating"), 2)              AS ratings_average,
       round(sum(r."numVotes"), 2)                   AS total_votes,
       count(s.tconst)                               AS show_count,
       round(sum(r."numVotes") / count(s.tconst), 2) AS avg_votes_per_show
FROM shows_genre_split as s
         LEFT JOIN ratings as r on s.tconst = r.tconst
WHERE s.genre = 'Fantasy'
GROUP BY s."startYear", s.genre
ORDER BY s."startYear";
