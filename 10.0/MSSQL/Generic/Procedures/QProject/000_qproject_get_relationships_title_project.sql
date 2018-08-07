IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_relationships_title_project') )
DROP PROCEDURE dbo.qproject_get_relationships_title_project
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.qproject_get_relationships_title_project
 (@i_projectkey     integer,
  @i_relationshiptab_datacode    integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_relationships_title_project
**  Desc: This stored procedure returns all project/title relationships
**        for a project. 
**
**    Auth: Alan Katzen
**    Date: 11 September 2008
**
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:        Author:     Description:
**    --------     --------    -------------------------------------------
**   01/27/2016	   UK		       Case 35031 - Task 004 /Case 36738
**	 05/11/2016    Colman      Added userkey input for taskdate accesscode output
**   06/27/2016    UK		       Case 38806
**   08/03/2016    Colman      39608 - Run misc calc on calculated dates
**   09/26/2016    UK          Case 40596
**   06/21/2018    Colman      51661
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  
  DECLARE 
      @rowcount_var INT,
      @v_gentablesrelationshipkey INT,
      @v_relationshipTabCode INT,
      @v_itemType INT,
      @v_usageClass INT,
      @v_qsicode INT,

      @v_quantity1label varchar(100),
      @v_quantity2label varchar(100),
      @v_quantity3label varchar(100),
      @v_quantity4label varchar(100),

      @v_indicator1label varchar(100),
      @v_indicator2label varchar(100),

      @v_miscitemkey1 INT,
      @v_miscitem1label varchar(100),
      @v_miscItem1Value varchar(100),
      @v_miscitemkey2 INT,
      @v_miscitem2label varchar(100),
      @v_miscItem2Value varchar(100),  
		  @v_miscitemkey3 INT,
      @v_miscitem3label varchar(100),
      @v_miscItem3Value varchar(100), 
		  @v_miscitemkey4 INT,
      @v_miscitem4label varchar(100),
      @v_miscItem4Value varchar(100),
		  @v_miscitemkey5 INT,
      @v_miscitem5label varchar(100),
      @v_miscItem5Value varchar(100), 
		  @v_miscitemkey6 INT,
      @v_miscitem6label varchar(100),
      @v_miscItem6Value varchar(100),

      @v_datetypecode1 INT,
      @v_date1label varchar(100),
      @v_date1value datetime,
      @v_datetypecode2 INT,
      @v_date2label varchar(100),
      @v_date2value datetime,
		  @v_datetypecode3 INT,
      @v_date3label varchar(100),
      @v_date3value datetime,
		  @v_datetypecode4 INT,
      @v_date4label varchar(100),
      @v_date4value datetime,
		  @v_datetypecode5 INT,
      @v_date5label varchar(100),
      @v_date5value datetime,
		  @v_datetypecode6 INT,
      @v_date6label varchar(100),
      @v_date6value datetime,

		  @v_productidcode1 INT,
		  @v_productid1label varchar(100),
		  @v_productIdCode1Value INT,
		  @v_productidcode2 INT,
		  @v_productid2label varchar(100),
		  @v_productIdCode2Value INT,

		  @v_roletypecode1 INT,
		  @v_roletype1label varchar(100),
		  @v_roletypecode1Value varchar(100),
		  @v_roletypecode2 INT,
		  @v_roletype2label varchar(100),
		  @v_roletypecode2Value varchar(100),

		  @v_pricetypecode1 INT,
		  @v_price1label varchar(100),
		  @v_pricetypecode1Value varchar(100),
		  @v_pricetypecode2 INT,
		  @v_price2label varchar(100),
		  @v_pricetypecode2Value varchar(100),
		  @v_pricetypecode3 INT,
		  @v_price3label varchar(100),
		  @v_pricetypecode3Value varchar(100),
		  @v_pricetypecode4 INT,
		  @v_price4label varchar(100),
		  @v_pricetypecode4Value varchar(100),		  
		  @v_decimal1 INT,
		  @v_decimal2 INT,
		  @v_decimal1format VARCHAR(40),
		  @v_decimal2format VARCHAR(40),		  

      @v_tableid1 INT,
      @v_tableidlabel1 varchar(100),
      @v_tableid2 INT,
      @v_tableidlabel2 varchar(100),
      @v_tableid3 INT,
      @v_tableidlabel3 varchar(100),
      @v_tableid4 INT,
      @v_tableidlabel4 varchar(100),
      
      @v_lastmaintdate datetime,
      @v_lastuserid varchar(100),
      @v_hidedeletebuttonind TINYINT, 
      
      @v_otherbookkey INT,
      @v_otherprintingkey INT,
      @v_thistaqprojectkey INT,
      @v_othertitlerolecode INT,
      @v_thisprojectrolecode INT,
      @v_miscitemtype INT,
      @v_calcvalue	VARCHAR(255),
      @v_sortvalue	VARCHAR(255)                

  SET @v_hidedeletebuttonind = NULL
  
  SELECT @v_gentablesrelationshipkey = COALESCE(gentablesrelationshipkey,0)
    FROM gentablesrelationships
   WHERE gentable1id = 605
     and gentable2id = 583

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing gentablesrelationships: projectkey = ' + cast(@i_projectkey AS VARCHAR)
    RETURN  
  END 

  IF @v_gentablesrelationshipkey <= 0 BEGIN
    RETURN
  END

  IF @i_relationshiptab_datacode > 0 BEGIN
    SET @v_relationshipTabCode = @i_relationshiptab_datacode
	  SELECT @v_qsicode = qsicode FROM gentables where tableid = 583 and datacode = @i_relationshiptab_datacode
  END
  ELSE BEGIN
    -- Tab datacode not passed in use generic - Tab Titles for Projects (qsicode = 15)
	  SELECT @v_relationshipTabCode = datacode FROM gentables where tableid = 583 and qsicode = 15
	  SET @v_qsicode = 15
  END
  
  -- coreprojectinfo with project key and get itemtype/searchitem and usage class  
	SELECT    @v_itemType = searchitemcode,
	          @v_usageClass = usageclasscode
	FROM      coreprojectinfo
	WHERE     (projectkey = @i_projectkey)
		
			SELECT	@v_quantity1label = quantity1label, @v_quantity2label = quantity2label, 
        @v_quantity3label = quantity3label, @v_quantity4label = quantity4label, 
				@v_indicator1label = indicator1label, @v_indicator2label = indicator2label, 
				
				@v_miscitemkey1 = miscitemkey1, @v_miscitem1label = miscitem1label, 
				@v_miscitemkey2 = miscitemkey2, @v_miscitem2label = miscitem2label,
				@v_miscitemkey3 = miscitemkey3, @v_miscitem3label = miscitem3label,
				@v_miscitemkey4 = miscitemkey4, @v_miscitem4label = miscitem4label,
				@v_miscitemkey5 = miscitemkey5, @v_miscitem5label = miscitem5label,
				@v_miscitemkey6 = miscitemkey6, @v_miscitem6label = miscitem6label,

				@v_datetypecode1 = datetypecode1, @v_date1label = date1label, 
				@v_datetypecode2 = datetypecode2, @v_date2label = date2label, 
				@v_datetypecode3 = datetypecode3, @v_date3label = date3label, 
				@v_datetypecode4 = datetypecode4, @v_date4label = date4label, 
				@v_datetypecode5 = datetypecode5, @v_date5label = date5label, 
				@v_datetypecode6 = datetypecode6, @v_date6label = date6label, 

				@v_productidcode1 = Productidcode1, @v_productid1label = Productid1label,
				@v_productidcode2 = Productidcode2, @v_productid2label = Productid2label,
		
				@v_roletypecode1 = roletypecode1, @v_roletype1label = roletype1label,
				@v_roletypecode2 = roletypecode2, @v_roletype2label = roletype2label,

				@v_pricetypecode1 = pricetypecode1, @v_price1label = price1label,
				@v_pricetypecode2 = pricetypecode2, @v_price2label = price2label,
				@v_pricetypecode3 = pricetypecode3, @v_price3label = price3label,
				@v_pricetypecode4 = pricetypecode4, @v_price4label = price4label,
				
			    @v_decimal1format = decimal1format, @v_decimal2format = decimal2format,				
				
        @v_tableid1 = tableid1, 
        @v_tableidlabel1 = CASE
          WHEN tableid1 > 0 AND tableidlabel1 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid1)
          ELSE tableidlabel1
        END,
        @v_tableid2 = tableid2, 
        @v_tableidlabel2 = CASE
          WHEN tableid2 > 0 AND tableidlabel2 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid2)
          ELSE tableidlabel2
        END,
        @v_tableid3 = tableid3, 
        @v_tableidlabel3 = CASE
          WHEN tableid3 > 0 AND tableidlabel3 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid3)
          ELSE tableidlabel3
        END,
        @v_tableid4 = tableid4, 
        @v_tableidlabel4 = CASE
          WHEN tableid4 > 0 AND tableidlabel4 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid4)
          ELSE tableidlabel4
        END,
        
				@v_lastmaintdate = lastmaintdate, @v_lastuserid = lastuserid,
				@v_hidedeletebuttonind = hidedeletebuttonind
      FROM dbo.qproject_get_filtered_tabconfig_table(@v_relationshipTabCode, @v_itemType, @v_usageClass, NULL, NULL)
      
