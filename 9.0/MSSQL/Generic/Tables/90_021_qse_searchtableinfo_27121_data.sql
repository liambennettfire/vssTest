delete from qse_searchtableinfo
where searchitemcode = 14
go
-- for printings start with same data as projects
INSERT INTO qse_searchtableinfo (searchitemcode,tablename,jointoresultstablefrom,
  jointoresultstablewhere,tablekey1column,tablekey2column)
SELECT 14,tablename,jointoresultstablefrom,jointoresultstablewhere,tablekey1column,tablekey2column
  FROM qse_searchtableinfo
 WHERE searchitemcode = 3
go

INSERT INTO qse_searchtableinfo
  (searchitemcode, tablename, jointoresultstablefrom, jointoresultstablewhere)
VALUES
  (14, 'taqprojectprinting_view', 'taqprojectprinting_view', 'coreprojectinfo.projectkey = taqprojectprinting_view.taqprojectkey')
go


delete from qse_searchtableinfo
where tablename = 'temp_globalcontact'
go

DECLARE @v_searchitemcode INT

DECLARE searchtypecode_cur CURSOR FOR
	SELECT DISTINCT searchitemcode FROM qse_searchlist 
	WHERE searchtypecode IN (
				SELECT DISTINCT searchtypecode FROM qse_searchtypecriteria WHERE searchcriteriakey IN (
						SELECT detailcriteriakey FROM qse_searchcriteriadetail
						WHERE parentcriteriakey = 157)
							)
OPEN searchtypecode_cur

FETCH NEXT FROM searchtypecode_cur INTO @v_searchitemcode

WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
BEGIN
	INSERT INTO qse_searchtableinfo
	  (searchitemcode, tablename, jointoresultstablefrom, jointoresultstablewhere)
	VALUES
	  (@v_searchitemcode, 'temp_globalcontact', 'taqprojecttitle, titlecontacts, globalcontact', 'coreprojectinfo.projectkey = taqprojecttitle.taqprojectkey AND titlecontacts.bookkey = taqprojecttitle.bookkey AND titlecontacts.printingkey = taqprojecttitle.printingkey AND titlecontacts.contactkey = globalcontact.globalcontactkey')	
	FETCH NEXT FROM searchtypecode_cur INTO @v_searchitemcode
END

CLOSE searchtypecode_cur
DEALLOCATE searchtypecode_cur    
GO