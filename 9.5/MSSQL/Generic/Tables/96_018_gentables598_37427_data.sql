DECLARE @datacode INT,
		@sortorder INT,
		@reldatacode INT,
		--Item Type cursor vars
		@itemtypekey	INT,
		@curdatasubcode INT,
		@curdatasub2code INT,
		@curitemtypecode INT,
		@curitemtypesubcode INT,
		@curdefaultind TINYINT,
		@cursortorder INT,
		@currelateddatacode INT,
		@curindicator1 TINYINT,
		@curtext1 VARCHAR(255)

SELECT @datacode = COALESCE(MAX(datacode), 0) + 1
FROM gentables
WHERE tableid = 598

SELECT @sortorder = COALESCE(sortorder, 0) + 1
FROM gentables
WHERE tableid = 598
  AND qsicode = 26

UPDATE gentables
SET sortorder = sortorder + 1
WHERE tableid = 598
  AND sortorder >= @sortorder

INSERT INTO gentables
(tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
 numericdesc1, gen2ind, lockbyqsiind, alternatedesc1, qsicode)
VALUES
(598, @datacode, 'New Related Projects use Update Wizard', 'N', @sortorder, 'CopyProjectDataGroups', 'Related Projects', 'QSIDBA', GETDATE(),
 1, 0, 1, 'Use Update Wizard to create New Related Projects then Relate other Projects depending on Project Relationship type', 27)

SELECT @reldatacode = datacode
FROM gentables
WHERE tableid = 598
  AND qsicode = 26

SELECT *
INTO #newitemtypes
FROM gentablesitemtype
WHERE tableid = 598
  AND datacode = @reldatacode

DECLARE curItemTypes CURSOR FAST_FORWARD FOR
SELECT datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind, sortorder, relateddatacode, indicator1, text1
FROM #newitemtypes

OPEN curItemTypes

FETCH NEXT FROM curItemTypes INTO @curdatasubcode, @curdatasub2code, @curitemtypecode, @curitemtypesubcode,
	@curdefaultind, @cursortorder, @currelateddatacode, @curindicator1, @curtext1

WHILE @@FETCH_STATUS = 0   
BEGIN   
    EXECUTE get_next_key 'QSIDBA', @itemtypekey OUTPUT

	INSERT INTO gentablesitemtype
	(gentablesitemtypekey, tableid, datacode, datasubcode, datasub2code, itemtypecode, itemtypesubcode, defaultind,
	 lastuserid, lastmaintdate, sortorder, relateddatacode, indicator1, text1)
	VALUES
	(@itemtypekey, 598, @datacode, @curdatasubcode, @curdatasub2code, @curitemtypecode, @curitemtypesubcode, @curdefaultind,
	 'QSIDBA', GETDATE(), @cursortorder, @currelateddatacode, @curindicator1, @curtext1)
	
	FETCH NEXT FROM curItemTypes INTO @curdatasubcode, @curdatasub2code, @curitemtypecode, @curitemtypesubcode,
		@curdefaultind, @cursortorder, @currelateddatacode, @curindicator1, @curtext1
END   

CLOSE curItemTypes   
DEALLOCATE curItemTypes