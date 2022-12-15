USE tempdb;

WITH cleaned
  AS (SELECT ROW_NUMBER() OVER (ORDER BY i.RowNumber) AS RowNumber,
             REPLACE(i.Data, '$ ', '')                AS Data
        FROM dbo.Input AS i
       WHERE i.Data NOT IN ( '$ cd /', '$ ls' )),
     parts
  AS (SELECT c.RowNumber,
             SUBSTRING(c.Data, 1, CHARINDEX(' ', c.Data) - 1)           AS Part1,
             SUBSTRING(c.Data, CHARINDEX(' ', c.Data) + 1, LEN(c.Data)) AS Part2
        FROM cleaned AS c),
     parsed
  AS (SELECT CAST(0 AS int)            AS RowNumber,
             CAST('/' AS varchar(200)) AS Path,
             CAST(NULL AS int)         AS Size
      UNION ALL
      SELECT ps.RowNumber + 1,
             CAST(CASE
                       WHEN pt.Part1 = 'cd' THEN
                           CASE pt.Part2
                                WHEN '..' THEN -- Remove last directory from path
                                    LEFT(ps.Path, LEN(ps.Path) - CHARINDEX('/', REVERSE(LEFT(ps.Path, LEN(ps.Path) - 1)) + '/'))
                                ELSE -- Append directory to path
                                    ps.Path + pt.Part2 + '/'
                           END
                       ELSE
                           ps.Path
                  END AS varchar(200)) AS Path,
             TRY_CAST(pt.Part1 AS int) AS Size
        FROM parsed AS ps
        JOIN parts  AS pt
          ON (pt.RowNumber = ps.RowNumber + 1)),
     dirs
  AS (SELECT DISTINCT
             p.Path
        FROM parsed AS p),
     dir_sizes
  AS (SELECT d.Path,
             SUM(p.Size) AS Size
        FROM dirs   AS d
        JOIN parsed AS p
          ON p.Path LIKE d.Path + '%'
       GROUP BY d.Path)
SELECT SUM(ds.Size) AS SumOfTotalSizes
  FROM dir_sizes AS ds
 WHERE ds.Size < 100000
OPTION (MAXRECURSION 2000);