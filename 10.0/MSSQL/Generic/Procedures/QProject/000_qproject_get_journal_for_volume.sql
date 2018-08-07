if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_journal_for_volume') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_journal_for_volume
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_journal_for_volume
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_journal_for_volume
**  Desc: This stored procedure returns Journal info for the 
**        Journal Tab for Volumes. 
**
**    Auth: Alan Katzen
**    Date: 10 March 2008
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**	06/07/2016   Colman      38278 - Return sortable string value for numeric misc columns
**  06/21/2018   Colman      51661
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT

  DECLARE	@rowcount_var INT,
			@v_gentablesrelationshipkey INT,
			@v_journalkey INT,
			@v_journalname varchar(80),
			@v_relationshipTabCode INT,
			@v_itemType INT,
			@v_usageClass INT,
			@v_qsicode INT,
			@v_volumekey INT,
			@v_taqprojectrelationshipkey INT,

			@v_formtabusageclass INT,
			@v_formtabitemtype INT,

			@v_quantity1 int,
			@v_quantity2 int,
			@v_quantity3 int,
			@v_quantity4 int,
			@v_quantity1label varchar(100),
			@v_quantity2label varchar(100),
			@v_quantity3label varchar(100),
			@v_quantity4label varchar(100),

			@v_indicator1 int,
			@v_indicator2 int,
			@v_indicator1label varchar(100),
			@v_indicator2label varchar(100),

			@v_miscitemkey1 INT,
			@v_miscitem1label varchar(100),
			@v_miscItem1Value varchar(100),

			@v_miscItem1MiscType INT,
			@v_miscItemFormat varchar(20),

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

			@v_lastmaintdate datetime,
			@v_lastuserid varchar(100),
      @v_journal_datacode int

  SELECT @v_journal_datacode = COALESCE(datacode,0)
    FROM gentables
    WHERE tableid = 582
      AND qsicode = 1

  SELECT @v_journalkey = relatedprojectkey, 
			   @v_taqprojectrelationshipkey = taqprojectrelationshipkey
    FROM projectrelationshipview
    WHERE taqprojectkey = @i_projectkey
      AND relationshipcode = @v_journal_datacode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing View (journalkey): projectkey = ' + cast(@i_projectkey AS VARCHAR)
    RETURN  
  END 

SELECT @v_gentablesrelationshipkey = COALESCE(gentablesrelationshipkey,0)
    FROM gentablesrelationships
   WHERE gentable1id = 582
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

  -- volumes tab
  SET @v_qsicode = 3
 
  -- Setup the formtabitemtype and usageclass ( 550 )
  SET @v_formtabusageclass = 4 -- journal 
  SET @v_formtabitemtype = 6 -- journal
 
	SELECT @v_relationshipTabCode = datacode FROM gentables where tableid = 583 and qsicode = @v_qsicode
	
	SELECT @v_formtabusageclass = datasubcode FROM subgentables where tableid = 550 and datacode = @v_formtabitemtype AND qsicode = @v_formtabusageclass

	SELECT @v_relationshipTabCode = datacode FROM gentables where tableid =  583 and qsicode = @v_qsicode

  -- coreprojectinfo with project key and get itemtype/searchitem and usage class  
	SELECT    @v_itemType = searchitemcode
	FROM            coreprojectinfo
	WHERE        (projectkey = @i_projectkey)

	SELECT    @v_usageClass = usageclasscode
	FROM            coreprojectinfo
	WHERE        (projectkey = @i_projectkey)
		
  SELECT @v_quantity1label = quantity1label, @v_quantity2label = quantity2label, 
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
				
      @v_lastmaintdate = lastmaintdate, @v_lastuserid = lastuserid
  FROM dbo.qproject_get_filtered_tabconfig_table(@v_relationshipTabCode, @v_itemType, @v_usageClass, @v_formtabitemtype, @v_formtabusageclass)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing taqrelationshiptabconfig: projectkey = ' + cast(@i_projectkey AS VARCHAR)
    RETURN  
  END 

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
		SET @v_productid1label = ( SELECT COALESCE( datadescshort, datadesc, NULL ) FROM gentables where tableid = 594 and datacode = @v_productidcode1  )
	END

