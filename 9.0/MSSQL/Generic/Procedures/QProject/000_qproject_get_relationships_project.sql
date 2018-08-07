IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_relationships_project') )
DROP PROCEDURE dbo.qproject_get_relationships_project
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_get_relationships_project]
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_relationships_project
**  Desc: This stored procedure returns all relationships
**        for a project. 
**
**    Auth: Alan Katzen
**    Date: 18 February 2008
**
**	  Revised: Jon Hess - 07/08/08 for project relationship tab enhancement
**	  Revised: Jon Hess - 07/18/08 for project relationship tab enhancement Phase II
**	  Rebised: Josh R	- 07/16/15 for project relationship tab fix - case #33406
*******************************************************************************/

DECLARE @error_var    INT,
  @rowcount_var INT,
  @v_configCount_1 INT,
  @v_configCount_2 INT,
  @v_configCount_3 INT,  
  @v_gentablesrelationshipkey INT,
  @v_qsicode INT,
  @v_relationshipTabCode INT,
  @v_itemType INT,
  @v_usageClass INT,
  @v_miscitemkey1 INT,
  @v_miscitemkey2 INT,
  @v_miscitemkey3 INT,
  @v_miscitemkey4 INT,
  @v_miscitemkey5 INT,
  @v_miscitemkey6 INT,
  @v_datetypecode1 INT,
  @v_datetypecode2 INT,
  @v_datetypecode3 INT,
  @v_datetypecode4 INT,
  @v_datetypecode5 INT,
  @v_datetypecode6 INT,
  @v_productidcode1 INT,
  @v_productidcode2 INT,
  @v_roletypecode1 INT,
  @v_roletypecode2 INT,
  @v_pricetypecode1 INT,
  @v_pricetypecode2 INT,
  @v_pricetypecode3 INT,
  @v_pricetypecode4 INT,
  @v_decimal1 INT,
  @v_decimal2 INT,
  @v_decimal1format VARCHAR(40),
  @v_decimal2format VARCHAR(40),   
  @v_tableid1 INT,
  @v_tableid2 INT,
  @v_lastmaintdate datetime,
  @v_lastuserid varchar(100),
  @v_hidedeletebuttonind TINYINT  

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_hidedeletebuttonind = NULL

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

  -- Tab for Projects
  SET @v_qsicode = 1
   
	SELECT @v_relationshipTabCode = datacode FROM gentables where tableid =  583 and qsicode = @v_qsicode

  -- coreprojectinfo with project key and get itemtype/searchitem and usage class  
	SELECT @v_itemType = searchitemcode, @v_usageClass = usageclasscode
	FROM  coreprojectinfo
	WHERE projectkey = @i_projectkey
		
