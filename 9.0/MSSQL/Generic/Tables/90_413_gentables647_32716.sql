DECLARE @v_next_datacode INT,
		@v_next_sortorder INT

SELECT @v_next_datacode = MAX(datacode)
FROM gentables
where tableid = 647

SET @v_next_datacode = COALESCE(@v_next_datacode, 0) + 1

SELECT @v_next_sortorder = MAX(sortorder) 
FROM gentables
WHERE tableid = 647

SET @v_next_sortorder = COALESCE(@v_next_sortorder, 0) + 1

IF NOT EXISTS(SELECT * FROM gentables WHERE tableid = 647 AND eloquencefieldtag = 'CLD_M_TITLEGRID')
BEGIN
	INSERT INTO gentables
	(tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, eloquencefieldtag)
	VALUES
	(647, @v_next_datacode, 'Title Grid', 'N', @v_next_sortorder, 'WebCatalogSectionDisplayType', 'Title Grid', 'QSIDBA', GETDATE(), 1, 0, 1, 0, 'CLD_M_TITLEGRID')

	SET @v_next_datacode = @v_next_datacode + 1
	SET @v_next_sortorder = @v_next_sortorder + 1
END

IF NOT EXISTS(SELECT * FROM gentables WHERE tableid = 647 AND eloquencefieldtag = 'CLD_M_TITLETABLE')
BEGIN
	INSERT INTO gentables
	(tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, eloquencefieldtag)
	VALUES
	(647, @v_next_datacode, 'Title Table', 'N', @v_next_sortorder, 'WebCatalogSectionDisplayType', 'Title Table', 'QSIDBA', GETDATE(), 1, 0, 1, 0, 'CLD_M_TITLETABLE')
END