USE tempdb;

DROP TABLE IF EXISTS dbo.Input;

CREATE TABLE dbo.Input
(
    RowNumber int         IDENTITY(1, 1) NOT NULL,
    Data      varchar(50) NOT NULL,
    CONSTRAINT PK_Input PRIMARY KEY CLUSTERED (RowNumber)
);
GO

CREATE OR ALTER VIEW dbo.vInput
AS
SELECT Data
  FROM dbo.Input;
GO

BULK INSERT dbo.vInput
FROM 'X:\04\input.txt'
WITH (TABLOCK);

SELECT *
  FROM dbo.Input;