SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_update_qsiconfigdetailtabs' ) 
     DROP PROCEDURE qutl_update_qsiconfigdetailtabs 
go

CREATE PROCEDURE [dbo].[qutl_update_qsiconfigdetailtabs]
 (@i_relateddatacode_old integer,
  @i_relateddatacode_new integer,
  @i_itemtypecode        integer,  
  @i_itemtypesubcode	 integer,
  @i_relationshiptabcode integer,   
  @o_error_code          integer OUTPUT,
  @o_error_desc			 varchar(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qutl_update_qsiconfigdetailtabs  
**  Desc: This stored procedure updates existing window views on qsiconfigdetailtabs
**        when the relateddatacode for item type filtering is changed for Web Relationship
**        Tab gentable (583). Relateddatacode is retrieved from Web Tab Group (tableid 680)      
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
	@v_count				integer,
	@v_count2				integer,
	@v_configobjectkey		integer,
	@v_itemtypedesc			varchar(40),
	@v_configobjectid_old	varchar (100),
	@v_configobjectid_new   varchar (100),
	@v_configdetailkey_new	integer,
	@v_configdetailkey_old	integer,
	@v_configobjectkey_old  integer,
	@v_configobjectkey_new	integer,
	@v_qsiwindowviewkey_old	integer,
	@v_qsiwindowviewkey_new	integer

BEGIN

	SET @v_count = 0
	SET @v_count2 = 0
	
	IF COALESCE(@i_relateddatacode_new,0) = 0 BEGIN
		SELECT @i_relateddatacode_new = datacode FROM gentables WHERE tableid = 680 AND qsicode = 1
	END
	-- Find configdetailkey from qsiconfigobjects/qsiconfigdetails for the old Web Tab Group
	IF COALESCE(@i_itemtypecode, 0) > 0 BEGIN
	   SELECT @v_itemtypedesc = datadesc FROM gentables WHERE tableid = 550 AND datacode = @i_itemtypecode
	END
	
	SET @v_configobjectid_old = @v_itemtypedesc + 'Tabgroup' + convert(varchar(30),@i_relateddatacode_old)
	
  SELECT @v_count = COUNT(*) FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid_old AND itemtypecode = @i_itemtypecode
	IF @v_count = 0 OR @v_count > 1 BEGIN
		SET @o_error_code = -1	
		SET @o_error_desc = 'Update to qsiconfigdetailtabs not done (old).  Either qsiconfigobjects row is missing or there is more than one row for ' + @v_configobjectid_old + ' for Item Type ' + @v_itemtypedesc
		RETURN
  END

  SELECT @v_configobjectkey_old = configobjectkey FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid_old AND itemtypecode = @i_itemtypecode

 	SET @v_configobjectid_new = @v_itemtypedesc + 'Tabgroup' + convert(varchar(30),@i_relateddatacode_new)
	
  SELECT @v_count = COUNT(*) FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid_new AND itemtypecode = @i_itemtypecode
	IF @v_count = 0 OR @v_count > 1 BEGIN
		SET @o_error_code = -1	
		SET @o_error_desc = 'Update to qsiconfigdetailtabs not done (new).  Either qsiconfigobjects row is missing or there is more than one row for ' + @v_configobjectid_new + ' for Item Type ' + @v_itemtypedesc
		RETURN
  END
	
	SELECT @v_configobjectkey_new = configobjectkey FROM qsiconfigobjects WHERE configobjectid = @v_configobjectid_new AND itemtypecode = @i_itemtypecode

  IF @i_itemtypesubcode > 0 BEGIN
 	  DECLARE configdetail_old_cur CURSOR FOR
		 SELECT COALESCE(d.configdetailkey,0), COALESCE(wv.qsiwindowviewkey,0) 
       FROM qsiconfigdetail d, qsiwindowview wv 
		  WHERE d.qsiwindowviewkey = wv.qsiwindowviewkey
        AND d.configobjectkey = @v_configobjectkey_old 
        AND wv.itemtypecode = @i_itemtypecode AND wv.usageclasscode = @i_itemtypesubcode
  END
  ELSE BEGIN
    -- no usage class so find all qsiconfigdetail rows for the item type
 	  DECLARE configdetail_old_cur CURSOR FOR
		 SELECT COALESCE(d.configdetailkey,0), COALESCE(wv.qsiwindowviewkey,0) 
       FROM qsiconfigdetail d, qsiwindowview wv  
		  WHERE d.qsiwindowviewkey = wv.qsiwindowviewkey
        AND d.configobjectkey = @v_configobjectkey_old
        AND wv.itemtypecode = @i_itemtypecode
  END

  OPEN configdetail_old_cur
	
	FETCH NEXT FROM configdetail_old_cur INTO @v_configdetailkey_old, @v_qsiwindowviewkey_old
	
	WHILE (@@FETCH_STATUS = 0) BEGIN
    SELECT @v_count = COUNT(*) FROM qsiconfigdetailtabs WHERE relationshiptabcode = @i_relationshiptabcode AND configdetailkey = @v_configdetailkey_old
    IF @v_count = 0 BEGIN
      -- qsiconfigdetailtabs row not found for old detail row
      goto GET_NEXT_DETAIL_OLD
    END
	  
    IF @i_itemtypesubcode > 0 BEGIN
 	    DECLARE configdetail_new_cur CURSOR FOR
		   SELECT COALESCE(d.configdetailkey,0), COALESCE(wv.qsiwindowviewkey,0) 
         FROM qsiconfigdetail d, qsiwindowview wv  
		    WHERE d.qsiwindowviewkey = wv.qsiwindowviewkey
          AND d.configobjectkey = @v_configobjectkey_new 
          AND wv.itemtypecode = @i_itemtypecode AND wv.usageclasscode = @i_itemtypesubcode
    END
    ELSE BEGIN
      -- no usage class so find all qsiconfigdetail rows for the item type
 	    DECLARE configdetail_new_cur CURSOR FOR
		   SELECT COALESCE(d.configdetailkey,0), COALESCE(wv.qsiwindowviewkey,0) 
         FROM qsiconfigdetail d, qsiwindowview wv 
		    WHERE d.qsiwindowviewkey = wv.qsiwindowviewkey
          AND d.configobjectkey = @v_configobjectkey_new
          AND wv.itemtypecode = @i_itemtypecode
    END

    OPEN configdetail_new_cur
	
	  FETCH NEXT FROM configdetail_new_cur INTO @v_configdetailkey_new, @v_qsiwindowviewkey_new
	
	  WHILE (@@FETCH_STATUS = 0) BEGIN  
      IF @v_configdetailkey_new > 0 AND @v_configdetailkey_old > 0 BEGIN
		    UPDATE qsiconfigdetailtabs
		       SET configdetailkey = @v_configdetailkey_new,
		           lastmaintdate = GETDATE()
		     WHERE relationshiptabcode = @i_relationshiptabcode 
		       AND configdetailkey = @v_configdetailkey_old  
       
		    SELECT @o_error_code = @@ERROR
		    IF @o_error_code <> 0 BEGIN
			    SET @o_error_code = -1	
			    SET @o_error_desc = 'Error occurred updating qsiconfigdetailtabs for ' + @v_configobjectid_new  
 	        CLOSE configdetail_new_cur 
	        DEALLOCATE configdetail_new_cur  
  	      CLOSE configdetail_old_cur 
  	      DEALLOCATE configdetail_old_cur  
			    RETURN
		    END   
	    END

  	  FETCH NEXT FROM configdetail_new_cur INTO @v_configdetailkey_new, @v_qsiwindowviewkey_new
    END

 	  CLOSE configdetail_new_cur 
	  DEALLOCATE configdetail_new_cur  

    GET_NEXT_DETAIL_OLD:
   	FETCH NEXT FROM configdetail_old_cur INTO @v_configdetailkey_old, @v_qsiwindowviewkey_old
  END
 
 	CLOSE configdetail_old_cur 
	DEALLOCATE configdetail_old_cur  

END

GO
GRANT EXEC ON qutl_update_qsiconfigdetailtabs TO PUBLIC
GO