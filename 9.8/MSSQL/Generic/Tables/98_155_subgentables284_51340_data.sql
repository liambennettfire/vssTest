DECLARE @v_count INT
DECLARE @v_datadesc VARCHAR(255)
DECLARE @v_message VARCHAR(255)

IF EXISTS(SELECT * FROM subgentables WHERE tableid=284 AND eloquencefieldtag = 'AI' AND deletestatus = 'N') BEGIN -- Author 
	SELECT @v_datadesc = datadesc FROM subgentables WHERE tableid=284 AND eloquencefieldtag = 'AI' AND deletestatus = 'N'

	SELECT @v_count = COUNT(*) FROM subgentables WHERE tableid=284 AND eloquencefieldtag = 'AI' AND deletestatus = 'N'

	IF @v_count = 1 BEGIN
	    SET @v_message = 'One row found for: ' + @v_datadesc + ' on subgentables table 284. Qsicode will be updated.'
		PRINT @v_message
		UPDATE subgentables
		   SET qsicode = 1, lastmaintdate = getdate(), lastuserid = 'FB_51340_UPDATE'
		 WHERE tableid = 284 AND eloquencefieldtag = 'AI'  AND deletestatus = 'N'
	END
	ELSE BEGIN
	    SET @v_message = 'Unable to update qsicode for ' + @v_datadesc + '  on subgentables table 284. More than one match found for datadesc.'
		PRINT @v_message
    RETURN 
  END
END
GO