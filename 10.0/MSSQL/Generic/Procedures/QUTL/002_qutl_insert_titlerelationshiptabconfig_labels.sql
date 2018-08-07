
/****** Object:  StoredProcedure [dbo].[qutl_insert_titlerelationshiptabconfig_labels]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_titlerelationshiptabconfig_labels' ) 
drop procedure qutl_insert_titlerelationshiptabconfig_labels
go

/***********************************************************************************************
**  Name: qutl_insert_titlerelationshiptabconfig_labels
**  Desc: This stored procedure searches to see if a the titlerelationshiptabconfig row exists for the item 
**        type/class/tab code sent. If not, it will create it. Then it will update all of the labels and indicators 
**        based on parameters sent.
**    Auth: Uday A. Khisty
**    Date: 7 March 2017
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    
************************************************************************************************/

CREATE PROCEDURE [dbo].[qutl_insert_titlerelationshiptabconfig_labels]
 (@i_relationtabqsicode			integer,
  @i_relationtabdatadesc		varchar (40),
  @i_itemqsicode				integer,
  @i_classqsicode				integer,
  @i_decimal1label				varchar(100),
  @i_decimal2label				varchar(100),
  @i_miscitem1label				varchar(100),
  @i_miscitem2label				varchar(100),
  @i_miscitem3label				varchar(100),
  @i_miscitem4label				varchar(100),
  @i_miscitem5label				varchar(100),
  @i_miscitem6label				varchar(100),
  @i_date1label					varchar(100),
  @i_date2label					varchar(100),
  @i_date3label					varchar(100),
  @i_date4label					varchar(100),
  @i_date5label					varchar(100),
  @i_date6label					varchar(100),
  @i_price1label				varchar(100),
  @i_price2label				varchar(100),
  @i_price3label				varchar(100),
  @i_price4label				varchar(100),
  @i_hideproductnumberind		tinyint,
  @i_hideitemnumberind			tinyint,
  @i_hidetitleind				tinyint,
  @i_hideauthorind				tinyint,
  @i_hidemediaformatind			tinyint,
  @i_hidebisacstatusind			tinyint,
  @i_hideeditionind				tinyint,
  @i_hidepubdateind				tinyint,
  @i_hidepriceind				tinyint,
  @i_hidepublisherind			tinyint,
  @i_hideprimaryind				tinyint,
  @i_hidepropagateinfoind		tinyint,
  @i_hidesumulpubind			tinyint,
  @i_hideillustrationind		tinyint,
  @i_hiderptind					tinyint,
  @i_hidepagecntind				tinyint,
  @i_hidebookposind				tinyint,
  @i_hidelifetodateposind		tinyint,
  @i_hideyeartodateposind		tinyint,
  @i_hideprevyearposind			tinyint,
  @i_hideproscommentind			tinyint,
  @i_hideconscommentind			tinyint,
  @i_hidesortorderind			tinyint,
  @i_hideqtyind					tinyint,
  @i_hidevolumeind				tinyint,
  @o_titlerelationshipconfigkey integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qutl_insert_titlerelationshiptabconfig_labels
**  Desc: This stored procedure searches to see if a the titlerelationshiptabconfig row exists 
**        for the item type/class/tab code sent.  If no, it will create it. Then it will update
**        all of the labels and indicators based on parameters sent.   
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
    @v_misckey              integer,
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
	
	
	--Find if titlerelationshipconfig row exists for this tab/item/class; if not insert it
	exec qutl_insert_titlerelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
		  @o_titlerelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
		  RETURN
		END 

   UPDATE titlerelationshiptabconfig
   SET decimal1label = @i_decimal1label,
	   decimal2label = @i_decimal2label,
	   miscitem1label = @i_miscitem1label,
	   miscitem2label = @i_miscitem2label,
	   miscitem3label = @i_miscitem3label,
	   miscitem4label = @i_miscitem4label,
	   miscitem5label = @i_miscitem5label,
	   miscitem6label = @i_miscitem6label,
	   date1label	  = @i_date1label,
	   date2label	  = @i_date2label,
	   date3label	  = @i_date3label,
	   date4label	  = @i_date4label,
	   date5label	  = @i_date5label,
	   date6label	  = @i_date6label,
	   price1label    = @i_price1label,
	   price2label    = @i_price2label,
	   price3label    = @i_price3label,
	   price4label    = @i_price4label,
	   hideproductnumberind = @i_hideproductnumberind,
	   hideitemnumberind = @i_hideitemnumberind,
	   hidetitleind = @i_hidetitleind,
	   hideauthorind = @i_hideauthorind,
	   hidemediaformatind = @i_hidemediaformatind,
	   hidebisacstatusind = @i_hidebisacstatusind,
	   hideeditionind = @i_hideeditionind,
	   hidepubdateind = @i_hidepubdateind,
	   hidepriceind = @i_hidepriceind,
	   hidepublisherind = @i_hidepublisherind,
	   hideprimaryind = @i_hideprimaryind,
	   hidepropagateinfoind = @i_hidepropagateinfoind,
	   hidesumulpubind = @i_hidesumulpubind,
	   hideillustrationind = @i_hideillustrationind,
	   hiderptind = @i_hiderptind,
	   hidepagecntind = @i_hidepagecntind,
	   hidebookposind = @i_hidebookposind,
	   hidelifetodateposind = @i_hidelifetodateposind,
	   hideyeartodateposind = @i_hideyeartodateposind,
	   hideprevyearposind = @i_hideprevyearposind,
	   hideproscommentind = @i_hideproscommentind,
	   hideconscommentind = @i_hideconscommentind,
	   hidesortorderind = @i_hidesortorderind,
	   hidevolumeind = @i_hidevolumeind
   WHERE titlerelationshiptabconfigkey = @o_titlerelationshipconfigkey
       
   SELECT @v_error_code = @@ERROR
   IF @v_error_code <> 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'update to titlerelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END 
   
    RETURN   
    
END  --PROCEDURE END

GO