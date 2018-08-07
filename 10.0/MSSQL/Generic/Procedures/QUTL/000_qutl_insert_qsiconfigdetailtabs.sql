SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_qsiconfigdetailtabs' ) 
     DROP PROCEDURE qutl_insert_qsiconfigdetailtabs 
go

CREATE PROCEDURE [dbo].[qutl_insert_qsiconfigdetailtabs]
 (@i_relateddatacode	 integer,
  @i_itemtypecode        integer,  
  @i_itemtypesubcode	 integer,
  @i_relationshiptabcode integer, 
  @i_sortorder           integer, 
  @o_error_code          integer OUTPUT,
  @o_error_desc			 varchar(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qutl_insert_qsiconfigdetailtabs  
**  Desc: This stored procedure will insert into qsiconfigdetailtabs when a new row
**        is added to the Web Relationship tab gentable (tableid 583) 
**    Auth: Kusum
**    Date: 12 July 2016
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:         Author:        Description:
**    --------      --------       --------------------------------------------------------
**    2016-11-30    Joshua Granville Cursor was not being closed or deallocated, causing errors
**										saying it already exists CASE: 41972
**    2017-12-01    Colman         Case 48604 Issues inserting title tabs to main title relationship group
********************************************************************************************/
	DECLARE 
	@v_count			integer,
	@v_count2           integer,
	@v_count3           integer,
	@v_configobjectkey	integer,
	@v_itemtypedesc		varchar(40),
	@v_configobjectid	varchar (100),
	@v_configdetailkey  integer,
	@v_configdetailkey_old integer,
	@v_qsiwindowviewkey	integer,
	@v_windowviewkey_old integer,
  @v_relateddatacode integer,
  @v_titletabind integer

BEGIN
	SET @v_count = 0
	SET @v_count2 = 0
	SET @v_count3 = 0 
	
	IF COALESCE(@i_relateddatacode,0) = 0 BEGIN
		SELECT @i_relateddatacode = datacode FROM gentables WHERE tableid = 680 AND qsicode = 1
	END
	
  SET @v_relateddatacode = @i_relateddatacode
  SET @v_titletabind = 0

  IF @i_itemtypecode = 1 AND @i_relateddatacode = 2 -- Main Title Relationship Group
  BEGIN
	  SET @v_itemtypedesc = 'TitleRelationships'
    SET @v_relateddatacode = 1
    SET @v_titletabind = 1
  END
	ELSE IF COALESCE(@i_itemtypecode, 0) > 0
	   SELECT @v_itemtypedesc = datadesc FROM gentables WHERE tableid = 550 AND datacode = @i_itemtypecode
	
	SET @v_configobjectid = @v_itemtypedesc + 'Tabgroup' + convert(varchar(30),@v_relateddatacode)
	
	SELECT @v_count = COUNT(*) FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid AND itemtypecode = @i_itemtypecode
	
	IF @v_count = 1 BEGIN
		SELECT @v_configobjectkey = configobjectkey FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid AND itemtypecode = @i_itemtypecode
		
		SELECT @v_count2 = COUNT(*) FROM qsiconfigdetail WHERE configobjectkey = @v_configobjectkey AND (usageclasscode = @i_itemtypesubcode OR COALESCE(usageclasscode, 0) = 0)
	
		IF @v_count2 > 0 BEGIN

			DECLARE detail_cur CURSOR FOR
			SELECT configdetailkey, qsiwindowviewkey
			FROM qsiconfigdetail 
			WHERE configobjectkey = @v_configobjectkey AND (usageclasscode = @i_itemtypesubcode OR COALESCE(usageclasscode, 0) = 0)
			
			OPEN detail_cur

			FETCH NEXT FROM detail_cur INTO @v_configdetailkey, @v_qsiwindowviewkey
	
			WHILE (@@FETCH_STATUS = 0) BEGIN
				SELECT @v_count3 = COUNT(*)
				FROM qsiconfigdetailtabs
				WHERE configdetailkey = @v_configdetailkey AND relationshiptabcode = @i_relationshiptabcode
			
				IF @v_count3 = 0 BEGIN
					INSERT INTO qsiconfigdetailtabs (configdetailkey, relationshiptabcode, sortorder, titletabind, lastuserid, lastmaintdate)
						VALUES(@v_configdetailkey,@i_relationshiptabcode,@i_sortorder,@v_titletabind,'QSIDBA',GETDATE())
					
					SELECT @o_error_code = @@ERROR
					IF @o_error_code <> 0 BEGIN
	  					SET @o_error_code = -1	
						SET @o_error_desc = 'Error occurred inserting into qsiconfigdetailtabs for ' + @v_configobjectid  
						RETURN
					END	
				END

				FETCH NEXT FROM detail_cur INTO @v_configdetailkey, @v_qsiwindowviewkey
			END
			CLOSE detail_cur
			DEALLOCATE detail_cur
		END
	END 
	
END

GO
GRANT EXEC ON qutl_insert_qsiconfigdetailtabs TO PUBLIC
GO