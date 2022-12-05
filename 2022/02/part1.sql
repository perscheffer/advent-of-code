USE tempdb;

WITH strategy_guide
  AS (SELECT CASE Response
                  WHEN 'X' THEN
                      1 + CASE OpponentPlay
                               WHEN 'A' THEN
                                   3
                               WHEN 'B' THEN
                                   0
                               WHEN 'C' THEN
                                   6
                               ELSE
                                   NULL
                          END
                  WHEN 'Y' THEN
                      2 + CASE OpponentPlay
                               WHEN 'A' THEN
                                   6
                               WHEN 'B' THEN
                                   3
                               WHEN 'C' THEN
                                   0
                               ELSE
                                   NULL
                          END
                  WHEN 'Z' THEN
                      3 + CASE OpponentPlay
                               WHEN 'A' THEN
                                   0
                               WHEN 'B' THEN
                                   6
                               WHEN 'C' THEN
                                   3
                               ELSE
                                   NULL
                          END
                  ELSE
                      NULL
             END AS Score
        FROM dbo.Input)
SELECT SUM(sg.Score) AS TotalScore
  FROM strategy_guide AS sg;