--********************************************************************

	-- Run three counts against tabrelationshiptabconfig, 
	-- 1. Matching relationshiptabcode, itemtypecode and usageclass
	-- 2. Matching relationshiptabcode and itemtype with NULL usageclass
	-- 3. Matching relationshiptabcode and NULL itemtype and usageclass
	-- This will satisfy the spec requirements as written: 
		/** "It will first check for the tab name using the item type/usage class of the current item 
		(for example. the Project Key of the Project you are on in Project Summary) on taqrelationshiptabconfig.  
		If nothing is found for the item type/usage class, check again using the item type with a null usage class; 
		this will find a default for the item type if there is any.  If nothing is selected still, check again with 
		both the item type and usage class set to null; this will find a default for the tab if there is any.
		If nothing is found at all, set all of the configurable columns to invisible. " **/

	SET		@v_configCount_1 = 0
	SET		@v_configCount_2 = 0
	SET		@v_configCount_3 = 0

  SELECT @v_configCount_1 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass = @v_usageClass

  SELECT @v_configCount_2 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass IS NULL

  SELECT @v_configCount_3 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode IS NULL AND usageclass IS NULL

	IF @v_configCount_1 > 0
		SELECT @v_miscitemkey1 = miscitemkey1, @v_miscitemkey2 = miscitemkey2, 
			@v_miscitemkey3 = miscitemkey3, @v_miscitemkey4 = miscitemkey4, 
			@v_miscitemkey5 = miscitemkey5, @v_miscitemkey6 = miscitemkey6, 
			@v_datetypecode1 = datetypecode1, @v_datetypecode2 = datetypecode2, 
			@v_datetypecode3 = datetypecode3, @v_datetypecode4 = datetypecode4, 
			@v_datetypecode5 = datetypecode5, @v_datetypecode6 = datetypecode6, 
			@v_productidcode1 = Productidcode1, @v_productidcode2 = Productidcode2, 
			@v_roletypecode1 = roletypecode1, @v_roletypecode2 = roletypecode2, 
			@v_pricetypecode1 = pricetypecode1, @v_pricetypecode2 = pricetypecode2, 
			@v_pricetypecode3 = pricetypecode3, @v_pricetypecode4 = pricetypecode4, 
			@v_decimal1format = decimal1format, @v_decimal2format = decimal2format,				
      @v_tableid1 = tableid1, @v_tableid2 = tableid2, 
			@v_lastmaintdate = lastmaintdate, @v_lastuserid = lastuserid,
			@v_hidedeletebuttonind = hidedeletebuttonind			
		FROM taqrelationshiptabconfig
		WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass = @v_usageClass

	ELSE IF @v_configCount_2 > 0
    SELECT @v_miscitemkey1 = miscitemkey1, @v_miscitemkey2 = miscitemkey2, 
			@v_miscitemkey3 = miscitemkey3, @v_miscitemkey4 = miscitemkey4, 
			@v_miscitemkey5 = miscitemkey5, @v_miscitemkey6 = miscitemkey6, 
			@v_datetypecode1 = datetypecode1, @v_datetypecode2 = datetypecode2, 
			@v_datetypecode3 = datetypecode3, @v_datetypecode4 = datetypecode4, 
			@v_datetypecode5 = datetypecode5, @v_datetypecode6 = datetypecode6, 
			@v_productidcode1 = Productidcode1, @v_productidcode2 = Productidcode2, 
			@v_roletypecode1 = roletypecode1, @v_roletypecode2 = roletypecode2, 
			@v_pricetypecode1 = pricetypecode1, @v_pricetypecode2 = pricetypecode2, 
			@v_pricetypecode3 = pricetypecode3, @v_pricetypecode4 = pricetypecode4, 
			@v_decimal1format = decimal1format, @v_decimal2format = decimal2format,			
      @v_tableid1 = tableid1, @v_tableid2 = tableid2, 
			@v_lastmaintdate = lastmaintdate, @v_lastuserid = lastuserid,
			@v_hidedeletebuttonind = hidedeletebuttonind			
    FROM taqrelationshiptabconfig
    WHERE relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass IS NULL

	ELSE IF @v_configCount_3 > 0
    SELECT @v_miscitemkey1 = miscitemkey1, @v_miscitemkey2 = miscitemkey2, 
			@v_miscitemkey3 = miscitemkey3, @v_miscitemkey4 = miscitemkey4, 
			@v_miscitemkey5 = miscitemkey5, @v_miscitemkey6 = miscitemkey6, 
			@v_datetypecode1 = datetypecode1, @v_datetypecode2 = datetypecode2, 
			@v_datetypecode3 = datetypecode3, @v_datetypecode4 = datetypecode4, 
			@v_datetypecode5 = datetypecode5, @v_datetypecode6 = datetypecode6, 
			@v_productidcode1 = Productidcode1, @v_productidcode2 = Productidcode2, 
			@v_roletypecode1 = roletypecode1, @v_roletypecode2 = roletypecode2, 
			@v_pricetypecode1 = pricetypecode1, @v_pricetypecode2 = pricetypecode2, 
			@v_pricetypecode3 = pricetypecode3, @v_pricetypecode4 = pricetypecode4, 
			@v_decimal1format = decimal1format, @v_decimal2format = decimal2format,			
      @v_tableid1 = tableid1, @v_tableid2 = tableid2, 
			@v_lastmaintdate = lastmaintdate, @v_lastuserid = lastuserid,
			@v_hidedeletebuttonind = hidedeletebuttonind			
    FROM taqrelationshiptabconfig
    WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode IS NULL AND usageclass IS NULL

  --********************************************************************
  -- retrieve relationships in both directions
  IF @v_itemType = 6 BEGIN
    -- Journal
    SELECT 1 projectnumber,
      taqprojectkey1 thisprojectkey, 
      taqprojectkey2 otherprojectkey, 
      relationshipcode1 thisrelationshipcode, 
      dbo.get_gentables_desc(582,relationshipcode1,'long') thisrelationshipdesc,
      relationshipcode2 otherrelationshipcode, 
      COALESCE(c.projecttitle,r.projectname2) otherprojectdisplayname,  
      COALESCE(c.projectstatusdesc,r.project2status) otherprojectstatus,  
      COALESCE(c.projectstatus,0) otherprojectstatuscode, 
      CASE c.searchitemcode
        WHEN 9 THEN (SELECT t.authorname FROM coretitleinfo t, taqproject p WHERE p.taqprojectkey = c.projectkey AND t.bookkey = p.workkey AND t.printingkey = 1)
        ELSE COALESCE(c.projectparticipants,r.project2participants)
      END otherprojectparticipants,     
      r.taqprojectrelationshipkey, r.relationshipaddtldesc, r.keyind, r.sortorder,
      c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
      cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
      c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder, 
      r.quantity1, r.quantity2, r.decimal1, @v_decimal1format as decimal1format, r.decimal2, @v_decimal2format as decimal2format, r.indicator1, r.indicator2, 
      dbo.qpl_allow_remove_relationship(taqprojectkey1, taqprojectkey2) allowremoverelationship,
      dbo.qpl_is_master_pl_project(taqprojectkey1) isthisprojectmasterplproject,  
      dbo.qpl_is_master_pl_project(taqprojectkey2) isotherprojectmasterplproject,       
      @v_miscitemkey1 as miscitemkey1, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey1 ) miscItem1value, 
      @v_miscitemkey2 as miscitemkey2, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey2 ) miscItem2value, 
      @v_miscitemkey3 as miscitemkey3, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey3 ) miscItem3value, 
      @v_miscitemkey4 as miscitemkey4, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey4 ) miscItem4value, 
      @v_miscitemkey5 as miscitemkey5, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey5 ) miscItem5value, 
      @v_miscitemkey6 as miscitemkey6, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey6 ) miscItem6value,
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey1) fieldformat1, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey2) fieldformat2, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey3) fieldformat3, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey4) fieldformat4, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey5) fieldformat5, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey6) fieldformat6,          
      @v_datetypecode1 as datetypecode1, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode1 ) as date1value, 
      @v_datetypecode2 as datetypecode2, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode2 ) as date2value,
      @v_datetypecode3 as datetypecode3, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode3 ) as date3value,
      @v_datetypecode4 as datetypecode4, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode4 ) as date4value,
      @v_datetypecode5 as datetypecode5, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode5 ) as date5value,
      @v_datetypecode6 as datetypecode6, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode6 ) as date6value,
      @v_pricetypecode1 as pricetypecode1, dbo.qproject_get_price_by_pricetype( r.taqprojectkey2, @v_pricetypecode1 ) as pricetypecode1Value,
      @v_pricetypecode2 as pricetypecode2, dbo.qproject_get_price_by_pricetype( r.taqprojectkey2, @v_pricetypecode2 ) as pricetypecode2Value,
      @v_pricetypecode3 as pricetypecode3, dbo.qproject_get_price_by_pricetype( r.taqprojectkey2, @v_pricetypecode3 ) as pricetypecode3Value,
      @v_pricetypecode4 as pricetypecode4, dbo.qproject_get_price_by_pricetype( r.taqprojectkey2, @v_pricetypecode4 ) as pricetypecode4Value,
      @v_productidcode1 as productidcode1, 
      (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey2 AND productidcode = @v_productidcode1) as productIdCode1Value,
      @v_productidcode2 as productidcode2, 
      (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey2 AND productidcode = @v_productidcode2) as productIdCode2Value,
      @v_roletypecode1 as roletypecode1, dbo.qproject_get_participant_name_by_role( r.taqprojectkey2, @v_roletypecode1) as roletypecode1Value,
      @v_roletypecode2 as roletypecode2, dbo.qproject_get_participant_name_by_role( r.taqprojectkey2, @v_roletypecode2) as roletypecode2Value,		 
      @v_tableid1 as tableid1,
      dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid1, r.datacode1) as datacode1,
      dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid1, r.datacode1) as datacode1Value,
      @v_tableid2 as tableid2,
      dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid2, r.datacode2) as datacode2,
      dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid2, r.datacode2) as datacode2Value,
      @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid, @v_hidedeletebuttonind as hidedeletebuttonind  
    FROM taqprojectrelationship r 
      LEFT OUTER JOIN coreprojectinfo c ON r.taqprojectkey2 = c.projectkey
    WHERE r.taqprojectkey1 = @i_projectkey AND
      (relationshipcode1 IN 
        (SELECT DISTINCT code1 FROM gentablesrelationshipdetail
        WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND
        code2 IN (SELECT datacode FROM gentables WHERE tableid = 583 AND qsicode = @v_qsicode)) OR
      relationshipcode1 NOT IN 
        (SELECT DISTINCT code1 FROM gentablesrelationshipdetail 
        WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND
        code2 IN (SELECT datacode FROM gentables 
          WHERE tableid = 583 AND --alternatedesc2 LIKE '%ProjectsGeneric%' AND 
          datacode IN (SELECT datacode FROM gentablesitemtype
                       WHERE tableid = 583 AND itemtypecode = @v_itemType AND COALESCE(itemtypesubcode,0) IN (0,@v_usageClass)) )) )                                                                                              
    UNION
    SELECT 2 projectnumber, 
      taqprojectkey2 thisprojectkey, 
      taqprojectkey1 otherprojectkey, 
      relationshipcode2 thisrelationshipcode, 
      dbo.get_gentables_desc(582,relationshipcode2,'long') thisrelationshipdesc,
      relationshipcode1 otherrelationshipcode, 
      c.projecttitle otherprojectdisplayname,  
      c.projectstatusdesc otherprojectstatus,  
      COALESCE(c.projectstatus,0) otherprojectstatuscode,  
      CASE c.searchitemcode
        WHEN 9 THEN (SELECT t.authorname FROM coretitleinfo t, taqproject p WHERE p.taqprojectkey = c.projectkey AND t.bookkey = p.workkey AND t.printingkey = 1)
        ELSE c.projectparticipants
      END otherprojectparticipants,    
      r.taqprojectrelationshipkey, r.relationshipaddtldesc, r.keyind, r.sortorder,
      c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
      cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
      c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder, 	 		
      r.quantity1, r.quantity2, r.decimal1, @v_decimal1format as decimal1format, r.decimal2, @v_decimal2format as decimal2format, r.indicator1, r.indicator2, 
      dbo.qpl_allow_remove_relationship(taqprojectkey2, taqprojectkey1) allowremoverelationship,
      dbo.qpl_is_master_pl_project(taqprojectkey2) isthisprojectmasterplproject,  
      dbo.qpl_is_master_pl_project(taqprojectkey1) isotherprojectmasterplproject,      
      @v_miscitemkey1 as miscitemkey1, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey1 ) miscItem1value, 
      @v_miscitemkey2 as miscitemkey2, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey2 ) miscItem2value, 
      @v_miscitemkey3 as miscitemkey3, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey3 ) miscItem3value, 
      @v_miscitemkey4 as miscitemkey4, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey4 ) miscItem4value, 
      @v_miscitemkey5 as miscitemkey5, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey5 ) miscItem5value, 
      @v_miscitemkey6 as miscitemkey6, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey6 ) miscItem6value, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey1) fieldformat1, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey2) fieldformat2, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey3) fieldformat3, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey4) fieldformat4, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey5) fieldformat5, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey6) fieldformat6,        
      @v_datetypecode1 as datetypecode1, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode1 ) as date1value, 
      @v_datetypecode2 as datetypecode2, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode2 ) as date2value,
      @v_datetypecode3 as datetypecode3, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode3 ) as date3value,
      @v_datetypecode4 as datetypecode4, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode4 ) as date4value,
      @v_datetypecode5 as datetypecode5, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode5 ) as date5value,
      @v_datetypecode6 as datetypecode6, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode6 ) as date6value,
      @v_pricetypecode1 as pricetypecode1, dbo.qproject_get_price_by_pricetype( r.taqprojectkey1, @v_pricetypecode1 ) as pricetypecode1Value,
      @v_pricetypecode2 as pricetypecode2, dbo.qproject_get_price_by_pricetype( r.taqprojectkey1, @v_pricetypecode2 ) as pricetypecode2Value,
      @v_pricetypecode3 as pricetypecode3, dbo.qproject_get_price_by_pricetype( r.taqprojectkey1, @v_pricetypecode3 ) as pricetypecode3Value,
      @v_pricetypecode4 as pricetypecode4, dbo.qproject_get_price_by_pricetype( r.taqprojectkey1, @v_pricetypecode4 ) as pricetypecode4Value,
      @v_productidcode1 as productidcode1, 
      (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey1 AND productidcode = @v_productidcode1) as productIdCode1Value,
      @v_productidcode2 as productidcode2, 
      (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey1 AND productidcode = @v_productidcode2) as productIdCode2Value,
      @v_roletypecode1 as roletypecode1, dbo.qproject_get_participant_name_by_role( r.taqprojectkey1, @v_roletypecode1) as roletypecode1Value,
      @v_roletypecode2 as roletypecode2, dbo.qproject_get_participant_name_by_role( r.taqprojectkey1, @v_roletypecode2) as roletypecode2Value,    
      @v_tableid1 as tableid1,
      dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid1, r.datacode1) as datacode1,
      dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid1, r.datacode1) as datacode1Value,
      @v_tableid2 as tableid2,
      dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid2, r.datacode2) as datacode2,
      dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid2, r.datacode2) as datacode2Value,
      @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid, @v_hidedeletebuttonind as hidedeletebuttonind  
    FROM taqprojectrelationship r 
      LEFT OUTER JOIN coreprojectinfo c ON r.taqprojectkey1 = c.projectkey
    WHERE r.taqprojectkey2 = @i_projectkey AND
      (relationshipcode2 IN 
        (SELECT DISTINCT code1 FROM gentablesrelationshipdetail
        WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND
        code2 IN (SELECT datacode FROM gentables WHERE tableid = 583 AND qsicode = @v_qsicode)) OR
      relationshipcode2 NOT IN 
        (SELECT DISTINCT code1 FROM gentablesrelationshipdetail 
        WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND
        code2 IN (SELECT datacode FROM gentables 
          WHERE tableid = 583 AND --alternatedesc2 LIKE '%ProjectsGeneric%' AND 
          datacode IN (SELECT datacode FROM gentablesitemtype
                       WHERE tableid = 583 AND itemtypecode = @v_itemType AND COALESCE(itemtypesubcode,0) IN (0,@v_usageClass)) )) )               
    ORDER BY r.keyind DESC, r.sortorder ASC, thisrelationshipcode ASC, otherrelationshipcode ASC
  END
  ELSE BEGIN
    SELECT 1 projectnumber,
      taqprojectkey1 thisprojectkey, 
      taqprojectkey2 otherprojectkey, 
      relationshipcode1 thisrelationshipcode, 
      dbo.get_gentables_desc(582,relationshipcode1,'long') thisrelationshipdesc,
      relationshipcode2 otherrelationshipcode, 
      COALESCE(c.projecttitle,r.projectname2) otherprojectdisplayname,  
      COALESCE(c.projectstatusdesc,r.project2status) otherprojectstatus,  
      COALESCE(c.projectstatus,0) otherprojectstatuscode, 
      CASE c.searchitemcode
        WHEN 9 THEN (SELECT t.authorname FROM coretitleinfo t, taqproject p WHERE p.taqprojectkey = c.projectkey AND t.bookkey = p.workkey AND t.printingkey = 1)
        ELSE COALESCE(c.projectparticipants,r.project2participants)
      END otherprojectparticipants,     
      r.taqprojectrelationshipkey, r.relationshipaddtldesc, r.keyind, r.sortorder,
      c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
      cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
      c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder, 
      r.quantity1, r.quantity2, r.decimal1, @v_decimal1format as decimal1format, r.decimal2, @v_decimal2format as decimal2format, r.indicator1, r.indicator2, 
      dbo.qpl_allow_remove_relationship(taqprojectkey1, taqprojectkey2) allowremoverelationship,
      dbo.qpl_is_master_pl_project(taqprojectkey1) isthisprojectmasterplproject,  
      dbo.qpl_is_master_pl_project(taqprojectkey2) isotherprojectmasterplproject,      
      @v_miscitemkey1 as miscitemkey1, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey1 ) miscItem1value, 
      @v_miscitemkey2 as miscitemkey2, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey2 ) miscItem2value, 
      @v_miscitemkey3 as miscitemkey3, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey3 ) miscItem3value, 
      @v_miscitemkey4 as miscitemkey4, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey4 ) miscItem4value, 
      @v_miscitemkey5 as miscitemkey5, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey5 ) miscItem5value, 
      @v_miscitemkey6 as miscitemkey6, dbo.qproject_get_misc_value( r.taqprojectkey2, @v_miscitemkey6 ) miscItem6value, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey1) fieldformat1, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey2) fieldformat2, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey3) fieldformat3, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey4) fieldformat4, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey5) fieldformat5, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey6) fieldformat6,        
      @v_datetypecode1 as datetypecode1, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode1 ) as date1value, 
      @v_datetypecode2 as datetypecode2, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode2 ) as date2value,
      @v_datetypecode3 as datetypecode3, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode3 ) as date3value,
      @v_datetypecode4 as datetypecode4, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode4 ) as date4value,
      @v_datetypecode5 as datetypecode5, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode5 ) as date5value,
      @v_datetypecode6 as datetypecode6, dbo.qproject_get_last_taskdate2( r.taqprojectkey2, @v_datetypecode6 ) as date6value,
      @v_pricetypecode1 as pricetypecode1, dbo.qproject_get_price_by_pricetype( r.taqprojectkey2, @v_pricetypecode1 ) as pricetypecode1Value,
      @v_pricetypecode2 as pricetypecode2, dbo.qproject_get_price_by_pricetype( r.taqprojectkey2, @v_pricetypecode2 ) as pricetypecode2Value,
      @v_pricetypecode3 as pricetypecode3, dbo.qproject_get_price_by_pricetype( r.taqprojectkey2, @v_pricetypecode3 ) as pricetypecode3Value,
      @v_pricetypecode4 as pricetypecode4, dbo.qproject_get_price_by_pricetype( r.taqprojectkey2, @v_pricetypecode4 ) as pricetypecode4Value,
      @v_productidcode1 as productidcode1, 
      (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey2 AND productidcode = @v_productidcode1) as productIdCode1Value,
      @v_productidcode2 as productidcode2, 
      (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey2 AND productidcode = @v_productidcode2) as productIdCode2Value,
      @v_roletypecode1 as roletypecode1, dbo.qproject_get_participant_name_by_role( r.taqprojectkey2, @v_roletypecode1) as roletypecode1Value,
      @v_roletypecode2 as roletypecode2, dbo.qproject_get_participant_name_by_role( r.taqprojectkey2, @v_roletypecode2) as roletypecode2Value,		 
      @v_tableid1 as tableid1,
      dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid1, r.datacode1) as datacode1,
      dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid1, r.datacode1) as datacode1Value,
      @v_tableid2 as tableid2,
      dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid2, r.datacode2) as datacode2,
      dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid2, r.datacode2) as datacode2Value,
      @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid, @v_hidedeletebuttonind as hidedeletebuttonind  
    FROM taqprojectrelationship r 
      LEFT OUTER JOIN coreprojectinfo c ON r.taqprojectkey2 = c.projectkey
    WHERE r.taqprojectkey1 = @i_projectkey AND
      (relationshipcode1 IN 
        (SELECT DISTINCT code1 FROM gentablesrelationshipdetail
        WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND
        code2 IN (SELECT datacode FROM gentables WHERE tableid = 583 AND qsicode = @v_qsicode)) OR
      relationshipcode1 NOT IN 
        (SELECT DISTINCT code1 FROM gentablesrelationshipdetail 
        WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND
        code2 IN (SELECT datacode FROM gentables 
          WHERE tableid = 583 -- AND alternatedesc2 LIKE '%ProjectsGeneric%' 
          AND datacode IN (SELECT datacode FROM gentablesitemtype
                       WHERE tableid = 583 AND itemtypecode = @v_itemType AND COALESCE(itemtypesubcode,0) IN (0,@v_usageClass)) )) )                                                                                              
    UNION
    SELECT 2 projectnumber, 
      taqprojectkey2 thisprojectkey, 
      taqprojectkey1 otherprojectkey, 
      relationshipcode2 thisrelationshipcode, 
      dbo.get_gentables_desc(582,relationshipcode2,'long') thisrelationshipdesc,
      relationshipcode1 otherrelationshipcode, 
      c.projecttitle otherprojectdisplayname,  
      c.projectstatusdesc otherprojectstatus,  
      COALESCE(c.projectstatus,0) otherprojectstatuscode,  
      CASE c.searchitemcode
        WHEN 9 THEN (SELECT t.authorname FROM coretitleinfo t, taqproject p WHERE p.taqprojectkey = c.projectkey AND t.bookkey = p.workkey AND t.printingkey = 1)
        ELSE c.projectparticipants
      END otherprojectparticipants,    
      r.taqprojectrelationshipkey, r.relationshipaddtldesc, r.keyind, r.sortorder,
      c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
      cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
      c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder, 	 		
      r.quantity1, r.quantity2, r.decimal1, @v_decimal1format as decimal1format, r.decimal2, @v_decimal2format as decimal2format, r.indicator1, r.indicator2, 
      dbo.qpl_allow_remove_relationship(taqprojectkey2, taqprojectkey1) allowremoverelationship,
      dbo.qpl_is_master_pl_project(taqprojectkey2) isthisprojectmasterplproject,  
      dbo.qpl_is_master_pl_project(taqprojectkey1) isotherprojectmasterplproject,      
      @v_miscitemkey1 as miscitemkey1, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey1 ) miscItem1value, 
      @v_miscitemkey2 as miscitemkey2, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey2 ) miscItem2value, 
      @v_miscitemkey3 as miscitemkey3, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey3 ) miscItem3value, 
      @v_miscitemkey4 as miscitemkey4, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey4 ) miscItem4value, 
      @v_miscitemkey5 as miscitemkey5, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey5 ) miscItem5value, 
      @v_miscitemkey6 as miscitemkey6, dbo.qproject_get_misc_value( r.taqprojectkey1, @v_miscitemkey6 ) miscItem6value, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey1) fieldformat1, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey2) fieldformat2, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey3) fieldformat3, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey4) fieldformat4, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey5) fieldformat5, 
	  dbo.qutl_get_misc_fieldformat(@v_miscitemkey6) fieldformat6,        
      @v_datetypecode1 as datetypecode1, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode1 ) as date1value, 
      @v_datetypecode2 as datetypecode2, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode2 ) as date2value,
      @v_datetypecode3 as datetypecode3, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode3 ) as date3value,
      @v_datetypecode4 as datetypecode4, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode4 ) as date4value,
      @v_datetypecode5 as datetypecode5, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode5 ) as date5value,
      @v_datetypecode6 as datetypecode6, dbo.qproject_get_last_taskdate2( r.taqprojectkey1, @v_datetypecode6 ) as date6value,
      @v_pricetypecode1 as pricetypecode1, dbo.qproject_get_price_by_pricetype( r.taqprojectkey1, @v_pricetypecode1 ) as pricetypecode1Value,
      @v_pricetypecode2 as pricetypecode2, dbo.qproject_get_price_by_pricetype( r.taqprojectkey1, @v_pricetypecode2 ) as pricetypecode2Value,
      @v_pricetypecode3 as pricetypecode3, dbo.qproject_get_price_by_pricetype( r.taqprojectkey1, @v_pricetypecode3 ) as pricetypecode3Value,
      @v_pricetypecode4 as pricetypecode4, dbo.qproject_get_price_by_pricetype( r.taqprojectkey1, @v_pricetypecode4 ) as pricetypecode4Value,
      @v_productidcode1 as productidcode1, 
      (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey1 AND productidcode = @v_productidcode1) as productIdCode1Value,
      @v_productidcode2 as productidcode2, 
      (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey1 AND productidcode = @v_productidcode2) as productIdCode2Value,
      @v_roletypecode1 as roletypecode1, dbo.qproject_get_participant_name_by_role( r.taqprojectkey1, @v_roletypecode1) as roletypecode1Value,
      @v_roletypecode2 as roletypecode2, dbo.qproject_get_participant_name_by_role( r.taqprojectkey1, @v_roletypecode2) as roletypecode2Value,    
      @v_tableid1 as tableid1,
      dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid1, r.datacode1) as datacode1,
      dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid1, r.datacode1) as datacode1Value,
      @v_tableid2 as tableid2,
      dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid2, r.datacode2) as datacode2,
      dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid2, r.datacode2) as datacode2Value,
      @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid, @v_hidedeletebuttonind as hidedeletebuttonind  
    FROM taqprojectrelationship r 
      LEFT OUTER JOIN coreprojectinfo c ON r.taqprojectkey1 = c.projectkey
    WHERE r.taqprojectkey2 = @i_projectkey AND
      (relationshipcode2 IN 
        (SELECT DISTINCT code1 FROM gentablesrelationshipdetail
        WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND
        code2 IN (SELECT datacode FROM gentables WHERE tableid = 583 AND qsicode = @v_qsicode)) OR
      relationshipcode2 NOT IN 
        (SELECT DISTINCT code1 FROM gentablesrelationshipdetail 
        WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND
        code2 IN (SELECT datacode FROM gentables 
          WHERE tableid = 583 -- AND alternatedesc2 LIKE '%ProjectsGeneric%' 
          AND datacode IN (SELECT datacode FROM gentablesitemtype
                       WHERE tableid = 583 AND itemtypecode = @v_itemType AND COALESCE(itemtypesubcode,0) IN (0,@v_usageClass)) )) )               
    ORDER BY r.keyind DESC, r.sortorder ASC, thisrelationshipcode ASC, otherrelationshipcode ASC  
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on taqprojectrelationship (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

END
go

GRANT EXEC ON qproject_get_relationships_project TO PUBLIC
GO





