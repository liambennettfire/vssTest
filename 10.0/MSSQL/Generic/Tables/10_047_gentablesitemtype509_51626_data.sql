-- Insert default item type filtering for Report types
DECLARE @v_sortorder INT,
  @v_qsicode INT,
  @v_reporttypecode INT,
  @v_reporttypesubcode INT,
  @v_reporttypesub2code INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_titles INT,
  @v_contacts INT,
  @v_projects INT,
  @v_journals INT,
  @v_works INT,
  @v_contracts INT,
  @v_scales INT,
  @v_printings INT,
  @v_purchaseorders INT,
  @v_titlereports INT,
  @v_contactreports INT,
  @v_projectreports INT,
  @v_generalreports INT,
  @v_journalreports INT,
  @v_workreports INT,
  @v_plstagereports INT,
  @v_plversionreports INT,
  @v_contractreports INT,
  @v_scalereports INT,
  @v_printingreports INT,
  @v_purchaseorderreports INT,
  @v_newkey INT

DECLARE @InsertTable TABLE (
  reporttype INT,
  itemtype INT
  )

SET @v_titlereports = 10
SET @v_contactreports = 11
SET @v_projectreports = 12
SET @v_generalreports = 13
SET @v_journalreports = 16
SET @v_workreports = 19
SET @v_plstagereports = 20
SET @v_plversionreports = 21
SET @v_contractreports = 22
SET @v_scalereports = 23
SET @v_printingreports = 24
SET @v_purchaseorderreports = 25

SELECT @v_titles = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 1

SELECT @v_contacts = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 2

SELECT @v_projects = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 3

SELECT @v_journals = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 6

SELECT @v_works = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 9

SELECT @v_contracts = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 10

SELECT @v_scales = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 11

SELECT @v_printings = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 14

SELECT @v_purchaseorders = datacode
FROM gentables
WHERE tableid = 550
  AND qsicode = 15

SET @v_usageclass = 0 -- All classes

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_titlereports, @v_titles)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_contactreports, @v_contacts)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_projectreports, @v_projects)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_generalreports, @v_titles)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_generalreports, @v_contacts)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_generalreports, @v_projects)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_generalreports, @v_journals)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_generalreports, @v_works)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_generalreports, @v_contracts)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_generalreports, @v_scales)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_generalreports, @v_printings)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_generalreports, @v_purchaseorders)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_journalreports, @v_journals)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_workreports, @v_works)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_plstagereports, @v_projects)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_plstagereports, @v_works)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_plversionreports, @v_projects)

INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_plversionreports, @v_works)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_contractreports, @v_contracts)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_scalereports, @v_scales)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_printingreports, @v_printings)
------
INSERT INTO @InsertTable (reporttype, itemtype)
VALUES (@v_purchaseorderreports, @v_purchaseorders)

DECLARE ins_cur CURSOR FOR
SELECT reporttype, itemtype
FROM @InsertTable

OPEN ins_cur

FETCH ins_cur
INTO @v_reporttypecode, @v_itemtype

WHILE @@FETCH_STATUS = 0
BEGIN
  DECLARE rpt_cur CURSOR FOR
  SELECT datasubcode, datasub2code
  FROM sub2gentables
  WHERE tableid = 509
    AND datacode = @v_reporttypecode
  ORDER BY datasubcode, datasub2code

  OPEN rpt_cur

  FETCH rpt_cur
  INTO @v_reporttypesubcode, @v_reporttypesub2code

  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM gentablesitemtype
        WHERE tableid = 509
          AND datacode = @v_reporttypecode
          AND datasubcode = @v_reporttypesubcode
          AND datasub2code = @v_reporttypesub2code
          AND itemtypecode = @v_itemtype
          AND itemtypesubcode = 0
        )
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUTPUT

      --PRINT 'Insert into gentablesitemtype: tableid=509, datacode=' + cast(@v_reporttypecode AS VARCHAR) + ' datasubcode=' + cast(@v_reporttypesubcode AS VARCHAR) + ' datasub2code=' + cast(@v_reporttypesub2code AS VARCHAR) + ' itemtypecode=' + cast(@v_itemtype AS VARCHAR) + ' itemtypesubcode=0'

      INSERT INTO gentablesitemtype (
        gentablesitemtypekey,
        tableid,
        datacode,
        datasubcode,
        datasub2code,
        itemtypecode,
        itemtypesubcode,
        lastuserid,
        lastmaintdate
        )
      VALUES (
        @v_newkey,
        509,
        @v_reporttypecode,
        @v_reporttypesubcode,
        @v_reporttypesub2code,
        @v_itemtype,
        0,
        'QSIDBA',
        getdate()
        )

      IF @@ERROR <> 0
      BEGIN
        PRINT 'Insert to gentablesitemtype had an error: tableid=509, datacode=' + cast(@v_reporttypecode AS VARCHAR) + ' datasubcode=' + cast(@v_reporttypesubcode AS VARCHAR) + ' datasub2code=' + cast(@v_reporttypesub2code AS VARCHAR) + ' itemtypecode=' + cast(@v_itemtype AS VARCHAR) + ' itemtypesubcode=0'

        GOTO ERROREXIT
      END
    END

    FETCH rpt_cur
    INTO @v_reporttypesubcode, @v_reporttypesub2code
  END

  CLOSE rpt_cur

  DEALLOCATE rpt_cur

  FETCH ins_cur
  INTO @v_reporttypecode, @v_itemtype
END

RETURN

ErrorExit:

CLOSE rpt_cur
DEALLOCATE rpt_cur

CLOSE ins_cur
DEALLOCATE ins_cur
GO