-- Run through the main logic of determining visibility status as follows per the specs as written below:
--	if the datetypecode1 is not null, make this column visible. For the label, use date1label if this is not null; if it is null, use datelabel from the datetype table 
--  for the datetypecode stored in datetypecode1. Fill the column with the value from taqprojecttasks for the related projectkey and datekey. 
--  If there is more than one, select the one with the most recent lastmaintdate. If it is null, set this column to invisible.

-- date1
IF ( @v_datetypecode1 > 0 AND @v_date1label IS NULL ) 
	BEGIN
		SET @v_date1label = dbo.qproject_get_dateype_label( @v_datetypecode1 )
	END

-- date2
IF ( @v_datetypecode2 > 0 AND @v_date2label IS NULL ) 
	BEGIN
		SET @v_date2label = dbo.qproject_get_dateype_label( @v_datetypecode2 )
	END

-- date3
IF ( @v_datetypecode3 > 0 AND @v_date3label IS NULL ) 
	BEGIN
		SET @v_date3label = dbo.qproject_get_dateype_label( @v_datetypecode3 )
	END

-- date4
IF ( @v_datetypecode4 > 0 AND @v_date4label IS NULL ) 
	BEGIN
		SET @v_date4label = dbo.qproject_get_dateype_label( @v_datetypecode4 )
	END

