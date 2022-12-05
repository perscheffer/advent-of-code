USE tempdb;

WITH nums
  AS (SELECT TOP (100)
             ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS i
        FROM master.dbo.spt_values
       ORDER BY i),
     item
  AS (SELECT       (i.RowNumber - 1) / 3 + 1    AS GroupNumber,
                   i.RowNumber                  AS RucksackNumber,
                   SUBSTRING(i.Data, nums.i, 1) AS ItemType
        FROM       dbo.Input AS i
       CROSS APPLY nums
       WHERE       nums.i <= LEN(i.Data)),
     prio
  AS (SELECT i.GroupNumber,
             i.RucksackNumber,
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
       GROUP BY p.GroupNumber,
                p.Priority
      HAVING COUNT(DISTINCT p.RucksackNumber) = 3)
SELECT SUM(common.Priority)
  FROM common;