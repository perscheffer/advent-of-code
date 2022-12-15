USE tempdb;

WITH compartment
  AS (SELECT RowNumber                 AS RucksackNumber,
             1                         AS Compartment,
             LEFT(Data, LEN(Data) / 2) AS Contents
        FROM dbo.Input
      UNION
      SELECT RowNumber                  AS RucksackNumber,
             2                          AS Compartment,
             RIGHT(Data, LEN(Data) / 2) AS Contents
        FROM dbo.Input),
     item
  AS (SELECT       c.RucksackNumber,
                   c.Compartment,
                   SUBSTRING(c.Contents, gs.value, 1) AS ItemType
        FROM       compartment                         AS c
       CROSS APPLY GENERATE_SERIES(1, LEN(c.Contents)) AS gs ),
     prio
  AS (SELECT i.RucksackNumber,
             i.Compartment,
             ASCII(i.ItemType) - CASE
                                      WHEN ASCII(i.ItemType) <= 90 THEN
                                          38
                                      ELSE
                                          96
                                 END AS Priority
        FROM item AS i),
     common
  AS (SELECT p.Priority
        FROM prio AS p
       GROUP BY p.RucksackNumber,
                p.Priority
      HAVING COUNT(DISTINCT p.Compartment) = 2)
SELECT SUM(common.Priority)
  FROM common;