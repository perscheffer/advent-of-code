SET NOCOUNT ON;

USE tempdb;

WITH instruction
  AS (SELECT RowNumber            AS InstructionNumber,
             CAST(CASE
                       WHEN Data LIKE '% %' THEN
                           LEFT(Data, CHARINDEX(' ', Data) - 1)
                       ELSE
                           Data
                  END AS char(4)) AS Instruction,
             CAST(CASE
                       WHEN Data LIKE '% %' THEN
                           SUBSTRING(Data, CHARINDEX(' ', Data) + 1, LEN(Data) - CHARINDEX(' ', Data))
                       ELSE
                           0
                  END AS int)     AS Value
        FROM dbo.Input),
     increment
  AS (SELECT i.InstructionNumber,
             i.Value AS Increment,
             CASE i.Instruction
                  WHEN 'addx' THEN
                      2
                  ELSE
                      1
             END     AS Cycles
        FROM instruction AS i),
     cycle
  AS (SELECT       CAST(ROW_NUMBER() OVER (ORDER BY i.InstructionNumber,
                                                    gn.n) AS int) AS CycleNumber,
                   CASE
                        WHEN i.Cycles = gn.n THEN
                            i.Increment
                        ELSE
                            0
                   END                                            AS Increment
        FROM       increment                AS i
       CROSS APPLY dbo.GetNums(1, i.Cycles) AS gn ),
     register
  AS (SELECT c.CycleNumber,
             COALESCE(SUM(c.Increment) OVER (ORDER BY c.CycleNumber
                                              ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),
                      0) + 1 AS X
        FROM cycle AS c),
     crt
  AS (SELECT (r.CycleNumber - 1) / 40 AS Row,
             (r.CycleNumber - 1) % 40 AS Col,
             CASE
                  WHEN r.X - ((r.CycleNumber - 1) % 40) BETWEEN -1 AND 1 THEN
                      N'█'
                  ELSE
                      N'░'
             END                      AS Pixel
        FROM register AS r)
SELECT CAST(STRING_AGG(crt.Pixel, N'')WITHIN GROUP(ORDER BY crt.Col) AS nchar(40)) AS Letters
  FROM crt
 GROUP BY crt.Row;