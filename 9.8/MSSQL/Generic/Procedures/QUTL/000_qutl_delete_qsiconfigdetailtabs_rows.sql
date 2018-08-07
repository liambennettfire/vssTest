SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_delete_qsiconfigdetailtabs_rows' ) 
     DROP PROCEDURE qutl_delete_qsiconfigdetailtabs_rows 
go

CREATE PROCEDURE [dbo].[qutl_delete_qsiconfigdetailtabs_rows]
 (@i_relateddatacode	 integer,
  @i_itemtypecode        integer,  
  @i_itemtypesubcode	 integer,
  @i_relationshiptabcode integer, 
  @i_sortorder           integer, 
  @o_error_code          integer OUTPUT,
  @o_error_desc			 varchar(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qutl_delete_qsiconfigdetailtabs_rows  
**  Desc: This stored procedure will insert into qsiconfigdetailtabs when a new row
**        is added to the Web Relationship tab gentable (tableid 583) 
**    Auth: Kusum
**    Date: 12 July 2016
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:         Author:        Description:
**    --------      --------       --------------------------------------------------------
**    
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
	@v_windowviewkey_old integer

BEGIN

	SET @v_count = 0
	SET @v_count2 = 0
	SET @v_count3 = 0 
	
	IF COALESCE(@i_relateddatacode,0) = 0 BEGIN
		SELECT @i_relateddatacode = datacode FROM gentables WHERE tableid = 680 AND qsicode = 1
	END 
	
	IF COALESCE(@i_itemtypecode, 0) > 0 BEGIN
	   SELECT @v_itemtypedesc = datadesc FROM gentables WHERE tableid = 550 AND datacode = @i_itemtypecode
	END
	
	SET @v_configobjectid = @v_itemtypedesc + 'Tabgroup' + convert(varchar(30),@i_relateddatacode)
	
	SELECT @v_count = COUNT(*) FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid AND itemtypecode = @i_itemtypecode
	
	IF @v_count = 1 BEGIN
		SELECT @v_configobjectkey = configobjectkey FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid AND itemtypecode = @i_itemtypecode
		
		SELECT @v_count2 = COUNT(*) FROM qsiconfigdetail WHERE configobjectkey = @v_configobjectkey AND usageclasscode = @i_itemtypesubcode
	
		IF @v_count2 = 1 BEGIN
			SELECT @v_configdetailkey = configdetailkey, @v_qsiwindowviewkey = qsiwindowviewkey FROM qsiconfigdetail 
			 WHERE configobjectkey = @v_configobjectkey AND usageclasscode = @i_itemtypesubcode
			 
			SELECT @v_count3 = COUNT(*) FROM qsiconfigdetailtabs
				WHERE configdetailkey = @v_configdetailkey AND relationshiptabcode = @i_relationshiptabcode
			
			IF @v_count3 > 0 BEGIN 
				DELETE FROM qsiconfigdetailtabs WHERE configdetailkey = @v_configdetailkey AND relationshiptabcode = @i_relationshiptabcode
					
				SELECT @o_error_code = @@ERROR
			    IF @o_error_code <> 0 BEGIN
	  				SET @o_error_code = -1	
					SET @o_error_desc = 'Error occurred deleting from qsiconfigdetailtabs for ' + @v_configobjectid  
					RETURN
				END	
			END
		END
	END 
	
END

GO
GRANT EXEC ON qutl_delete_qsiconfigdetailtabs_rows TO PUBLIC
GO