-- date5
IF ( @v_datetypecode5 > 0 AND @v_date5label IS NULL ) 
	BEGIN
		SET @v_date5label = dbo.qproject_get_dateype_label( @v_datetypecode5 )
	END

-- date6
IF ( @v_datetypecode6 > 0 AND @v_date6label IS NULL ) 
	BEGIN
		SET @v_date6label = dbo.qproject_get_dateype_label( @v_datetypecode6 )
	END

-- Misc 1
IF ( @v_miscitemkey1 > 0 AND @v_miscitem1label IS NULL ) 
	BEGIN
		SET @v_miscitem1label = dbo.qutl_get_misc_label( @v_miscitemkey1 )
	END

-- Misc 2
IF ( @v_miscitemkey2 > 0 AND @v_miscitem2label IS NULL ) 
	BEGIN
		SET @v_miscitem2label = dbo.qutl_get_misc_label( @v_miscitemkey2 )
	END

-- Misc 3
IF ( @v_miscitemkey3 > 0 AND @v_miscitem3label IS NULL ) 
	BEGIN
		SET @v_miscitem3label = dbo.qutl_get_misc_label( @v_miscitemkey3 )
	END

-- Misc 4
IF ( @v_miscitemkey4 > 0 AND @v_miscitem4label IS NULL ) 
	BEGIN
		SET @v_miscitem4label = dbo.qutl_get_misc_label( @v_miscitemkey4 )
	END

-- Misc 5
IF ( @v_miscitemkey5 > 0 AND @v_miscitem5label IS NULL ) 
	BEGIN
		SET @v_miscitem5label = dbo.qutl_get_misc_label( @v_miscitemkey5 )
	END

-- Misc 6
IF ( @v_miscitemkey6 > 0 AND @v_miscitem6label IS NULL ) 
	BEGIN
		SET @v_miscitem6label = dbo.qutl_get_misc_label( @v_miscitemkey6 )
	END

-- Product 1
IF ( @v_productidcode1 > 0 AND @v_productid1label IS NULL ) 
	BEGIN
		SET @v_productid1label = ( SELECT COALESCE( labelshort, label, NULL ) FROM productnumlocation p, isbnlabels i 
		                            WHERE lower(p.columnname) = lower(i.columnname) AND p.productnumlockey = @v_productidcode1 )
	END

-- Product 2
IF ( @v_productidcode2 > 0 AND @v_productid2label IS NULL ) 
	BEGIN
		SET @v_productid2label = ( SELECT COALESCE( labelshort, label, NULL ) FROM productnumlocation p, isbnlabels i 
		                            WHERE lower(p.columnname) = lower(i.columnname) AND p.productnumlockey = @v_productidcode2 )
	END

-- Participant 1
IF ( @v_roletypecode1 > 0 AND @v_roletype1label IS NULL ) 
	BEGIN
		SET @v_roletype1label = ( SELECT COALESCE( datadescshort, datadesc, NULL ) FROM gentables where tableid = 285 and datacode = @v_roletypecode1  )
	END

-- Participant 2
IF ( @v_roletypecode2 > 0 AND @v_roletype2label IS NULL ) 
	BEGIN
		SET @v_roletype2label = ( SELECT COALESCE( datadescshort, datadesc, NULL ) FROM gentables where tableid = 285 and datacode = @v_roletypecode2  )
	END

-- PriceType 1
IF ( @v_pricetypecode1 > 0 AND @v_price1label IS NULL ) 
	BEGIN
		SET @v_price1label = ( SELECT COALESCE( datadescshort, datadesc, NULL ) FROM gentables where tableid = 306 and datacode = @v_pricetypecode1  )
	END

-- PriceType 2
IF ( @v_pricetypecode2 > 0 AND @v_price2label IS NULL ) 
	BEGIN
		SET @v_price2label = ( SELECT COALESCE( datadescshort, datadesc, NULL ) FROM gentables where tableid = 306 and datacode = @v_pricetypecode2  )
	END

-- PriceType 3
IF ( @v_pricetypecode3 > 0 AND @v_price3label IS NULL ) 
	BEGIN
		SET @v_price3label = ( SELECT COALESCE( datadescshort, datadesc, NULL ) FROM gentables where tableid = 306 and datacode = @v_pricetypecode3  )
	END

