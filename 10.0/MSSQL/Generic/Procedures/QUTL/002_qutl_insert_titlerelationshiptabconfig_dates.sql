
/****** Object:  StoredProcedure [dbo].[qutl_insert_titlerelationshiptabconfig_dates]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_titlerelationshiptabconfig_dates' ) 
drop procedure qutl_insert_titlerelationshiptabconfig_dates
go

CREATE PROCEDURE [dbo].[qutl_insert_titlerelationshiptabconfig_dates]
 (@i_relationtabqsicode			integer,
  @i_relationtabdatadesc		varchar (40),
  @i_itemqsicode				integer,
  @i_classqsicode				integer,
  @i_datedescription			varchar (40),
  @i_datetablabel				varchar (100),
  @i_dateqsicode				integer,
  @i_tabdate_order				integer,
  @o_titlerelationshipconfigkey   integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qutl_insert_titlerelationshiptabconfig_dates
**  Desc: This stored procedure searches to see if a the titlerelationshiptabconfig row exists 
**        for the item type/class/tab code sent.  If not, it will create it. Then it will find
**        the datetypecode for the date type based on qsicode, or date description
**        (in that order) and then update the taqrelationshiptab row for the datetype identified.  
**        The taqrelationshipconfigkey is returned.   
**    Auth: Uday A. Khisty
**    Date: 7 March 2017
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    
************************************************************************************************/

  DECLARE 
    @v_datetypecode         integer,
    @v_count                integer,
	@v_error_code			integer,
	@v_error_desc			varchar (2000)
	     
  SET @o_titlerelationshipconfigkey = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_count = 0    
  SET @v_error_code = 0
  SET @v_error_desc = ''
    
BEGIN
	
	
	--Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	exec qutl_insert_titlerelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
		  @o_titlerelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
		  RETURN
		END 

	  
	--Date Type Order must be between 1 and 6
	IF @i_tabdate_order < 1 OR @i_tabdate_order > 6 OR @i_tabdate_order IS NULL BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Tab Date Order must be between 1 and 6 '  
	  RETURN  
	 END
	  
 	--Find date type code 
   exec @v_datetypecode = qutl_get_datetypecode @i_dateqsicode, @i_datedescription
   IF @v_datetypecode = 0  BEGIN -- No datetypecode Found 
      SET @o_error_code = -1
	  SET @o_error_desc = 'Date Type Code not Found'  
	  RETURN 
      END  
 
   IF @i_tabdate_order = 1
       UPDATE titlerelationshiptabconfig SET date1label = @i_datetablabel, datetypecode1 = @v_datetypecode 
       WHERE @o_titlerelationshipconfigkey = titlerelationshiptabconfigkey
   ELSE IF @i_tabdate_order = 2
       UPDATE titlerelationshiptabconfig SET date2label = @i_datetablabel, datetypecode2 = @v_datetypecode 
       WHERE @o_titlerelationshipconfigkey = titlerelationshiptabconfigkey
   ELSE IF @i_tabdate_order = 3
       UPDATE titlerelationshiptabconfig SET date3label = @i_datetablabel, datetypecode3 = @v_datetypecode 
       WHERE @o_titlerelationshipconfigkey = titlerelationshiptabconfigkey      
   ELSE IF @i_tabdate_order = 4
       UPDATE titlerelationshiptabconfig SET date4label = @i_datetablabel, datetypecode4 = @v_datetypecode 
       WHERE @o_titlerelationshipconfigkey = titlerelationshiptabconfigkey   
    ELSE IF @i_tabdate_order = 3
       UPDATE titlerelationshiptabconfig SET date5label = @i_datetablabel, datetypecode5 = @v_datetypecode 
       WHERE @o_titlerelationshipconfigkey = titlerelationshiptabconfigkey   
    ELSE IF @i_tabdate_order = 3
       UPDATE titlerelationshiptabconfig SET date6label = @i_datetablabel, datetypecode6 = @v_datetypecode 
       WHERE @o_titlerelationshipconfigkey = titlerelationshiptabconfigkey   
       
   SELECT @v_error_code = @@ERROR
   IF @v_error_code <> 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'update to titlerelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END 
   
    RETURN   
    
END  --PROCEDURE END

GO
GRANT EXEC ON qutl_insert_titlerelationshiptabconfig_dates TO PUBLIC
GO



