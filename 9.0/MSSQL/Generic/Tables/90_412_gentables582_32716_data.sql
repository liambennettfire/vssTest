DECLARE @v_nextdatacode	INT

SELECT @v_nextdatacode = MAX(datacode) + 1
FROM gentables
WHERE tableid = 582

IF (EXISTS(SELECT * FROM gentables WHERE tableid = 582 AND datadesc = 'Child Section - Browse' AND qsicode IS NULL))
BEGIN
	UPDATE gentables
	SET qsicode = 31
	WHERE tableid = 582 AND
		datadesc = 'Child Section - Browse' AND
		qsicode IS NULL
END
ELSE IF (NOT EXISTS(SELECT * FROM gentables WHERE tableid = 582 AND qsicode = 31))
BEGIN
	INSERT INTO gentables
	(tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode)
	VALUES
	(582, @v_nextdatacode, 'Child Section - Browse', 'N', 1, 'ProjectRelationship', 'Browse', 'QSIDBA', GETDATE(), 0, 0, 31)
END