USE tempdb;

WITH section_assignment
  AS (SELECT CAST(PARSENAME(REPLACE(REPLACE(Data, '-', '.'), ',', '.'), 4) AS int) AS Elf1SectionFrom,
             CAST(PARSENAME(REPLACE(REPLACE(Data, '-', '.'), ',', '.'), 3) AS int) AS Elf1SectionTo,
             CAST(PARSENAME(REPLACE(REPLACE(Data, '-', '.'), ',', '.'), 2) AS int) AS Elf2SectionFrom,
             CAST(PARSENAME(REPLACE(REPLACE(Data, '-', '.'), ',', '.'), 1) AS int) AS Elf2SectionTo
        FROM dbo.Input)
SELECT COUNT(*)
  FROM section_assignment AS sa
 WHERE sa.Elf1SectionFrom BETWEEN sa.Elf2SectionFrom AND sa.Elf2SectionTo
    OR sa.Elf2SectionFrom BETWEEN sa.Elf1SectionFrom AND sa.Elf1SectionTo;