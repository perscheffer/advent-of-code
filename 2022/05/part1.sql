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
SELECT       gs.value                                 AS StackNumber,
             ROW_NUMBER() OVER (PARTITION BY gs.value
                                    ORDER BY d.Depth) AS Depth, -- Calculate new depth after removing "empty crates"
             SUBSTRING(d.Data, 4 * gs.value - 2, 1)   AS Crate    -- The second and then every fourth character is a crate
  INTO       #Stack
  FROM       drawing                                          AS d
 CROSS APPLY GENERATE_SERIES(1, (DATALENGTH(d.Data) + 2) / 4) AS gs
 WHERE       SUBSTRING(d.Data, 4 * gs.value - 2, 1) <> ' ';

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
--  ITERATE THROUGH STEPS AND MOVES AND MOVE CRATES BY UPDATING THE STACK DATA
--------------------------------------------------------------------------------
DECLARE @Step int = 1;

-- Iterate through steps
WHILE @Step <= (   SELECT MAX(Step)
                     FROM #Move)
BEGIN
    DECLARE @Move int = 1;

    -- Iterate throug moves
    WHILE @Move <= (   SELECT MAX(Number)
                         FROM #Move
                        WHERE Step = @Step)
    BEGIN
        DECLARE @FromStack int;
        DECLARE @ToStack int;

        SELECT @FromStack = FromStack,
               @ToStack   = ToStack
          FROM #Move
         WHERE Step = @Step;

        -- Move all crates down one level in target stack
        UPDATE #Stack
           SET Depth = Depth + 1
         WHERE StackNumber = @ToStack;

        -- Move the top crate from source stack to target stack
        UPDATE #Stack
           SET StackNumber = @ToStack
         WHERE StackNumber = @FromStack
           AND Depth       = 1;

        -- Move all crates up one level in source stack
        UPDATE #Stack
           SET Depth = Depth - 1
         WHERE StackNumber = @FromStack;

        SET @Move = @Move + 1;
    END;

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