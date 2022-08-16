SELECT s."primaryTitle", j.category, r."averageRating", r."numVotes"
FROM (SELECT data."primaryName", data.nconst
      FROM data
      WHERE data."primaryName" = 'Quentin Tarantino') as d
         INNER JOIN jobs AS j ON j.nconst = d.nconst
         INNER JOIN shows AS s ON j.tconst = s.tconst AND s."titleType" = 'movie'
         INNER JOIN ratings r ON s.tconst = r.tconst
WHERE j.category = 'director' OR j.category = 'writer'
ORDER BY r."numVotes" DESC;