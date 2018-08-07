
/****** Object:  StoredProcedure [dbo].[qutl_get_item_class_datacodes_from_qsicodes]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_get_item_class_datacodes_from_qsicodes' ) 
drop procedure qutl_get_item_class_datacodes_from_qsicodes
go

CREATE PROCEDURE [dbo].[qutl_get_item_class_datacodes_from_qsicodes]
 (@i_itemqsicode				integer,
  @i_classqsicode				integer,
  @o_itemcode				    integer output,
  @o_classcode					integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qutl_get_item_class_datacodes_from_qsicodes
**  Desc: This stored procedure finds item type datacode and the usage class datasubcode based
**        on parameters sent.  IF none found, NULLs are returned 
**    Auth: SLB
**    Date: 9 Jan 2015
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    
************************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''

    
BEGIN
	--Find Item and Class Data Codes

	IF (@i_itemqsicode = 0 or @i_itemqsicode IS NULL) AND (@i_classqsicode = 0 OR @i_classqsicode IS NULL)  BEGIN
	  SET @o_itemcode = NULL
	  SET @o_classcode = NULL
	  RETURN
	END  --item/class not part of config
	  
    IF @i_classqsicode = 0 OR @i_classqsicode IS NULL   BEGIN
	--Item exists but not Class 
	    SET @o_classcode = NULL 
   	    SELECT @o_itemcode = datacode FROM gentables WHERE (tableid = 550 AND qsicode = @i_itemqsicode) 
        IF @o_itemcode = 0 or @o_itemcode IS NULL  BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'No item type exists that matches on : qsicode=' + cast(@i_itemqsicode AS VARCHAR)
		  RETURN      
	    END
	    RETURN
	  END --Item exists but not Class 
	 
	  --Item and Class exists
	  SELECT @o_itemcode = datacode, @o_classcode = datasubcode FROM subgentables WHERE (tableid = 550 AND qsicode = @i_classqsicode) 
      IF @o_classcode = 0 or @o_classcode IS NULL  BEGIN
	    SET @o_error_code = -1
	    SET @o_error_desc = 'No class exists that matches on : qsicode=' + cast(@i_classqsicode AS VARCHAR) 
	    RETURN      	  
	  END	  	  
    
END

GO


