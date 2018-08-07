DECLARE @v_summarydatacode INT,
  @v_pagecount_act_subcode INT,
  @v_pagecount_est_subcode INT,
  @v_taqversionspecategorykey INT,
  @v_tentativepagecount INT,
  @v_nextkey INT

SELECT @v_pagecount_act_subcode = datasubcode
FROM subgentables
WHERE tableid = 616
  AND qsicode = 2

SELECT @v_pagecount_est_subcode = datasubcode
FROM subgentables
WHERE tableid = 616
  AND qsicode = 19

SELECT @v_summarydatacode = datacode
FROM gentables
WHERE tableid = 616
  AND qsicode = 1

DECLARE spec_cur CURSOR
FOR
SELECT c.taqversionspecategorykey,
  r.tentativepagecount
FROM taqversionspecitems i
INNER JOIN taqversionspeccategory c
  ON c.itemcategorycode = @v_summarydatacode
    AND c.taqversionspecategorykey = i.taqversionspecategorykey
INNER JOIN taqproject p
  ON p.taqprojectkey = c.taqprojectkey
    AND p.searchitemcode = 14
INNER JOIN taqprojecttitle t
  ON t.taqprojectkey = p.taqprojectkey
INNER JOIN book b
  ON b.bookkey = t.bookkey
INNER JOIN printing r
  ON r.bookkey = b.bookkey
    AND r.printingkey = t.printingkey
WHERE i.itemcode = @v_pagecount_act_subcode
  AND NOT EXISTS (
    SELECT 1
    FROM taqversionspecitems
    WHERE taqversionspecategorykey = c.taqversionspecategorykey
      AND itemcode = @v_pagecount_est_subcode
    )

OPEN spec_cur

FETCH spec_cur
INTO @v_taqversionspecategorykey,
  @v_tentativepagecount

WHILE @@FETCH_STATUS = 0
BEGIN
  EXEC get_next_key 'QSIDBA',
    @v_nextkey OUTPUT

  INSERT INTO taqversionspecitems (
    taqversionspecitemkey,
    taqversionspecategorykey,
    itemcode,
    quantity,
    validforprtgscode,
    lastuserid,
    lastmaintdate
    )
  VALUES (
    @v_nextkey,
    @v_taqversionspecategorykey,
    @v_pagecount_est_subcode,
    @v_tentativepagecount,
    3,
    'qsidba',
    getdate()
    )

  FETCH spec_cur
  INTO @v_taqversionspecategorykey,
    @v_tentativepagecount
END

CLOSE spec_cur

DEALLOCATE spec_cur
