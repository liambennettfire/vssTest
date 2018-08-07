SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_delete_qsiconfigdetail_rows' ) 
     DROP PROCEDURE qutl_delete_qsiconfigdetail_rows 
go

CREATE PROCEDURE [dbo].[qutl_delete_qsiconfigdetail_rows]
 (@i_tabgroupdatacode	 integer,
  @i_itemtypecode        integer,  
  @i_usageclasscode	 integer, 
  @o_error_code          integer OUTPUT,
  @o_error_desc			 varchar(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qutl_delete_qsiconfigdetail_rows  
**  Desc: This stored procedure deletes associated qsiconfigdetail rows for any window view 
**		  with the item/classes(s) when an item type value is removed  
**   Auth: Kusum
**   Date: 8 July 2016
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:         Author:        Description:
**    --------      --------       --------------------------------------------------------
**    09/09/16      Uday		   Case 40327
********************************************************************************************/

DECLARE 
@v_count			integer,
@v_count2           integer,
@v_configobjectkey	integer,
@v_itemtypedesc		varchar(40),
@v_configobjectid	varchar (100)

BEGIN
	SET @v_count = 0
	SET @v_count2 = 0
	
	IF COALESCE(@i_tabgroupdatacode,0) = 0 OR  COALESCE(@i_itemtypecode,0) = 0 BEGIN
		RETURN
	END
	
	IF COALESCE(@i_itemtypecode, 0) > 0 BEGIN
		SELECT @v_itemtypedesc = datadesc FROM gentables WHERE tableid = 550 AND datacode = @i_itemtypecode
	END
	
	SET @v_configobjectid = @v_itemtypedesc + 'Tabgroup' + convert(varchar(30),@i_tabgroupdatacode)
	
	SELECT @v_count = COUNT(*) FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid AND itemtypecode = @i_itemtypecode
	
	IF @v_count = 1 BEGIN
		SELECT @v_configobjectkey = configobjectkey FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid AND itemtypecode = @i_itemtypecode
		
		IF COALESCE(@i_usageclasscode,0) = 0 BEGIN
			SELECT @v_count2 = COUNT(*) FROM qsiconfigdetail 
			WHERE configobjectkey = @v_configobjectkey
			
			IF @v_count2 > 0 BEGIN			
				DELETE FROM  qsiconfigdetail
				WHERE configdetailkey IN (SELECT configdetailkey 
											FROM qsiconfigdetail 
											WHERE configobjectkey = @v_configobjectkey)
					
				SELECT @o_error_code = @@ERROR
				IF @o_error_code <> 0 BEGIN
					SET @o_error_code = -1	
					SET @o_error_desc = 'Error occurred deleting into qsiconfigdetail for ' + @v_configobjectid  
					RETURN
				END		
			END				
		END	
		ELSE BEGIN
			SELECT @v_count2 = COUNT(*) FROM qsiconfigdetail 
			WHERE configobjectkey = @v_configobjectkey AND usageclasscode = @i_usageclasscode
			
			IF @v_count2 > 0 BEGIN			
				DELETE FROM  qsiconfigdetail
				WHERE configdetailkey IN (SELECT configdetailkey 
											FROM qsiconfigdetail 
											WHERE configobjectkey = @v_configobjectkey AND usageclasscode = @i_usageclasscode)
					
				SELECT @o_error_code = @@ERROR
				IF @o_error_code <> 0 BEGIN
					SET @o_error_code = -1	
					SET @o_error_desc = 'Error occurred deleting into qsiconfigdetail for ' + @v_configobjectid  
					RETURN
				END		
			END						
		END			
	END 	
END

GO
GRANT EXEC ON qutl_delete_qsiconfigdetail_rows TO PUBLIC
GO