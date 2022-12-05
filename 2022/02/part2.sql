USE tempdb;

WITH strategy_guide
  AS (SELECT CASE Response
                  WHEN 'X' THEN
                      0 + CASE OpponentPlay
                               WHEN 'A' THEN
                                   3
                               WHEN 'B' THEN
                                   1
                               WHEN 'C' THEN
                                   2
                               ELSE
                                   NULL
                          END
                  WHEN 'Y' THEN
                      3 + CASE OpponentPlay
                               WHEN 'A' THEN
                                   1
                               WHEN 'B' THEN
                                   2
                               WHEN 'C' THEN
                                   3
                               ELSE
                                   NULL
                          END
                  WHEN 'Z' THEN
                      6 + CASE OpponentPlay
                               WHEN 'A' THEN
                                   2
                               WHEN 'B' THEN
                                   3
                               WHEN 'C' THEN
                                   1
                               ELSE
                                   NULL
                          END
                  ELSE
                      NULL
             END AS Score
        FROM dbo.Input)
SELECT SUM(sg.Score) AS TotalScore
  FROM strategy_guide AS sg;