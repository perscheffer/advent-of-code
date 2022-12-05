USE tempdb;

--------------------------------------------------------------------------------
--  CREATE TEMP TABLE #Stack_ FROM THE FIRST PART OF THE IMPUT. KEEP
--  "EMPTY CRATES" TO GET A CORRECT STACK NUMBER.
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS #Stack_;

WITH
-- Use the first part of the input as the drawing of the starting stacks
input1
  AS (SELECT RowNumber AS Depth,
             Data
        FROM dbo.Input
       WHERE RowNumber < ((   SELECT MIN(RowNumber)
                                FROM dbo.Input
                               WHERE Data IS NULL) - 1)),
-- Make the stack data comma separated
input2
  AS (SELECT i2.Depth,
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i2.Data, '    ', '[-]'), ' ', ''), '][', ','), '[', ''), ']', '') AS Data
        FROM input1 AS i2)
-- Split the comma separated data into rows
SELECT       ROW_NUMBER() OVER (PARTITION BY i2.Depth
                                    ORDER BY (SELECT NULL)) AS StackNumber,
             i2.Depth,
             ss.value                                       AS Crate
  INTO       #Stack_
  FROM       input2                     AS i2
 CROSS APPLY STRING_SPLIT(i2.Data, ',') AS ss;

--------------------------------------------------------------------------------
--  CREATE TEMP TABLE #Stack WITHOUT "EMPTY CRATES" AND WITH CORRECT DEPTH
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS #Stack;

SELECT StackNumber,
       ROW_NUMBER() OVER (PARTITION BY StackNumber
                              ORDER BY Depth) AS Depth,
       Crate
  INTO #Stack
  FROM #Stack_
 WHERE Crate <> '-';

DROP TABLE #Stack_;

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