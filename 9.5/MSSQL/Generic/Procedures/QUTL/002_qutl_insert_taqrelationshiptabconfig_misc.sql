IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_taqrelationshiptabconfig_misc' ) 
     DROP PROCEDURE qutl_insert_taqrelationshiptabconfig_misc 
GO

CREATE PROCEDURE [dbo].[qutl_insert_taqrelationshiptabconfig_misc]
 (@i_relationtabqsicode			integer,
  @i_relationtabdatadesc		varchar (40),
  @i_itemqsicode				integer,
  @i_classqsicode				integer,
  @i_miscname					varchar (40),
  @i_misctablabel				varchar (40),
  @i_miscqsicode				integer,
  @i_miscfiredistkey			integer,
  @i_tabmisc_order				integer,
  @o_taqrelationshipconfigkey   integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qutl_insert_taqrelationshiptabconfig_misc
**  Desc: This stored procedure searches to see if a the taqrelationshiptabconfig row exists 
**        for the item type/class/tab code sent.  If no, it will create it. Then it will find
**        the misc keys for the misc item based on qsicode, firedistkey, or misc name
**        (in that order) and then update the taqrelationshiptab row for the miscitem identified.  
**        The taqrelationshipconfigkey is returned.   
**    Auth: SLB
**    Date: 9 Jan 2015
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:        Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    7/30/16      SLB	          Fixed issue with misc item 5 and 6
************************************************************************************************/

  DECLARE 
    @v_misckey              integer,
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

	  
	--Misc Type must be between 1 and 6
	IF @i_tabmisc_order < 1 OR @i_tabmisc_order > 6 OR @i_tabmisc_order IS NULL BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Tab Misc Order must be between 1 and 6 '  
	  RETURN  
	 END
	  
 	--Find misc item key 
   exec @v_misckey = qutl_get_misckey @i_miscqsicode, @i_miscfiredistkey, @i_miscname
   IF @v_misckey = 0  BEGIN -- No Misckey Found 
      SET @o_error_code = -1
	  SET @o_error_desc = 'Misc item not Found'  
	  RETURN 
      END  
 
   IF @i_tabmisc_order = 1
       UPDATE taqrelationshiptabconfig SET miscitem1label = @i_misctablabel, miscitemkey1 = @v_misckey 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey
   ELSE IF @i_tabmisc_order = 2
       UPDATE taqrelationshiptabconfig SET miscitem2label = @i_misctablabel, miscitemkey2 = @v_misckey 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey
   ELSE IF @i_tabmisc_order = 3
       UPDATE taqrelationshiptabconfig SET miscitem3label = @i_misctablabel, miscitemkey3 = @v_misckey 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey      
   ELSE IF @i_tabmisc_order = 4
       UPDATE taqrelationshiptabconfig SET miscitem4label = @i_misctablabel, miscitemkey4 = @v_misckey 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey   
    ELSE IF @i_tabmisc_order = 5
       UPDATE taqrelationshiptabconfig SET miscitem5label = @i_misctablabel, miscitemkey5 = @v_misckey 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey   
    ELSE IF @i_tabmisc_order = 6
       UPDATE taqrelationshiptabconfig SET miscitem6label = @i_misctablabel, miscitemkey6 = @v_misckey 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey   
       
   SELECT @v_error_code = @@ERROR
   IF @v_error_code <> 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END 
   
    RETURN   
    
END  --PROCEDURE END


GO


GRANT EXEC ON qutl_insert_taqrelationshiptabconfig_misc TO PUBLIC
GO