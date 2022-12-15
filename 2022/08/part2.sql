USE tempdb;

DROP TABLE IF EXISTS #transposed;

CREATE TABLE #transposed
(
    Row        int NOT NULL,
    Col        int NOT NULL,
    TreeHeight int NOT NULL,
    CONSTRAINT PK_#transposed PRIMARY KEY (
        Row,
        Col)
);

INSERT #transposed (Row,
                    Col,
                    TreeHeight)
SELECT       i.RowNumber                    AS Row,
             gs.value                       AS Col,
             SUBSTRING(i.Data, gs.value, 1) AS TreeHeight
  FROM       dbo.Input                       AS i
 CROSS APPLY GENERATE_SERIES(1, LEN(i.Data)) AS gs;

WITH visibility
  AS (SELECT o.Row,
             o.Col,
             o.TreeHeight,
             CASE
                  WHEN o.Col = 1 THEN
                      0
                  ELSE
                      ISNULL((   SELECT MIN(x.Distance)
                                   FROM (   SELECT ABS(i.Col - o.Col) AS Distance
                                              FROM #transposed AS i
                                             WHERE i.Row        = o.Row
                                               AND i.Col        < o.Col
                                               AND i.TreeHeight >= o.TreeHeight) AS x ),
                             o.Col - 1)
             END AS LookingLeft,
             CASE
                  WHEN o.Col = (   SELECT MAX(Col)
                                     FROM #transposed) THEN
                      0
                  ELSE
                      ISNULL((   SELECT MIN(x.Distance)
                                   FROM (   SELECT ABS(i.Col - o.Col) AS Distance
                                              FROM #transposed AS i
                                             WHERE i.Row        = o.Row
                                               AND i.Col        > o.Col
                                               AND i.TreeHeight >= o.TreeHeight) AS x ),
                             (   SELECT MAX(Col)
                                   FROM #transposed) - o.Col)
             END AS LookingRight,
             CASE
                  WHEN o.Col = 1 THEN
                      0
                  ELSE
                      ISNULL((   SELECT MIN(x.Distance)
                                   FROM (   SELECT ABS(i.Row - o.Row) AS Distance
                                              FROM #transposed AS i
                                             WHERE i.Row        < o.Row
                                               AND i.Col        = o.Col
                                               AND i.TreeHeight >= o.TreeHeight) AS x ),
                             o.Row - 1)
             END AS LookingUp,
             CASE
                  WHEN o.Row = (   SELECT MAX(Row)
                                     FROM #transposed) THEN
                      0
                  ELSE
                      ISNULL((   SELECT MIN(x.Distance)
                                   FROM (   SELECT ABS(i.Row - o.Row) AS Distance
                                              FROM #transposed AS i
                                             WHERE i.Row        > o.Row
                                               AND i.Col        = o.Col
                                               AND i.TreeHeight >= o.TreeHeight) AS x ),
                             (   SELECT MAX(Col)
                                   FROM #transposed) - o.Row)
             END AS LookingDown
        FROM #transposed AS o)
SELECT MAX(v.LookingLeft * v.LookingRight * v.LookingUp * v.LookingDown)
  FROM visibility AS v;