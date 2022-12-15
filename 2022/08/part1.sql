USE tempdb;

WITH transposed
  AS (SELECT       i.RowNumber                    AS Row,
                   gs.value                       AS Col,
                   SUBSTRING(i.Data, gs.value, 1) AS TreeHeight
        FROM       dbo.Input                       AS i
       CROSS APPLY GENERATE_SERIES(1, LEN(i.Data)) AS gs ),
     visibility
  AS (SELECT CASE
                  WHEN NOT EXISTS (   SELECT *
                                        FROM transposed AS i
                                       WHERE i.Row        = o.Row
                                         AND i.Col        < o.Col
                                         AND i.TreeHeight >= o.TreeHeight) THEN
                      1
                  ELSE
                      0
             END AS FromLeft,
             CASE
                  WHEN NOT EXISTS (   SELECT *
                                        FROM transposed AS i
                                       WHERE i.Row        = o.Row
                                         AND i.Col        > o.Col
                                         AND i.TreeHeight >= o.TreeHeight) THEN
                      1
                  ELSE
                      0
             END AS FromRight,
             CASE
                  WHEN NOT EXISTS (   SELECT *
                                        FROM transposed AS i
                                       WHERE i.Row        < o.Row
                                         AND i.Col        = o.Col
                                         AND i.TreeHeight >= o.TreeHeight) THEN
                      1
                  ELSE
                      0
             END AS FromTop,
             CASE
                  WHEN NOT EXISTS (   SELECT *
                                        FROM transposed AS i
                                       WHERE i.Row        > o.Row
                                         AND i.Col        = o.Col
                                         AND i.TreeHeight >= o.TreeHeight) THEN
                      1
                  ELSE
                      0
             END AS FromBottom
        FROM transposed AS o)
SELECT COUNT(*)
  FROM visibility AS v
 WHERE v.FromLeft   <> 0
    OR v.FromRight  <> 0
    OR v.FromTop    <> 0
    OR v.FromBottom <> 0;