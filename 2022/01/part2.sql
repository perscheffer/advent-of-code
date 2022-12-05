USE tempdb;

WITH inventory1
  AS (SELECT RowNumber,
             Data AS Calories,
             CASE
                  WHEN LAG(Data, 1) OVER (ORDER BY RowNumber) IS NULL THEN
                      1
                  ELSE
                      0
             END  AS IsNewElf
        FROM tempdb.dbo.Input),
     inventory2
  AS (SELECT SUM(i1.IsNewElf) OVER (ORDER BY i1.RowNumber
                                     ROWS UNBOUNDED PRECEDING) AS ElfId,
             i1.Calories
        FROM inventory1 AS i1
       WHERE i1.Calories IS NOT NULL),
     inventory3
  AS (SELECT TOP (3)
             i2.ElfId,
             SUM(i2.Calories) AS TotalCalories
        FROM inventory2 AS i2
       GROUP BY i2.ElfId
       ORDER BY SUM(i2.Calories) DESC)
SELECT SUM(i3.TotalCalories) AS TopThreeTotalCalories
  FROM inventory3 AS i3;