-- Product 2
IF ( @v_productidcode2 > 0 AND @v_productid2label IS NULL ) 
	BEGIN
		SET @v_productid2label = ( SELECT COALESCE( datadescshort, datadesc, NULL ) FROM gentables where tableid = 594 and datacode = @v_productidcode2  )
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

  SET @v_journalname = ''
  IF @v_journalkey > 0 BEGIN
    SELECT @v_journalname = projecttitle
      FROM coreprojectinfo
     WHERE projectkey = @v_journalkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error acessing coreprojectinfo: projectkey = ' + cast(@v_journalkey AS VARCHAR)
      RETURN  
    END  
  END

  SELECT projecttitle as journalname, COALESCE(@v_journalkey,0) journalkey, 

         projectowner, 0 hiddenorder, 
		 @i_projectkey as otherprojectkey, @v_taqprojectrelationshipkey as taqprojectrelationshipkey,

		 @v_quantity1label as quantity1label, @v_quantity1 as quantity1,
		 @v_quantity2label as quantity2label, @v_quantity2 as quantity2, 
		 @v_quantity3label as quantity3label, @v_quantity3 as quantity3,
		 @v_quantity4label as quantity4label, @v_quantity4 as quantity4, 
		 @v_indicator1label as indicator1label, @v_indicator1 as indicator1,
		 @v_indicator2label as indicator2label, @v_indicator2 as indicator2,

		 @v_miscitemkey1 as miscitemkey1, @v_miscitem1label as miscitem1label, 
		 dbo.qproject_get_misc_value( @v_journalkey, @v_miscitemkey1 ) miscItem1value,
		 dbo.qproject_get_misc_sortvalue( @v_journalkey, @v_miscitemkey1 ) miscItem1sortvalue,

		 @v_miscitemkey2 as miscitemkey2, @v_miscitem2label as miscitem2label, 
		 dbo.qproject_get_misc_value( @v_journalkey, @v_miscitemkey2 ) miscItem2value, 
		 dbo.qproject_get_misc_sortvalue( @v_journalkey, @v_miscitemkey2 ) miscItem2sortvalue,

		 @v_miscitemkey3 as miscitemkey3, @v_miscitem3label as miscitem3label, 
		 dbo.qproject_get_misc_value( @v_journalkey, @v_miscitemkey3 ) miscItem3value, 
		 dbo.qproject_get_misc_sortvalue( @v_journalkey, @v_miscitemkey3 ) miscItem3sortvalue,

		 @v_miscitemkey4 as miscitemkey4, @v_miscitem4label as miscitem4label, 
		 dbo.qproject_get_misc_value( @v_journalkey, @v_miscitemkey4 ) miscItem4value, 
		 dbo.qproject_get_misc_sortvalue( @v_journalkey, @v_miscitemkey4 ) miscItem4sortvalue,

		 @v_miscitemkey5 as miscitemkey5, @v_miscitem5label as miscitem5label, 
		 dbo.qproject_get_misc_value( @v_journalkey, @v_miscitemkey5 ) miscItem5value, 
		 dbo.qproject_get_misc_sortvalue( @v_journalkey, @v_miscitemkey5 ) miscItem5sortvalue,

		 @v_miscitemkey6 as miscitemkey6, @v_miscitem6label as miscitem6label, 
		 dbo.qproject_get_misc_value( @v_journalkey, @v_miscitemkey6 ) miscItem6value, 
		 dbo.qproject_get_misc_sortvalue( @v_journalkey, @v_miscitemkey6 ) miscItem6sortvalue,

		 @v_datetypecode1 as datetypecode1,@v_date1label as date1label, 
		 dbo.qproject_get_last_taskdate( @v_journalkey, @v_datetypecode1 ) as date1value, 
		 @v_datetypecode2 as datetypecode2, @v_date2label as date2label, 
         dbo.qproject_get_last_taskdate( @v_journalkey, @v_datetypecode2 ) as date2value,
		 @v_datetypecode3 as datetypecode3, @v_date3label as date3label, 
         dbo.qproject_get_last_taskdate( @v_journalkey, @v_datetypecode3 ) as date3value,
		 @v_datetypecode4 as datetypecode4, @v_date4label as date4label, 
         dbo.qproject_get_last_taskdate( @v_journalkey, @v_datetypecode4 ) as date4value,
		 @v_datetypecode5 as datetypecode5, @v_date5label as date5label, 
         dbo.qproject_get_last_taskdate( @v_journalkey, @v_datetypecode5 ) as date5value,
		 @v_datetypecode6 as datetypecode6, @v_date6label as date6label, 
         dbo.qproject_get_last_taskdate( @v_journalkey, @v_datetypecode6 ) as date6value,

		 @v_pricetypecode1 as pricetypecode1, @v_price1label as price1label, 
         dbo.qproject_get_price_by_pricetype( @v_journalkey, @v_pricetypecode1 ) as pricetypecode1Value,
		 @v_pricetypecode2 as pricetypecode2, @v_price2label as price2label, 
         dbo.qproject_get_price_by_pricetype( @v_journalkey, @v_pricetypecode2 ) as pricetypecode2Value,
		 @v_pricetypecode3 as pricetypecode3, @v_price3label as price3label, 
         dbo.qproject_get_price_by_pricetype( @v_journalkey, @v_pricetypecode3 ) as pricetypecode3Value,
		 @v_pricetypecode4 as pricetypecode4, @v_price4label as price4label, 
         dbo.qproject_get_price_by_pricetype( @v_journalkey, @v_pricetypecode4 ) as pricetypecode4Value,

		 @v_productidcode1 as productidcode1, @v_productid1label as productid1label, 
		 ( SELECT productnumber FROM taqproductnumbers WHERE ( taqprojectkey = @v_journalkey AND productidcode = @v_productidcode1 ) ) as productIdCode1Value,
		 @v_productidcode2 as productidcode2, @v_productid2label as productid2label, 
		 ( SELECT productnumber FROM taqproductnumbers WHERE ( taqprojectkey = @v_journalkey AND productidcode = @v_productidcode2 ) ) as productIdCode2Value,

		 @v_roletypecode1 as roletypecode1, @v_roletype1label as roletype1label, 
		 dbo.qproject_get_participant_name_by_role( @v_journalkey, @v_roletypecode1) as roletypecode1Value,
		 @v_roletypecode2 as roletypecode2, @v_roletype2label as roletype2label, 
		 dbo.qproject_get_participant_name_by_role( @v_journalkey, @v_roletypecode2) as roletypecode2Value,

         @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid

    FROM coreprojectinfo
   WHERE projectkey = @v_journalkey
    
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing coreprojectinfo: projectkey = ' + cast(@i_projectkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qproject_get_journal_for_volume TO PUBLIC
GO

