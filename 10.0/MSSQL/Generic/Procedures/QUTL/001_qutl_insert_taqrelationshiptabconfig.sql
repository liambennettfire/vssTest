
/****** Object:  StoredProcedure [dbo].[qutl_insert_taqrelationshiptabconfig]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_taqrelationshiptabconfig' ) 
drop procedure qutl_insert_taqrelationshiptabconfig
go

CREATE PROCEDURE [dbo].[qutl_insert_taqrelationshiptabconfig]
 (@i_relationtabqsicode			integer,
  @i_relationtabdatadesc		varchar (40),
  @i_itemqsicode				integer,
  @i_classqsicode				integer,
  @o_taqrelationshipconfigkey   integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qutl_insert_taqrelationshiptabconfig
**  Desc: This stored procedure searches to see if a the taqrelationshiptabconfig row exists 
**        for the item type/class/tab code sent.  If not, it will create it and return the 
**        key. If it exists, it will simply return the key   
**    Auth: SLB
**    Date: 9 Jan 2015
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    
************************************************************************************************/

  DECLARE 
    @v_relationshiptabcode	integer,
	@v_itemcode				integer,
	@v_classcode			integer,
	@v_error_code			integer,
	@v_error_desc			varchar (2000)
	     
  SET @o_taqrelationshipconfigkey = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_relationshiptabcode =0
  SET @v_itemcode =NULL
  SET @v_classcode	= NULL			
  SET @v_error_code = 0
  SET @v_error_desc = ''
    
BEGIN
	--Find Relationship Tab Code
	exec @v_relationshiptabcode = qutl_get_gentables_datacode 583, @i_relationtabqsicode , @i_relationtabdatadesc
		  		  
  	IF @v_relationshiptabcode = 0  BEGIN
	  SET @o_error_code = -1
	  IF @i_relationtabqsicode is NULL or @i_relationtabdatadesc is NULL
  	      SET @o_error_desc = 'No relationship tab exists that matches on qsicode or datadesc'
  	  ELSE
  	      SET @o_error_desc = 'No relationship tab exists that matches on : qsicode=' + cast(@i_relationtabqsicode AS VARCHAR) +
		' or datadesc = ' + @i_relationtabdatadesc
	  RETURN
	END
	
	--Find config item/class (not required)
    exec qutl_get_item_class_datacodes_from_qsicodes @i_itemqsicode, @i_classqsicode,  @v_itemcode output, @v_classcode output,
         @v_error_code output,@v_error_desc output
	IF @v_error_code <> 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error finding item-class: item qsicode=' + cast(@i_itemqsicode AS VARCHAR)+ ', classqsicode = ' +  cast(@i_classqsicode AS VARCHAR)
	  RETURN
	END 
	
	--Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	IF @v_itemcode IS NULL and @v_classcode is NULL
	  SELECT TOP 1 @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey FROM taqrelationshiptabconfig
			WHERE @v_relationshiptabcode = relationshiptabcode AND itemtypecode IS NULL AND usageclass IS NULL 
	ELSE IF @v_itemcode IS NOT NULL and @v_classcode is NULL
	  SELECT TOP 1 @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey FROM taqrelationshiptabconfig
			WHERE @v_relationshiptabcode = relationshiptabcode AND @v_itemcode = itemtypecode AND usageclass IS NULL 
	ELSE  
	  SELECT @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey FROM taqrelationshiptabconfig
			WHERE @v_relationshiptabcode = relationshiptabcode AND @v_itemcode = itemtypecode AND @v_classcode = usageclass
			    	
	IF @o_taqrelationshipconfigkey = 0 BEGIN
	   EXEC dbo.get_next_key 'QSIDBA', @o_taqrelationshipconfigkey OUT
	   INSERT INTO taqrelationshiptabconfig (taqrelationshiptabconfigkey, relationshiptabcode, itemtypecode, usageclass, lastuserid, lastmaintdate)
           VALUES (@o_taqrelationshipconfigkey, @v_relationshiptabcode, @v_itemcode, @v_classcode, 'QSIDBA', getdate() )
       SELECT @v_error_code = @@ERROR
	   IF @v_error_code <> 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'insert to taqrelationshiptabconfig table had an error: relationship tab =' + cast(@i_relationtabdatadesc AS VARCHAR)
		  RETURN
	   END 
	END --insert into taqrelationshiptabconfig  
	


    
END  --PROCDURE END

GO


