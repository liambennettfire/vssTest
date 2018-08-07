
/****** Object:  StoredProcedure [dbo].[qutl_insert_taqrelationshiptabconfig_productids]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_taqrelationshiptabconfig_productids' ) 
drop procedure qutl_insert_taqrelationshiptabconfig_productids
go

CREATE PROCEDURE [dbo].[qutl_insert_taqrelationshiptabconfig_productids]
 (@i_relationtabqsicode			integer,
  @i_relationtabdatadesc		varchar (40),
  @i_itemqsicode				integer,
  @i_classqsicode				integer,
  @i_datadesc					varchar (40),
  @i_productidlabel				varchar (40),
  @i_qsicode					integer,
  @i_tabprodid_order			integer,
  @o_taqrelationshipconfigkey   integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qutl_insert_taqrelationshiptabconfig_productids
**  Desc: This stored procedure searches to see if a the taqrelationshiptabconfig row exists 
**        for the item type/class/tab code sent.  If no, it will create it. Then it will find
**        the misc keys for the misc item based on qsicode or data desc
**        (in that order) and then update the taqrelationshiptab row for the product id identified.  
**        The taqrelationshipconfigkey is returned.   
**    Auth: SLB
**    Date: 9 Jul 2015
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    
************************************************************************************************/

  DECLARE 
    @v_datacode             integer,
    @v_count                integer,
	@v_error_code			integer,
	@v_error_desc			varchar (2000)
	     
  SET @o_taqrelationshipconfigkey = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_count = 0    
  SET @v_error_code = 0
  SET @v_error_desc = ''
    
BEGIN
	
	
	--Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
		  @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
		  RETURN
		END 

	  
	--Product ID Type must be between 1 and 6
	IF @i_tabprodid_order < 1 OR @i_tabprodid_order > 2 OR @i_tabprodid_order IS NULL BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Tab Product ID Order must be between 1 and 2 '  
	  RETURN  
	 END
	  
 	--Find datacode 
   exec @v_datacode = qutl_get_gentables_datacode 594, @i_qsicode, @i_datadesc
   IF @v_datacode = 0  BEGIN -- No Datacode Found 
      SET @o_error_code = -1
	  SET @o_error_desc = 'Datacode not Found'  
	  RETURN 
      END  
 
   IF @i_tabprodid_order = 1
       UPDATE taqrelationshiptabconfig SET Productid1label = @i_productidlabel, Productidcode1 = @v_datacode 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey
   ELSE IF @i_tabprodid_order = 2
       UPDATE taqrelationshiptabconfig SET Productid2label = @i_productidlabel, Productidcode2 = @v_datacode 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey
    
       
   SELECT @v_error_code = @@ERROR
   IF @v_error_code <> 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END 
   
    RETURN   
    
END  --PROCEDURE END
GO
GRANT EXEC ON qutl_insert_taqrelationshiptabconfig_productids TO PUBLIC
GO



