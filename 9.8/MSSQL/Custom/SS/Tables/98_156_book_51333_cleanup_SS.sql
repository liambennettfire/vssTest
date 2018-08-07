UPDATE book
SET nextprintingnbr = NULL
WHERE nextprintingnbr IS NOT NULL
  AND bookkey NOT IN (
    SELECT DISTINCT b.bookkey
    FROM book b
    INNER JOIN taqprojecttitle tpt
      ON b.bookkey = tpt.bookkey
        AND tpt.projectrolecode = (
          SELECT datacode
          FROM gentables
          WHERE tableid = 604
            AND qsicode = 3
          )
    WHERE b.nextprintingnbr > (
        SELECT max(printingnum) + 1
        FROM printing
        WHERE bookkey = b.bookkey
        )
    )
