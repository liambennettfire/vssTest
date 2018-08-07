UPDATE clientoptions
   SET optionname = 'Updt Act Date When PO Final',
       lastuserid = 'FB_UPDATE_45162',
	   lastmaintdate = getdate()
 WHERE optionid = 54
   AND optionname = 'Update Actual Date when PO Finalized'
GO