-- PriceType 4
IF ( @v_pricetypecode4 > 0 AND @v_price4label IS NULL ) 
	BEGIN
		SET @v_price4label = ( SELECT COALESCE( datadescshort, datadesc, NULL ) FROM gentables where tableid = 306 and datacode = @v_pricetypecode4  )
	END

	SELECT r.taqprojectformatkey,
	       r.taqprojectkey, 
         COALESCE(r.bookkey, 0) as bookkey, 
         COALESCE(r.printingkey, 0) as printingkey, 
         r.projectrolecode, 
         dbo.get_gentables_desc(604,r.projectrolecode,'long') projectroledesc,
         r.titlerolecode, 
         dbo.get_gentables_desc(605,r.titlerolecode,'long') titleroledesc,
         COALESCE(c.title,r.relateditem2name) title,  
         COALESCE(c.bisacstatusdesc,r.relateditem2status) bisacstatusdesc,  
         COALESCE(c.bisacstatuscode,0) bisacstatuscode,  
         COALESCE(dbo.qtitle_get_authors_from_qsicomments(r.bookkey),c.authorname,r.relateditem2participants) authors,  
         r.keyind, r.sortorder,r.taqprojectformatdesc,
         c.mediatypecode mediatypecode, c.mediatypesubcode formatcode, 
         cast(COALESCE(c.mediatypecode,0) AS VARCHAR) + '|' + cast(COALESCE(c.mediatypesubcode,0) AS VARCHAR) titlemediatypeformat,
         c.formatname formatdesc, COALESCE(c.bestseasonkey, 0) bestseasonkey, c.seasondesc, 0 hiddenorder, 
		     r.quantity1, r.quantity2, r.quantity3, r.quantity4, r.decimal1, @v_decimal1format as decimal1format, r.decimal2, @v_decimal2format as decimal2format, r.indicator1, r.indicator2, @v_quantity1label as quantity1label, @v_quantity2label as quantity2label, 
         @v_indicator1label as indicator1label, @v_indicator2label as indicator2label, 

      @v_miscitemkey1 as miscitemkey1, @v_miscitem1label as miscitem1label, 
      dbo.qtitle_get_misc_value_info( r.bookkey, @v_miscitemkey1 ) miscItem1value, 
      dbo.qtitle_get_misc_sortvalue( r.bookkey, @v_miscitemkey1 ) miscItem1sortvalue, 
			dbo.qutl_get_misctype(@v_miscitemkey1) misctype1,      
			dbo.qutl_get_misc_label(@v_miscitemkey1) misclabel1,
			dbo.qutl_get_miscname(@v_miscitemkey1) miscname1,  			
			dbo.qtitle_get_misc_numeric_value( r.bookkey, @v_miscitemkey1 ) miscItem1numericvalue,
			dbo.qtitle_get_misc_float_value( r.bookkey, @v_miscitemkey1 ) miscItem1floatvalue,        
			dbo.qtitle_get_misc_text_value( r.bookkey, @v_miscitemkey1 ) miscItem1textvalue,        
			dbo.qtitle_get_misc_checkbox_value( r.bookkey, @v_miscitemkey1 ) miscItem1checkboxvalue,     
			dbo.qtitle_get_misc_datacode_value( r.bookkey, @v_miscitemkey1 ) miscItem1datacodevalue,      
			dbo.qtitle_get_misc_datasubcode_value( r.bookkey, @v_miscitemkey1 ) miscItem1datasubcodevalue,  
			dbo.qtitle_get_misc_calculated_value( r.bookkey, @v_miscitemkey1 ) miscItem1calculatedvalue, 	
			dbo.qtitle_get_misc_updateind( r.bookkey, @v_miscitemkey1 ) updateind1,
			dbo.qtitle_get_misc_sendtoeloquence_value( r.bookkey, @v_miscitemkey1 ) sendtoeloquence1,
			dbo.qtitle_get_misc_defaultsendtoeloquence_value( r.bookkey, @v_miscitemkey1 ) defaultsendtoeloquence1,	
			dbo.qtitle_exists_misc_entry( r.bookkey, @v_miscitemkey1 ) existsmiscentry1,
			dbo.qtitle_exists_misc_default_entry( r.bookkey, @v_miscitemkey1 ) existsmiscdefaultentry1,	
			dbo.qtitle_exists_misc_section_entry( r.bookkey, @v_miscitemkey1 ) existsmiscsectionentry1,					     
		     
      @v_miscitemkey2 as miscitemkey2, @v_miscitem2label as miscitem2label, 
      dbo.qtitle_get_misc_value_info( r.bookkey, @v_miscitemkey2 ) miscItem2value, 
      dbo.qtitle_get_misc_sortvalue( r.bookkey, @v_miscitemkey2 ) miscItem2sortvalue, 
			dbo.qutl_get_misctype(@v_miscitemkey2) misctype2,    
			dbo.qutl_get_misc_label(@v_miscitemkey2) misclabel2, 
			dbo.qutl_get_miscname(@v_miscitemkey2) miscname2, 						  
			dbo.qtitle_get_misc_numeric_value( r.bookkey, @v_miscitemkey2 ) miscItem2numericvalue,
			dbo.qtitle_get_misc_float_value( r.bookkey, @v_miscitemkey2 ) miscItem2floatvalue,        
			dbo.qtitle_get_misc_text_value( r.bookkey, @v_miscitemkey2 ) miscItem2textvalue,        
			dbo.qtitle_get_misc_checkbox_value( r.bookkey, @v_miscitemkey2 ) miscItem2checkboxvalue,     
			dbo.qtitle_get_misc_datacode_value( r.bookkey, @v_miscitemkey2 ) miscItem2datacodevalue,      
			dbo.qtitle_get_misc_datasubcode_value( r.bookkey, @v_miscitemkey2 ) miscItem2datasubcodevalue,  
			dbo.qtitle_get_misc_calculated_value( r.bookkey, @v_miscitemkey2 ) miscItem2calculatedvalue, 	
			dbo.qtitle_get_misc_updateind( r.bookkey, @v_miscitemkey2 ) updateind2,	  
			dbo.qtitle_get_misc_sendtoeloquence_value( r.bookkey, @v_miscitemkey2 ) sendtoeloquence2,
			dbo.qtitle_get_misc_defaultsendtoeloquence_value( r.bookkey, @v_miscitemkey2 ) defaultsendtoeloquence2,	
			dbo.qtitle_exists_misc_entry( r.bookkey, @v_miscitemkey2 ) existsmiscentry2,					
			dbo.qtitle_exists_misc_default_entry( r.bookkey, @v_miscitemkey2 ) existsmiscdefaultentry2,	
			dbo.qtitle_exists_misc_section_entry( r.bookkey, @v_miscitemkey2 ) existsmiscsectionentry2,						   
		     		     
      @v_miscitemkey3 as miscitemkey3, @v_miscitem3label as miscitem3label, 
      dbo.qtitle_get_misc_value_info( r.bookkey, @v_miscitemkey3 ) miscItem3value, 
      dbo.qtitle_get_misc_sortvalue( r.bookkey, @v_miscitemkey3 ) miscItem3sortvalue, 
			dbo.qutl_get_misctype(@v_miscitemkey3) misctype3,  
			dbo.qutl_get_misc_label(@v_miscitemkey3) misclabel3, 
			dbo.qutl_get_miscname(@v_miscitemkey3) miscname3,						    
			dbo.qtitle_get_misc_numeric_value( r.bookkey, @v_miscitemkey3 ) miscItem3numericvalue,
			dbo.qtitle_get_misc_float_value( r.bookkey, @v_miscitemkey3 ) miscItem3floatvalue,        
			dbo.qtitle_get_misc_text_value( r.bookkey, @v_miscitemkey3 ) miscItem3textvalue,        
			dbo.qtitle_get_misc_checkbox_value( r.bookkey, @v_miscitemkey3 ) miscItem3checkboxvalue,     
			dbo.qtitle_get_misc_datacode_value( r.bookkey, @v_miscitemkey3 ) miscItem3datacodevalue,      
			dbo.qtitle_get_misc_datasubcode_value( r.bookkey, @v_miscitemkey3 ) miscItem3datasubcodevalue,  
			dbo.qtitle_get_misc_calculated_value( r.bookkey, @v_miscitemkey3 ) miscItem3calculatedvalue,
			dbo.qtitle_get_misc_updateind( r.bookkey, @v_miscitemkey3 ) updateind3, 	
			dbo.qtitle_get_misc_sendtoeloquence_value( r.bookkey, @v_miscitemkey3 ) sendtoeloquence3,
			dbo.qtitle_get_misc_defaultsendtoeloquence_value( r.bookkey, @v_miscitemkey3 ) defaultsendtoeloquence3,	
			dbo.qtitle_exists_misc_entry( r.bookkey, @v_miscitemkey3 ) existsmiscentry3,	
			dbo.qtitle_exists_misc_default_entry( r.bookkey, @v_miscitemkey3 ) existsmiscdefaultentry3,	
			dbo.qtitle_exists_misc_section_entry( r.bookkey, @v_miscitemkey3 ) existsmiscsectionentry3,								     
		     		     
      @v_miscitemkey4 as miscitemkey4, @v_miscitem4label as miscitem4label, 
      dbo.qtitle_get_misc_value_info( r.bookkey, @v_miscitemkey4 ) miscItem4value,
      dbo.qtitle_get_misc_sortvalue( r.bookkey, @v_miscitemkey4 ) miscItem4sortvalue, 
			dbo.qutl_get_misctype(@v_miscitemkey4) misctype4,      
			dbo.qutl_get_misc_label(@v_miscitemkey4) misclabel4, 	
			dbo.qutl_get_miscname(@v_miscitemkey4) miscname4,					
			dbo.qtitle_get_misc_numeric_value( r.bookkey, @v_miscitemkey4 ) miscItem4numericvalue,
			dbo.qtitle_get_misc_float_value( r.bookkey, @v_miscitemkey4 ) miscItem4floatvalue,        
			dbo.qtitle_get_misc_text_value( r.bookkey, @v_miscitemkey4 ) miscItem4textvalue,        
			dbo.qtitle_get_misc_checkbox_value( r.bookkey, @v_miscitemkey4 ) miscItem4checkboxvalue,     
			dbo.qtitle_get_misc_datacode_value( r.bookkey, @v_miscitemkey4 ) miscItem4datacodevalue,      
			dbo.qtitle_get_misc_datasubcode_value( r.bookkey, @v_miscitemkey4 ) miscItem4datasubcodevalue,  
			dbo.qtitle_get_misc_calculated_value( r.bookkey, @v_miscitemkey4 ) miscItem4calculatedvalue, 
			dbo.qtitle_get_misc_updateind( r.bookkey, @v_miscitemkey4 ) updateind4,		
			dbo.qtitle_get_misc_sendtoeloquence_value( r.bookkey, @v_miscitemkey4 ) sendtoeloquence4,
			dbo.qtitle_get_misc_defaultsendtoeloquence_value( r.bookkey, @v_miscitemkey4 ) defaultsendtoeloquence4,
			dbo.qtitle_exists_misc_entry( r.bookkey, @v_miscitemkey4 ) existsmiscentry4,
			dbo.qtitle_exists_misc_default_entry( r.bookkey, @v_miscitemkey4 ) existsmiscdefaultentry4,	
			dbo.qtitle_exists_misc_section_entry( r.bookkey, @v_miscitemkey4 ) existsmiscsectionentry4,											     
		     		      
      @v_miscitemkey5 as miscitemkey5, @v_miscitem5label as miscitem5label, 
      dbo.qtitle_get_misc_value_info( r.bookkey, @v_miscitemkey5 ) miscItem5value,
      dbo.qtitle_get_misc_sortvalue( r.bookkey, @v_miscitemkey5 ) miscItem5sortvalue, 
			dbo.qutl_get_misctype(@v_miscitemkey5) misctype5,    
			dbo.qutl_get_misc_label(@v_miscitemkey5) misclabel5,
			dbo.qutl_get_miscname(@v_miscitemkey5) miscname5,				 			  
			dbo.qtitle_get_misc_numeric_value( r.bookkey, @v_miscitemkey5 ) miscItem5numericvalue,
			dbo.qtitle_get_misc_float_value( r.bookkey, @v_miscitemkey5 ) miscItem5floatvalue,        
			dbo.qtitle_get_misc_text_value( r.bookkey, @v_miscitemkey5 ) miscItem5textvalue,        
			dbo.qtitle_get_misc_checkbox_value( r.bookkey, @v_miscitemkey5 ) miscItem5checkboxvalue,     
			dbo.qtitle_get_misc_datacode_value( r.bookkey, @v_miscitemkey5 ) miscItem5datacodevalue,      
			dbo.qtitle_get_misc_datasubcode_value( r.bookkey, @v_miscitemkey5 ) miscItem5datasubcodevalue,  
			dbo.qtitle_get_misc_calculated_value( r.bookkey, @v_miscitemkey5 ) miscItem5calculatedvalue,
			dbo.qtitle_get_misc_updateind( r.bookkey, @v_miscitemkey5 ) updateind5, 	
			dbo.qtitle_get_misc_sendtoeloquence_value( r.bookkey, @v_miscitemkey5 ) sendtoeloquence5,
			dbo.qtitle_get_misc_defaultsendtoeloquence_value( r.bookkey, @v_miscitemkey5 ) defaultsendtoeloquence5,		
			dbo.qtitle_exists_misc_entry( r.bookkey, @v_miscitemkey5 ) existsmiscentry5,
			dbo.qtitle_exists_misc_default_entry( r.bookkey, @v_miscitemkey5 ) existsmiscdefaultentry5,
			dbo.qtitle_exists_misc_section_entry( r.bookkey, @v_miscitemkey5 ) existsmiscsectionentry5,								     
		     		      
      @v_miscitemkey6 as miscitemkey6, @v_miscitem6label as miscitem6label, 
      dbo.qtitle_get_misc_value_info( r.bookkey, @v_miscitemkey6 ) miscItem6value, 
      dbo.qtitle_get_misc_sortvalue( r.bookkey, @v_miscitemkey6 ) miscItem6sortvalue, 
			dbo.qutl_get_misctype(@v_miscitemkey6) misctype6,      
			dbo.qutl_get_misc_label(@v_miscitemkey6) misclabel6, 
			dbo.qutl_get_miscname(@v_miscitemkey6) miscname6,							
			dbo.qtitle_get_misc_numeric_value( r.bookkey, @v_miscitemkey6 ) miscItem6numericvalue,
			dbo.qtitle_get_misc_float_value( r.bookkey, @v_miscitemkey6 ) miscItem6floatvalue,        
			dbo.qtitle_get_misc_text_value( r.bookkey, @v_miscitemkey6 ) miscItem6textvalue,        
			dbo.qtitle_get_misc_checkbox_value( r.bookkey, @v_miscitemkey6 ) miscItem6checkboxvalue,     
			dbo.qtitle_get_misc_datacode_value( r.bookkey, @v_miscitemkey6 ) miscItem6datacodevalue,      
			dbo.qtitle_get_misc_datasubcode_value( r.bookkey, @v_miscitemkey6 ) miscItem6datasubcodevalue,  
			dbo.qtitle_get_misc_calculated_value( r.bookkey, @v_miscitemkey6 ) miscItem6calculatedvalue, 		     
			dbo.qtitle_get_misc_updateind( r.bookkey, @v_miscitemkey6 ) updateind6,	
			dbo.qtitle_get_misc_sendtoeloquence_value( r.bookkey, @v_miscitemkey6 ) sendtoeloquence6,
			dbo.qtitle_get_misc_defaultsendtoeloquence_value( r.bookkey, @v_miscitemkey6 ) defaultsendtoeloquence6,	
			dbo.qtitle_exists_misc_entry( r.bookkey, @v_miscitemkey6 ) existsmiscentry6,
			dbo.qtitle_exists_misc_default_entry( r.bookkey, @v_miscitemkey6 ) existsmiscdefaultentry6,	
			dbo.qtitle_exists_misc_section_entry( r.bookkey, @v_miscitemkey6 ) existsmiscsectionentry6,									
		     		     
			 dbo.qutl_get_misc_fieldformat(@v_miscitemkey1) fieldformat1, 
			 dbo.qutl_get_misc_fieldformat(@v_miscitemkey2) fieldformat2, 
			 dbo.qutl_get_misc_fieldformat(@v_miscitemkey3) fieldformat3, 
			 dbo.qutl_get_misc_fieldformat(@v_miscitemkey4) fieldformat4, 
			 dbo.qutl_get_misc_fieldformat(@v_miscitemkey5) fieldformat5, 
			 dbo.qutl_get_misc_fieldformat(@v_miscitemkey6) fieldformat6,  			 	     

		     @v_datetypecode1 as datetypecode1,@v_date1label as date1label, 
		     dbo.qtitle_get_last_taskdate( r.bookkey, r.printingkey, @v_datetypecode1 ) as date1value, 
         dbo.qtitle_get_taskdate_access(@i_userkey, r.bookkey, r.printingkey, @v_datetypecode1) as date1access,
		     @v_datetypecode2 as datetypecode2, @v_date2label as date2label, 
         dbo.qtitle_get_last_taskdate( r.bookkey, r.printingkey, @v_datetypecode2 ) as date2value,
         dbo.qtitle_get_taskdate_access(@i_userkey, r.bookkey, r.printingkey, @v_datetypecode2) as date2access,
		     @v_datetypecode3 as datetypecode3, @v_date3label as date3label, 
         dbo.qtitle_get_last_taskdate( r.bookkey, r.printingkey, @v_datetypecode3 ) as date3value,
         dbo.qtitle_get_taskdate_access(@i_userkey, r.bookkey, r.printingkey, @v_datetypecode3) as date3access,
		     @v_datetypecode4 as datetypecode4, @v_date4label as date4label, 
         dbo.qtitle_get_last_taskdate( r.bookkey, r.printingkey, @v_datetypecode4 ) as date4value,
         dbo.qtitle_get_taskdate_access(@i_userkey, r.bookkey, r.printingkey, @v_datetypecode4) as date4access,
		     @v_datetypecode5 as datetypecode5, @v_date5label as date5label, 
         dbo.qtitle_get_last_taskdate( r.bookkey, r.printingkey, @v_datetypecode5 ) as date5value,
         dbo.qtitle_get_taskdate_access(@i_userkey, r.bookkey, r.printingkey, @v_datetypecode5) as date5access,
		     @v_datetypecode6 as datetypecode6, @v_date6label as date6label, 
         dbo.qtitle_get_last_taskdate( r.bookkey, r.printingkey, @v_datetypecode6 ) as date6value,
         dbo.qtitle_get_taskdate_access(@i_userkey, r.bookkey, r.printingkey, @v_datetypecode6) as date6access,

		     @v_pricetypecode1 as pricetypecode1, @v_price1label as price1label, 
         dbo.qtitle_get_price_by_pricetype( r.bookkey, @v_pricetypecode1 ) as pricetypecode1Value,
		     @v_pricetypecode2 as pricetypecode2, @v_price2label as price2label, 
         dbo.qtitle_get_price_by_pricetype( r.bookkey, @v_pricetypecode2 ) as pricetypecode2Value,
		     @v_pricetypecode3 as pricetypecode3, @v_price3label as price3label, 
         dbo.qtitle_get_price_by_pricetype( r.bookkey, @v_pricetypecode3 ) as pricetypecode3Value,
		     @v_pricetypecode4 as pricetypecode4, @v_price4label as price4label, 
         dbo.qtitle_get_price_by_pricetype( r.bookkey, @v_pricetypecode4 ) as pricetypecode4Value,

		     @v_productidcode1 as productidcode1, @v_productid1label as productid1label, 
		     dbo.qutl_get_productnumber( @v_productidcode1, r.bookkey ) as productIdCode1Value,
		     @v_productidcode2 as productidcode2, @v_productid2label as productid2label, 
		     dbo.qutl_get_productnumber( @v_productidcode2, r.bookkey ) as productIdCode2Value,

		     @v_roletypecode1 as roletypecode1, @v_roletype1label as roletype1label, 
		     dbo.qtitle_get_participant_name_by_role( r.bookkey, r.printingkey, @v_roletypecode1) as roletypecode1Value,
		     @v_roletypecode2 as roletypecode2, @v_roletype2label as roletype2label, 
		     dbo.qtitle_get_participant_name_by_role( r.bookkey, r.printingkey, @v_roletypecode2) as roletypecode2Value,

         @v_tableid1 as tableid1, @v_tableidlabel1 as tableidlabel1,
         dbo.get_gentables_desc(@v_tableid1,r.datacode1,'long') as datacode1Value,r.datacode1,
         @v_tableid2 as tableid2, @v_tableidlabel2 as tableidlabel2,
         dbo.get_gentables_desc(@v_tableid2,r.datacode2,'long') as datacode2Value,r.datacode2,
         @v_tableid3 as tableid3, @v_tableidlabel3 as tableidlabel3,
         dbo.get_gentables_desc(@v_tableid3,r.datacode3,'long') as datacode3Value,r.datacode3,
         @v_tableid4 as tableid4, @v_tableidlabel4 as tableidlabel4,
         dbo.get_gentables_desc(@v_tableid4,r.datacode4,'long') as datacode4Value,r.datacode4,
         
         @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid, @v_hidedeletebuttonind as hidedeletebuttonind,
         CASE WHEN c.seasonkey IS NULL THEN 0 ELSE 1 END actualseasonind
         
   INTO #temp_relationships          
    FROM taqprojecttitle r LEFT OUTER JOIN coretitleinfo c ON r.bookkey = c.bookkey AND COALESCE(r.printingkey,1) = c.printingkey  
   WHERE r.taqprojectkey = @i_projectkey 
     AND titlerolecode in (SELECT datacode from gentables
                                WHERE tableid = 605
                                  AND ((datacode in (SELECT distinct code1 FROM gentablesrelationshipdetail
                                                      WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey
                                                        AND code2 = @v_relationshipTabCode)) OR
                                        -- Case #18293 - Only show title roles not configured for any tab if we are on the 
                                        -- generic titles tab on projects (qsicode = 15)
                                       (@v_qsicode = 15 and datacode not in (SELECT distinct code1 FROM gentablesrelationshipdetail
                                                          WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey))))

