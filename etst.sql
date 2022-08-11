SELECT s."primaryTitle"  AS movie_title,
       r."averageRating" AS rating,
       r."numVotes"      AS total_votes,
       s."startYear"     AS released,
       regexp_split_to_table(s.genres, E',') AS genre,
       d."primaryName"   AS directors
FROM shows as s
         INNER JOIN ratings r on s.tconst = r.tconst
         INNER JOIN (SELECT crew.tconst, regexp_split_to_table(crew.directors, E',') AS directors FROM crew) AS c
                    on c.tconst = s.tconst
         INNER JOIN data AS d
                    on d.nconst = c.directors
WHERE r."averageRating" IS NOT NULL
  AND s."titleType" = 'movie'
  AND r."numVotes" > 1000
ORDER BY s."primaryTitle";