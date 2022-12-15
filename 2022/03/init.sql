USE tempdb;

--------------------------------------------------------------------------------
--  READ FILE input.txt INTO TABLE Input
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.Input;

CREATE TABLE dbo.Input
(
    RowNumber int          IDENTITY(1, 1) NOT NULL,
    Data      varchar(100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    CONSTRAINT PK_Input PRIMARY KEY CLUSTERED (RowNumber)
);
GO

CREATE OR ALTER VIEW dbo.vInput
AS
SELECT Data
  FROM dbo.Input;
GO

BULK INSERT dbo.vInput
FROM 'X:\03\input.txt'
WITH (TABLOCK);

DROP VIEW dbo.vInput;

--------------------------------------------------------------------------------
--  VIEW INPUT DATA
--------------------------------------------------------------------------------
SELECT *
  FROM dbo.Input;

WITH cte
  AS (SELECT MAX(LEN(Data))                                           AS MaxLength,
             2 * MAX(LEN(Data))                                       AS DoubleMaxLength,
             POWER(10, CAST(FLOOR(LOG10(2 * MAX(LEN(Data)))) AS int)) AS Magnitude
        FROM dbo.Input)
SELECT c.MaxLength,
       CASE
            WHEN 1.0 * c.DoubleMaxLength / c.Magnitude <= 1 THEN
                c.Magnitude
            WHEN 1.0 * c.DoubleMaxLength / c.Magnitude <= 2 THEN
                2 * c.Magnitude
            WHEN 1.0 * c.DoubleMaxLength / c.Magnitude <= 5 THEN
                5 * c.Magnitude
            ELSE
                10 * c.Magnitude
       END AS ColumnSize
  FROM cte AS c;