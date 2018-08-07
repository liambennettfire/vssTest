-- for Specification Templates start with same data as projects

IF NOT EXISTS (SELECT * FROM qse_searchtableinfo WHERE searchitemcode = 5 and tablename = 'qse_searchresults') BEGIN
	INSERT INTO qse_searchtableinfo (searchitemcode,tablename,jointoresultstablefrom,
	  jointoresultstablewhere,tablekey1column,tablekey2column)
	SELECT 5,tablename,jointoresultstablefrom,jointoresultstablewhere,tablekey1column,tablekey2column
	  FROM qse_searchtableinfo
	 WHERE searchitemcode = 3 and tablename = 'qse_searchresults'
 END
go

IF NOT EXISTS (SELECT * FROM qse_searchtableinfo WHERE searchitemcode = 5 and tablename = 'taqprojecttask') BEGIN
	INSERT INTO qse_searchtableinfo (searchitemcode,tablename,jointoresultstablefrom,
	  jointoresultstablewhere,tablekey1column,tablekey2column)
	SELECT 5,tablename,jointoresultstablefrom,jointoresultstablewhere,tablekey1column,tablekey2column
	  FROM qse_searchtableinfo
	 WHERE searchitemcode = 3 and tablename = 'taqprojecttask'
END
go

IF NOT EXISTS (SELECT * FROM qse_searchtableinfo WHERE searchitemcode = 5 and tablename = 'taqprojectorgentry') BEGIN
	INSERT INTO qse_searchtableinfo (searchitemcode,tablename,jointoresultstablefrom,
	  jointoresultstablewhere,tablekey1column,tablekey2column)
	SELECT 5,tablename,jointoresultstablefrom,jointoresultstablewhere,tablekey1column,tablekey2column
	  FROM qse_searchtableinfo
	 WHERE searchitemcode = 3 and tablename = 'taqprojectorgentry'
END
go


IF NOT EXISTS (SELECT * FROM qse_searchtableinfo WHERE searchitemcode = 5 and tablename = 'taqversionformat') BEGIN
	INSERT INTO qse_searchtableinfo
	  (searchitemcode, tablename, jointoresultstablefrom, jointoresultstablewhere)
	VALUES
	  (5, 'taqversionformat', 'taqversionformat', 'coreprojectinfo.projectkey = taqversionformat.taqprojectkey')
END  
go

--INSERT INTO qse_searchtableinfo
--  (searchitemcode, tablename, jointoresultstablefrom, jointoresultstablewhere)
--VALUES
--  (16, 'taqversionformat', 'taqversionformat,taqprojecttitle', 'coreprojectinfo.projectkey = taqversionformat.taqprojectkey AND taqprojecttitle.taqprojectkey = taqversionformat.taqprojectkey AND taqprojecttitle.mediatypecode =  taqversionformat.mediatypecode AND taqprojecttitle.mediatypesubcode = taqversionformat.mediatypesubcode')
--go