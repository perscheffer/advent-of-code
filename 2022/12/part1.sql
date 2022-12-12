USE tempdb;

DROP TABLE IF EXISTS dbo.ValidStep;
DROP TABLE IF EXISTS dbo.Square;

CREATE TABLE dbo.Square
(
    SquareNumber int NOT NULL,
    Row          int NOT NULL,
    Col          int NOT NULL,
    Elevation    int NOT NULL,
    IsStart      bit NOT NULL,
    IsEnd        bit NOT NULL,
    CONSTRAINT PK_Square PRIMARY KEY (SquareNumber)
) AS NODE;
GO

CREATE TABLE dbo.ValidStep AS EDGE;

CREATE UNIQUE INDEX IX_ValidStep
ON dbo.ValidStep (
    $from_id,
    $to_id);

WITH letter
  AS (SELECT       CAST(ROW_NUMBER() OVER (ORDER BY i.RowNumber,
                                                    gs.value) AS int) AS SquareNumber,
                   i.RowNumber                                        AS Row,
                   gs.value                                           AS Col,
                   SUBSTRING(i.Data, gs.value, 1)                     AS Letter
        FROM       dbo.Input                       AS i
       CROSS APPLY GENERATE_SERIES(1, LEN(i.Data)) AS gs ),
     square
  AS (SELECT l.SquareNumber,
             l.Row,
             l.Col,
             ASCII(CASE l.Letter
                        WHEN 'S' THEN
                            'a'
                        WHEN 'E' THEN
                            'z'
                        ELSE
                            l.Letter
                   END) - 97 AS Elevation,
             CASE l.Letter
                  WHEN 'S' THEN
                      1
                  ELSE
                      0
             END             AS IsStart,
             CASE l.Letter
                  WHEN 'E' THEN
                      1
                  ELSE
                      0
             END             AS IsEnd
        FROM letter AS l)
INSERT dbo.Square (SquareNumber,
                   Row,
                   Col,
                   Elevation,
                   IsStart,
                   IsEnd)
SELECT s.SquareNumber,
       s.Row,
       s.Col,
       s.Elevation,
       s.IsStart,
       s.IsEnd
  FROM square AS s;

INSERT dbo.ValidStep ($from_id,
                      $to_id)
SELECT fs.$node_id AS [$from_id],
       ts.$node_id AS [$to_id]
  FROM dbo.Square AS fs
  JOIN dbo.Square AS ts
    ON ABS(ts.Row - fs.Row) + ABS(ts.Col - fs.Col) = 1
   AND ts.Elevation                                <= fs.Elevation + 1;

WITH path
  AS (SELECT       from_square.SquareNumber                                     AS StartSquare,
                   LAST_VALUE(to_square.SquareNumber) WITHIN GROUP (GRAPH PATH) AS EndSquare,
                   COUNT(to_square.SquareNumber) WITHIN GROUP (GRAPH PATH)      AS FewestSteps
        FROM       dbo.Square             AS from_square,
                   dbo.Square FOR PATH    AS to_square,
                   dbo.ValidStep FOR PATH AS valid_step
       WHERE MATCH( SHORTEST_PATH(from_square(-(valid_step)->to_square)+))
                AND from_square.IsStart = 1)
SELECT FewestSteps
  FROM path
 WHERE EndSquare = (   SELECT TOP (1)
                              SquareNumber
                         FROM dbo.Square
                        WHERE IsEnd = 1);