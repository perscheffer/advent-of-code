USE tempdb;

--------------------------------------------------------------------------------
--  READ FILE input.txt INTO TABLE Input
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.Input;

CREATE TABLE dbo.Input
(
    RowNumber    int     IDENTITY(1, 1) NOT NULL,
    OpponentPlay char(1) NOT NULL,
    Response     char(1) NOT NULL CONSTRAINT PK_Input PRIMARY KEY CLUSTERED (RowNumber)
);
GO

CREATE OR ALTER VIEW dbo.vInput
AS
SELECT OpponentPlay,
       Response
  FROM dbo.Input;
GO

BULK INSERT dbo.vInput
FROM 'X:\02\input.txt'
WITH (TABLOCK,
      FIELDTERMINATOR = ' ');

DROP VIEW dbo.vInput;

--------------------------------------------------------------------------------
--  VIEW INPUT DATA
--------------------------------------------------------------------------------
SELECT *
  FROM dbo.Input;