SELECT s."primaryTitle", d."primaryName", j.category, j.characters
FROM jobs AS j
         INNER JOIN shows AS s ON s.tconst = j.tconst
         INNER JOIN data AS d ON d.nconst = j.nconst
WHERE j.tconst = 'tt0709699';