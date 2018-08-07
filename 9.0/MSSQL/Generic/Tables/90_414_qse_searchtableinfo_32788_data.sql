UPDATE qse_searchtableinfo 
SET jointoresultstablefrom = 'taqprojecttask', 
	jointoresultstablewhere = 'taqprojectprinting_view.bookkey = taqprojecttask.bookkey AND taqprojectprinting_view.printingkey = taqprojecttask.printingkey'
WHERE searchitemcode = 14 AND
      UPPER(tablename) = UPPER('taqprojecttask')
      
GO      