SELECT s.tconst                          AS id,
       s."primaryTitle"                  AS title,
       s."startYear"                     AS released,
       s.genres                          AS genre,
       r."averageRating"                 AS rating,
       string_agg(d."primaryName", ', ') AS directors
FROM shows AS s
         INNER JOIN ratings AS r ON r.tconst = s.tconst
         INNER JOIN (SELECT regexp_split_to_table(crew.directors, E',') AS directors, crew.tconst FROM crew) AS c
                    ON c.tconst = s.tconst
         INNER JOIN data AS d ON d.nconst = c.directors
WHERE s.tconst = 'tt0007617'
GROUP BY s.tconst,
         s."primaryTitle",
         s."startYear",
         s.genres, r."averageRating";