if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_relationships_volume') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_relationships_volume
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_relationships_volume
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  Name: qproject_get_relationships_volume
**  Desc: This stored procedure returns all relationships
**        for a project. 
**
**    Auth: Alan Katzen
**    Date: 27 February 2008
**
**	  Revised: Jon Hess - 07/09/08 for project relationship tab enhancement
**	  Revised: Jon Hess - 07/29/2008 for Project Relationship Tab Enhancement Phase II
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  06/21/2018   Colman      51661
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT

  DECLARE	
		@rowcount_var INT,
		@v_gentablesrelationshipkey INT,
		@v_qsicode INT,
		@v_taqprojectrelationshipkey INT,
		@v_keyind INT,

		@v_relationshipTabCode INT,
		@v_itemType INT,
		@v_usageClass INT,

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
		@v_lastmaintdate datetime,
		@v_lastuserid varchar(100),
    @v_otheritemtype INT,
    @v_otherusageclass INT

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
  SET @v_qsicode = 4

  -- tabcode = select datacode from gentables where tableid = 583 and qsicode = v_qsicode
    /** Get taqelementtypecode for 'Manuscript' (gentable 287, qsicode=1) **/
 
	SELECT @v_relationshipTabCode = datacode FROM gentables where tableid =  583 and qsicode = @v_qsicode

  -- coreprojectinfo with project key and get itemtype/searchitem and usage class  
	SELECT    @v_itemType = searchitemcode
	FROM            coreprojectinfo
	WHERE        (projectkey = @i_projectkey)

	SELECT    @v_usageClass = usageclasscode
	FROM            coreprojectinfo
	WHERE        (projectkey = @i_projectkey)

  SET @v_otheritemtype = 6 -- journal

  SELECT @v_otherusageclass = datasubcode from subgentables
   WHERE tableid = 550
     AND datacode = @v_otheritemtype
     AND qsicode = 8  -- volume

		BEGIN
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
				
				@v_lastmaintdate = lastmaintdate, @v_lastuserid = lastuserid
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

  SELECT v.relatedprojectkey otherprojectkey, c.templateind templateind,
         c.projecttitle otherprojectdisplayname,
         c.projectstatusdesc otherprojectstatus,  
         COALESCE(c.projectstatus,0) otherprojectstatuscode,  
         c.projectparticipants otherprojectparticipants,  
         c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
         cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
         c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder,
		 v.taqprojectrelationshipkey, v.keyind, v.relationshipaddtldescription relationshipaddtldesc,

		 v.quantity1, v.quantity2, v.quantity3, v.quantity4, 
     v.indicator1, v.indicator2, 
     @v_quantity1label as quantity1label, @v_quantity2label as quantity2label, 
     @v_quantity3label as quantity3label, @v_quantity4label as quantity4label, 
     @v_indicator1label as indicator1label, @v_indicator2label as indicator2label, 

		 @v_miscitemkey1 as miscitemkey1, @v_miscitem1label as miscitem1label, 
		 dbo.qproject_get_misc_value( v.relatedprojectkey, @v_miscitemkey1 ) miscItem1value, 
		 @v_miscitemkey2 as miscitemkey2, @v_miscitem2label as miscitem2label, 
		 dbo.qproject_get_misc_value( v.relatedprojectkey, @v_miscitemkey2 ) miscItem2value, 
		 @v_miscitemkey3 as miscitemkey3, @v_miscitem3label as miscitem3label, 
		 dbo.qproject_get_misc_value( v.relatedprojectkey, @v_miscitemkey3 ) miscItem3value, 
		 @v_miscitemkey4 as miscitemkey4, @v_miscitem4label as miscitem4label, 
		 dbo.qproject_get_misc_value( v.relatedprojectkey, @v_miscitemkey4 ) miscItem4value, 
		 @v_miscitemkey5 as miscitemkey5, @v_miscitem5label as miscitem5label, 
		 dbo.qproject_get_misc_value( v.relatedprojectkey, @v_miscitemkey5 ) miscItem5value, 
		 @v_miscitemkey6 as miscitemkey6, @v_miscitem6label as miscitem6label, 
		 dbo.qproject_get_misc_value( v.relatedprojectkey, @v_miscitemkey6 ) miscItem6value, 

		 dbo.qutl_get_misc_fieldformat(@v_miscitemkey1) fieldformat1, 
		 dbo.qutl_get_misc_fieldformat(@v_miscitemkey2) fieldformat2, 
		 dbo.qutl_get_misc_fieldformat(@v_miscitemkey3) fieldformat3, 
		 dbo.qutl_get_misc_fieldformat(@v_miscitemkey4) fieldformat4, 
		 dbo.qutl_get_misc_fieldformat(@v_miscitemkey5) fieldformat5, 
		 dbo.qutl_get_misc_fieldformat(@v_miscitemkey6) fieldformat6, 
			 
		 @v_datetypecode1 as datetypecode1,@v_date1label as date1label, 
		 dbo.qproject_get_last_taskdate( v.relatedprojectkey, @v_datetypecode1 ) as date1value, 
		 @v_datetypecode2 as datetypecode2, @v_date2label as date2label, 
         dbo.qproject_get_last_taskdate( v.relatedprojectkey, @v_datetypecode2 ) as date2value,
		 @v_datetypecode3 as datetypecode3, @v_date3label as date3label, 
         dbo.qproject_get_last_taskdate( v.relatedprojectkey, @v_datetypecode3 ) as date3value,
		 @v_datetypecode4 as datetypecode4, @v_date4label as date4label, 
         dbo.qproject_get_last_taskdate( v.relatedprojectkey, @v_datetypecode4 ) as date4value,
		 @v_datetypecode5 as datetypecode5, @v_date5label as date5label, 
         dbo.qproject_get_last_taskdate( v.relatedprojectkey, @v_datetypecode5 ) as date5value,
		 @v_datetypecode6 as datetypecode6, @v_date6label as date6label, 
         dbo.qproject_get_last_taskdate( v.relatedprojectkey, @v_datetypecode6 ) as date6value,

		 @v_pricetypecode1 as pricetypecode1, @v_price1label as price1label, 
         dbo.qproject_get_price_by_pricetype( v.relatedprojectkey, @v_pricetypecode1 ) as pricetypecode1Value,
		 @v_pricetypecode2 as pricetypecode2, @v_price2label as price2label, 
         dbo.qproject_get_price_by_pricetype( v.relatedprojectkey, @v_pricetypecode2 ) as pricetypecode2Value,
		 @v_pricetypecode3 as pricetypecode3, @v_price3label as price3label, 
         dbo.qproject_get_price_by_pricetype( v.relatedprojectkey, @v_pricetypecode3 ) as pricetypecode3Value,
		 @v_pricetypecode4 as pricetypecode4, @v_price4label as price4label, 
         dbo.qproject_get_price_by_pricetype( v.relatedprojectkey, @v_pricetypecode4 ) as pricetypecode4Value,

		 @v_productidcode1 as productidcode1, @v_productid1label as productid1label, 
		 ( SELECT productnumber FROM taqproductnumbers WHERE ( taqprojectkey = v.relatedprojectkey AND productidcode = @v_productidcode1 ) ) as productIdCode1Value,
		 @v_productidcode2 as productidcode2, @v_productid2label as productid2label, 
		 ( SELECT productnumber FROM taqproductnumbers WHERE ( taqprojectkey = v.relatedprojectkey AND productidcode = @v_productidcode2 ) ) as productIdCode2Value,

		 @v_roletypecode1 as roletypecode1, @v_roletype1label as roletype1label, 
		 dbo.qproject_get_participant_name_by_role( v.relatedprojectkey, @v_roletypecode1) as roletypecode1Value,
		 @v_roletypecode2 as roletypecode2, @v_roletype2label as roletype2label, 
		 dbo.qproject_get_participant_name_by_role( v.relatedprojectkey, @v_roletypecode2) as roletypecode2Value,

         @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid

    FROM projectrelationshipview v, coreprojectinfo c
   WHERE v.relatedprojectkey = c.projectkey 
     AND v.taqprojectkey = @i_projectkey
     AND c.searchitemcode = @v_otheritemtype and c.usageclasscode = @v_otherusageclass  -- only want volumes

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on taqprojectrelationship (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 
END
GO 

GRANT EXEC ON qproject_get_relationships_volume TO PUBLIC
GO
