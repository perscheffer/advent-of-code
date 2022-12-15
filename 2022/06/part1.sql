USE tempdb;

WITH marker
  AS (SELECT       gs.value + 3                   AS EndPosition,
                   SUBSTRING(i.Data, gs.value, 4) AS Marker
        FROM       dbo.Input                                           AS i
       CROSS APPLY GENERATE_SERIES(CAST(1 AS bigint), LEN(i.Data) - 3) AS gs ),
     marker_char
  AS (SELECT       m.EndPosition,
                   SUBSTRING(m.Marker, gs.value, 1) AS MarkerChar
        FROM       marker                AS m
       CROSS APPLY GENERATE_SERIES(1, 4) AS gs ),
     distinct_chars
  AS (SELECT mc.EndPosition,
             COUNT(DISTINCT mc.MarkerChar) AS DistinctMarkerChars
        FROM marker_char AS mc
       GROUP BY mc.EndPosition)
SELECT MIN(dc.EndPosition) AS CharactersProcessed
  FROM distinct_chars AS dc
 WHERE dc.DistinctMarkerChars = 4;