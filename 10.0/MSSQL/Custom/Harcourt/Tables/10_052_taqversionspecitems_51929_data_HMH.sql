SET NOCOUNT ON

-- Insert (if they do not already exist) the following spec items to ALL TITLE TEMPLATES.
--2			Page Count (ACT)
--7			Spine Size
--10		Trim Size (ACT)
--13		book weight
--14		insert/illustrations (ACT)
--15		Barcode ID 1
--16		Barcode ID 2
--17		Total Run Time
--18		# of Units
--19		Page Count (EST)
--20		Trim Size (EST)
--21  	insert/illustrations (EST)
--22    Other format
--23    jacket vendor
--24    print vendor

DECLARE @v_titlerole INT, @v_projectrole INT, @v_summarycode INT, @v_categorykey INT, @v_itemcode INT, @v_sortorder INT, @v_newkey INT, @v_count INT

SELECT @v_projectrole = datacode
FROM gentables
WHERE tableid = 604
  AND qsicode = 3

SELECT @v_titlerole = datacode
FROM gentables
WHERE tableid = 605
  AND qsicode = 7

SELECT @v_summarycode = datacode
FROM gentables
WHERE tableid = 616
  AND qsicode = 1

SET @v_count = 0

DECLARE @Categories TABLE (taqversionspeccategorykey INT);
DECLARE @SpecItemsToInsert TABLE (itemcode INT, sortorder INT)

INSERT INTO @SpecItemsToInsert (itemcode, sortorder)
SELECT datasubcode, sortorder
FROM subgentables
WHERE tableid = 616
  AND qsicode IN (2, 7, 10, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24)

-- Populate a temp table with all Summary speccategorykeys for all title templates
INSERT INTO @Categories (taqversionspeccategorykey)
SELECT DISTINCT c.taqversionspecategorykey
FROM taqversionspeccategory c
WHERE c.taqprojectkey IN (
    SELECT taqprojectkey
    FROM taqprojecttitle t
    WHERE t.projectrolecode = @v_projectrole
      AND t.titlerolecode = @v_titlerole
      AND t.printingkey = 1
      AND t.bookkey IN (
        SELECT bookkey
        FROM coretitleinfo
        WHERE standardind='Y'
        )
    )
  AND c.itemcategorycode = @v_summarycode

DECLARE cur_categories CURSOR
FOR
SELECT taqversionspeccategorykey
FROM @Categories

OPEN cur_categories

FETCH cur_categories
INTO @v_categorykey

WHILE @@FETCH_STATUS = 0
BEGIN
  DECLARE cur_specitems CURSOR
  FOR
  SELECT itemcode
  FROM @SpecItemsToInsert
  ORDER BY sortorder

  OPEN cur_specitems

  FETCH cur_specitems
  INTO @v_itemcode

  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM taqversionspecitems
        WHERE taqversionspecategorykey = @v_categorykey
          AND itemcode = @v_itemcode
        )
    BEGIN
      EXEC get_next_key 'QSIDBA', @v_newkey OUT

      INSERT INTO taqversionspecitems (taqversionspecitemkey, taqversionspecategorykey, itemcode, validforprtgscode, unitofmeasurecode, lastuserid, lastmaintdate)
      VALUES (@v_newkey, @v_categorykey, @v_itemcode, 3, NULL, 'QSIDBA', getdate())

      SET @v_count = @v_count + 1
    END

    FETCH cur_specitems
    INTO @v_itemcode
  END

  CLOSE cur_specitems

  DEALLOCATE cur_specitems

  FETCH cur_categories
  INTO @v_categorykey
END

CLOSE cur_categories

DEALLOCATE cur_categories

PRINT 'Inserted ' + convert(varchar,@v_count) + ' rows'
