SELECT s.tconst                          AS id,
       s."primaryTitle"                  AS title,
       s."startYear"                     AS released,
       s.genres                          AS genre,
       r."averageRating"                 AS rating,
       STRING_AGG(d."primaryName", ', ') AS directors
FROM shows AS s
         INNER JOIN ratings AS r ON r.tconst = s.tconst
         INNER JOIN (SELECT REGEXP_SPLIT_TO_TABLE(crew.directors, E',') AS directors, crew.tconst FROM crew) AS c
                    ON c.tconst = s.tconst
         INNER JOIN data AS d ON d.nconst = c.directors
WHERE s.tconst = 'tt0007617'
GROUP BY s.tconst,
         s."primaryTitle",
         s."startYear",
         s.genres, r."averageRating";