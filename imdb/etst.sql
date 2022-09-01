SELECT s.tconst                          AS id,
       s."primaryTitle"                  AS movie_title,
       r."averageRating"                 AS rating,
       r."numVotes"                      AS total_votes,
       s."startYear"                     AS released,
       s.genres                          AS genre,
       STRING_AGG(d."primaryName", ', ') AS directors
FROM shows AS s
         INNER JOIN ratings r ON s.tconst = r.tconst
         INNER JOIN (SELECT crew.tconst, REGEXP_SPLIT_TO_TABLE(crew.directors, E',') AS directors FROM crew) AS c
                    ON c.tconst = s.tconst
         INNER JOIN data AS d
                    ON d.nconst = c.directors
WHERE s."titleType" = 'movie'
GROUP BY s.tconst,
         s."primaryTitle",
         r."averageRating",
         r."numVotes",
         s."startYear",
         s.genres
ORDER BY s."tconst";