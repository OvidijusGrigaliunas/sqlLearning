SELECT s."primaryTitle", j.category, r."averageRating", r."numVotes"
FROM (SELECT data."primaryName", data.nconst
      FROM data
      WHERE data."primaryName" = 'Quentin Tarantino') as d
         INNER JOIN jobs AS j ON j.nconst = d.nconst AND j.category = 'director'
         INNER JOIN shows AS s ON j.tconst = s.tconst AND s."titleType" = 'movie'
         INNER JOIN ratings r ON s.tconst = r.tconst
ORDER BY r."numVotes" DESC;