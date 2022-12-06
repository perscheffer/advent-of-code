USE tempdb;

WITH marker
  AS (SELECT       gn.n + 13                   AS EndPosition,
                   SUBSTRING(i.Data, gn.n, 14) AS Marker
        FROM       dbo.Input                        AS i
       CROSS APPLY dbo.GetNums(1, LEN(i.Data) - 13) AS gn ),
     marker_char
  AS (SELECT       m.EndPosition,
                   SUBSTRING(m.Marker, gn.n, 1) AS MarkerChar
        FROM       marker             AS m
       CROSS APPLY dbo.GetNums(1, 14) AS gn ),
     distinct_chars
  AS (SELECT mc.EndPosition,
             COUNT(DISTINCT mc.MarkerChar) AS DistinctMarkerChars
        FROM marker_char AS mc
       GROUP BY mc.EndPosition)
SELECT MIN(dc.EndPosition) AS CharactersProcessed
  FROM distinct_chars AS dc
 WHERE dc.DistinctMarkerChars = 14;