USE tempdb;

--------------------------------------------------------------------------------
--  CREATE TEMP TABLE #Stack FROM THE FIRST PART OF THE INPUT
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS #Stack;

WITH
-- Use the first part of the input as the d of the starting stacks
drawing
  AS (SELECT RowNumber AS Depth,
             Data
        FROM dbo.Input
       WHERE RowNumber < ((   SELECT MIN(RowNumber)
                                FROM dbo.Input
                               WHERE Data IS NULL) - 1)
         AND Data IS NOT NULL)
SELECT       gn.n                                     AS StackNumber,
             ROW_NUMBER() OVER (PARTITION BY gn.n
                                    ORDER BY d.Depth) AS Depth, -- Calculate new depth after removing "empty crates"
             SUBSTRING(d.Data, 4 * gn.n - 2, 1)       AS Crate        -- The second and then every fourth character is a crate
  INTO       #Stack
  FROM       drawing                                      AS d
 CROSS APPLY dbo.GetNums(1, (DATALENGTH(d.Data) + 2) / 4) AS gn
 WHERE       SUBSTRING(d.Data, 4 * gn.n - 2, 1) <> ' ';

--------------------------------------------------------------------------------
--  CREATE TEMP TABLE #Move FROM THE SECOND PART OF THE INPUT
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS #Move;

WITH move
  AS (SELECT RowNumber,
             Data
        FROM dbo.Input
       WHERE RowNumber > (   SELECT MIN(RowNumber)
                               FROM dbo.Input
                              WHERE Data IS NULL))
SELECT ROW_NUMBER() OVER (ORDER BY m.RowNumber)                                                 AS Step,
       PARSENAME(REPLACE(REPLACE(REPLACE(m.Data, 'move ', ''), ' from ', '.'), ' to ', '.'), 2) AS FromStack,
       PARSENAME(REPLACE(REPLACE(REPLACE(m.Data, 'move ', ''), ' from ', '.'), ' to ', '.'), 1) AS ToStack,
       PARSENAME(REPLACE(REPLACE(REPLACE(m.Data, 'move ', ''), ' from ', '.'), ' to ', '.'), 3) AS Number
  INTO #Move
  FROM move AS m;

--------------------------------------------------------------------------------
--  ITERATE THROUGH STEPS AND MOVE CRATES BY UPDATING THE STACK DATA
--------------------------------------------------------------------------------
DECLARE @Step int = 1;

WHILE @Step <= (   SELECT MAX(Step)
                     FROM #Move)
BEGIN
    DECLARE @FromStack int;
    DECLARE @ToStack int;
    DECLARE @Number int;

    SELECT @FromStack = FromStack,
           @ToStack   = ToStack,
           @Number    = Number
      FROM #Move
     WHERE Step = @Step;

    -- Move all crates down @Number levels in target stack
    UPDATE #Stack
       SET Depth = Depth + @Number
     WHERE StackNumber = @ToStack;

    -- Move the top @Number crates from source stack to target stack
    UPDATE #Stack
       SET StackNumber = @ToStack
     WHERE StackNumber = @FromStack
       AND Depth       <= @Number;

    -- Move all crates up @Number levels in source stack
    UPDATE #Stack
       SET Depth = Depth - @Number
     WHERE StackNumber = @FromStack;

    SET @Step = @Step + 1;
END;

--------------------------------------------------------------------------------
--  RETURN THE TOP CRATES COMBINED TOGETHER
--------------------------------------------------------------------------------
SELECT STRING_AGG(Crate, '')WITHIN GROUP(ORDER BY StackNumber) AS Message
  FROM #Stack
 WHERE Depth = 1;

DROP TABLE #Move;
DROP TABLE #Stack;