ORDER BY r.keyind DESC, r.sortorder ASC, titleroledesc ASC

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on taqprojectrelationship (' + cast(@error_var AS VARCHAR) + '): projectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 
  
     -- Loop through all relationships and execute the misc calc sql, if any of the misc items are calculated
  DECLARE cur_relationship CURSOR FOR
    SELECT bookkey, printingkey, taqprojectkey, titlerolecode, projectrolecode
    FROM #temp_relationships
    
  OPEN cur_relationship
  
  FETCH NEXT FROM cur_relationship 
  INTO @v_otherbookkey, @v_otherprintingkey, @v_thistaqprojectkey, @v_othertitlerolecode, @v_thisprojectrolecode

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN 
     
    IF @v_miscitemkey1 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey1
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qtitle_run_bookmisc_calc @v_otherbookkey, @v_otherprintingkey, @v_miscitemkey1, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem1value = @v_calcvalue, miscItem1calculatedvalue = @v_calcvalue, updateind1 = 0, miscItem1sortvalue = @v_sortvalue
          WHERE bookkey = @v_otherbookkey
            AND printingkey = @v_otherprintingkey
            AND taqprojectkey = @v_thistaqprojectkey
            AND titlerolecode = @v_othertitlerolecode
            AND projectrolecode = @v_thisprojectrolecode
      END      
    END
    
    IF @v_miscitemkey2 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey2
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qtitle_run_bookmisc_calc @v_otherbookkey, @v_otherprintingkey, @v_miscitemkey2, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem2value = @v_calcvalue, miscItem2calculatedvalue = @v_calcvalue, updateind2 = 0, miscItem2sortvalue = @v_sortvalue
          WHERE bookkey = @v_otherbookkey
            AND printingkey = @v_otherprintingkey
            AND taqprojectkey = @v_thistaqprojectkey
            AND titlerolecode = @v_othertitlerolecode
            AND projectrolecode = @v_thisprojectrolecode
      END      
    END
    
    IF @v_miscitemkey3 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey3
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qtitle_run_bookmisc_calc @v_otherbookkey, @v_otherprintingkey, @v_miscitemkey3, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem3value = @v_calcvalue, miscItem3calculatedvalue = @v_calcvalue, updateind3 = 0, miscItem3sortvalue = @v_sortvalue
          WHERE bookkey = @v_otherbookkey
            AND printingkey = @v_otherprintingkey
            AND taqprojectkey = @v_thistaqprojectkey
            AND titlerolecode = @v_othertitlerolecode
            AND projectrolecode = @v_thisprojectrolecode
      END      
    END
    
    IF @v_miscitemkey4 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey4
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qtitle_run_bookmisc_calc @v_otherbookkey, @v_otherprintingkey, @v_miscitemkey4, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem4value = @v_calcvalue, miscItem4calculatedvalue = @v_calcvalue, updateind4 = 0, miscItem4sortvalue = @v_sortvalue
          WHERE bookkey = @v_otherbookkey
            AND printingkey = @v_otherprintingkey
            AND taqprojectkey = @v_thistaqprojectkey
            AND titlerolecode = @v_othertitlerolecode
            AND projectrolecode = @v_thisprojectrolecode
      END      
    END
    
    IF @v_miscitemkey5 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey5
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qtitle_run_bookmisc_calc @v_otherbookkey, @v_otherprintingkey, @v_miscitemkey5, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem5value = @v_calcvalue, miscItem5calculatedvalue = @v_calcvalue, updateind5 = 0, miscItem5sortvalue = @v_sortvalue
          WHERE bookkey = @v_otherbookkey
            AND printingkey = @v_otherprintingkey
            AND taqprojectkey = @v_thistaqprojectkey
            AND titlerolecode = @v_othertitlerolecode
            AND projectrolecode = @v_thisprojectrolecode
      END      
    END
    
    IF @v_miscitemkey6>0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey6
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qtitle_run_bookmisc_calc @v_otherbookkey, @v_otherprintingkey, @v_miscitemkey6, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem6value = @v_calcvalue, miscItem6calculatedvalue = @v_calcvalue, updateind6 = 0, miscItem6sortvalue = @v_sortvalue
          WHERE bookkey = @v_otherbookkey
            AND printingkey = @v_otherprintingkey
            AND taqprojectkey = @v_thistaqprojectkey
            AND titlerolecode = @v_othertitlerolecode
            AND projectrolecode = @v_thisprojectrolecode
      END      
    END              
  
    FETCH NEXT FROM cur_relationship
    INTO @v_otherbookkey, @v_otherprintingkey, @v_thistaqprojectkey, @v_othertitlerolecode, @v_thisprojectrolecode
  END
  
  CLOSE cur_relationship
  DEALLOCATE cur_relationship  
  
  -- *******************************************************************
  SELECT *
  FROM #temp_relationships
  ORDER BY keyind DESC, sortorder ASC, projectroledesc ASC  
GO

GRANT EXEC ON qproject_get_relationships_title_project TO PUBLIC
GO

