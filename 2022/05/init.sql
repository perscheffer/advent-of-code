USE tempdb;

DROP TABLE IF EXISTS dbo.Input;

CREATE TABLE dbo.Input
(
    RowNumber int          IDENTITY(1, 1) NOT NULL,
    Data      varchar(100) NULL,
    CONSTRAINT PK_Input PRIMARY KEY CLUSTERED (RowNumber)
);
GO

CREATE OR ALTER VIEW dbo.vInput
AS
SELECT Data
  FROM dbo.Input;
GO

BULK INSERT dbo.vInput
FROM 'X:\05\input.txt'
WITH (TABLOCK);

DROP VIEW dbo.vInput;

SELECT *
  FROM dbo.Input;