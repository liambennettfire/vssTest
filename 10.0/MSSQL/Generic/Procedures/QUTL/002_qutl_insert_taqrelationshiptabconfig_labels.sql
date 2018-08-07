
/****** Object:  StoredProcedure [dbo].[qutl_insert_taqrelationshiptabconfig_labels]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_taqrelationshiptabconfig_labels' ) 
drop procedure qutl_insert_taqrelationshiptabconfig_labels
go


CREATE PROCEDURE [dbo].[qutl_insert_taqrelationshiptabconfig_labels]
 (@i_relationtabqsicode			integer,
  @i_relationtabdatadesc		varchar (40),
  @i_itemqsicode				integer,
  @i_classqsicode				integer,
  @i_qty1label					varchar (40),
  @i_qty2label					varchar (40),
  @i_qty3label					varchar (40),
  @i_qty4label					varchar (40),
  @i_ind1label					varchar (40),
  @i_ind2label					varchar (40),
  @i_tableid1					integer,
  @i_tablelabel1				varchar (40),
  @i_tableid2					integer,
  @i_tablelabel2				varchar (40),
  @i_tableid3					integer,
  @i_tablelabel3				varchar (40),
  @i_tableid4					integer,
  @i_tablelabel4				varchar (40),
  @i_hidefiltersind				integer,
  @i_hideclassind				integer,
  @i_hidetypeind				integer,
  @i_hidethisrelind				integer,
  @i_hideotherrelind			integer,
  @i_hidenotesind				integer,
  @i_hideownerind				integer,
  @i_hideparticipantsind		integer,
  @i_adddrelateditemind			integer,
  @i_hidedeletebuttonind        integer,
  @o_taqrelationshipconfigkey   integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qutl_insert_taqrelationshiptabconfig_labels
**  Desc: This stored procedure searches to see if a the taqrelationshiptabconfig row exists 
**        for the item type/class/tab code sent.  If no, it will create it. Then it will update
**        all of the labels and indicators based on parameters sent.   
**    Auth: SLB
**    Date: 9 Jan 2015
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:       Author:     Description:
**    --------    --------    ---------------------------------------------------------------
**    06/21/2018  Colman      51661
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

   UPDATE taqrelationshiptabconfig SET   quantity1label = @i_qty1label, quantity2label= @i_qty2label, quantity3label = @i_qty3label, quantity4label= @i_qty4label, indicator1label = @i_ind1label, 
   indicator2label = @i_ind2label, tableid1 = @i_tableid1, tableidlabel1 = @i_tablelabel1, tableid2 = @i_tableid2, tableidlabel2 = @i_tablelabel2,
   tableid3 = @i_tableid3, tableidlabel3 = @i_tablelabel3, tableid4 = @i_tableid4, tableidlabel4 = @i_tablelabel4, 
   hidefiltersind = @i_hidefiltersind, hideclassind = @i_hideclassind, hidetypeind = @i_hidetypeind, hidethisrelind = @i_hidethisrelind,
   hideotherrelind = @i_hideotherrelind, hidenotesind = @i_hidenotesind, hideownerind = @i_hideownerind, hideparticipantsind =@i_hideparticipantsind,
   addrelateditemind = @i_adddrelateditemind, hidedeletebuttonind = @i_hidedeletebuttonind
 
   WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey   
       
   SELECT @v_error_code = @@ERROR
   IF @v_error_code <> 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END 
   
    RETURN   
    
END  --PROCEDURE END

GO


