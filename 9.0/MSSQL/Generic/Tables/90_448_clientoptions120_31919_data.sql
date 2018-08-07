IF NOT EXISTS (SELECT * FROM clientoptions WHERE optionid=120)
	INSERT INTO clientoptions
	       (optionid, optionname, optioncomment, optionvalue, lastuserid, lastmaintdate, optionmessage)
    VALUES (120, 'Auto Regenerate PO Rpt Details', 
    '1 will automatically regenerate PO Report details; 0 (default) will require users to click the regenerate button', 0, 'qsiadmin', getdate(), NULL) 
  
GO