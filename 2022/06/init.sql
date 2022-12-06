USE tempdb;

--------------------------------------------------------------------------------
--  READ FILE input.txt INTO TABLE Input
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.Input;

CREATE TABLE dbo.Input
(
    RowNumber int          IDENTITY(1, 1) NOT NULL,
    Data      varchar(MAX) NOT NULL,
    CONSTRAINT PK_Input PRIMARY KEY CLUSTERED (RowNumber)
);
GO

CREATE OR ALTER VIEW dbo.vInput
AS
SELECT Data
  FROM dbo.Input;
GO

BULK INSERT dbo.vInput
FROM 'X:\06\input.txt'
WITH (TABLOCK);

DROP VIEW dbo.vInput;

--------------------------------------------------------------------------------
--  CREATE GetNums HELPER FUNCTION
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.BatchMe;

CREATE TABLE dbo.BatchMe
(
    col1 int NOT NULL,
    INDEX idx_cs CLUSTERED COLUMNSTORE
);
GO

CREATE OR ALTER FUNCTION dbo.GetNums
(
    @low AS  bigint = 1,
    @high AS bigint
)
RETURNS table
AS
RETURN WITH L0
         AS (SELECT 1 AS c
               FROM (   VALUES (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1),
                               (1)) AS D (c) ),
            L1
         AS (SELECT      1 AS c
               FROM      L0 AS A
              CROSS JOIN L0 AS B),
            L2
         AS (SELECT      1 AS c
               FROM      L1 AS A
              CROSS JOIN L1 AS B),
            L3
         AS (SELECT      1 AS c
               FROM      L2 AS A
              CROSS JOIN L2 AS B),
            Nums
         AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rownum
               FROM L3)
SELECT            TOP (@high - @low + 1)
                  Nums.rownum             AS rn,
                  @high + 1 - Nums.rownum AS op,
                  @low - 1 + Nums.rownum  AS n
  FROM            Nums
  LEFT OUTER JOIN dbo.BatchMe AS bm
               ON 1 = 0
 ORDER BY Nums.rownum;
GO

--------------------------------------------------------------------------------
--  VIEW INPUT DATA
--------------------------------------------------------------------------------

SELECT *
  FROM dbo.Input;