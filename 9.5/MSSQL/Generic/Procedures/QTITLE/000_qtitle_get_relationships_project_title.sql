IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_relationships_project_title') )
DROP PROCEDURE dbo.qtitle_get_relationships_project_title
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.qtitle_get_relationships_project_title
 (@i_bookkey     integer,
  @i_relationshiptab_datacode    integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_relationships_project_title
**  Desc: This stored procedure returns all project relationships for a title. 
**
**    Auth: Alan Katzen
**    Date: 9 September 2008
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:        Author:     Description:
**    --------     --------    -------------------------------------------
**   01/26/2016	   UK		       Case 35031 - Task 003
**	 05/11/2016    Colman      Added userkey input for taskdate accesscode output
**	 06/06/2016    Colman      38278 - Return sortable string value for numeric misc columns
**   08/03/2016    Colman      39608 - Run misc calc on calculated dates
*******************************************************************************/

DECLARE
  @v_configCount_1 INT,
  @v_configCount_2 INT,
  @v_configCount_3 INT,
  @error_var    INT,
  @rowcount_var INT,
  @v_gentablesrelationshipkey INT,
  @v_relationshipTabCode INT,
  @v_itemType INT,
  @v_usageClass INT,
  @v_qsicode INT,
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
  @v_hidedeletebuttonind TINYINT,
  @v_thisbookkey INT,
  @v_thisprintingkey INT,
  @v_othertaqprojectkey INT,
  @v_thistitlerolecode INT,
  @v_otherprojectrolecode INT,
  @v_miscitemtype INT,
  @v_calcvalue	VARCHAR(255),
  @v_sortvalue	VARCHAR(255)    
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_hidedeletebuttonind = NULL

  SELECT @v_gentablesrelationshipkey = COALESCE(gentablesrelationshipkey,0)
  FROM gentablesrelationships
  WHERE gentable1id = 604 and gentable2id = 583

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing gentablesrelationships: bookkey = ' + cast(@i_bookkey AS VARCHAR)
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
    -- Tab datacode not passed in use generic - Tab Projects for Titles (qsicode = 14)
	  SELECT @v_relationshipTabCode = datacode FROM gentables where tableid = 583 and qsicode = 14
	  SET @v_qsicode = 14
  END
  
	SELECT @v_itemType = itemtypecode, @v_usageClass = usageclasscode
	FROM coretitleinfo
	WHERE bookkey = @i_bookkey
	
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Coulc not access coretitleinfo table: bookkey=' + cast(@i_bookkey AS VARCHAR)
    RETURN  
  END	
				
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

  SELECT @v_configCount_1 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass = @v_usageClass

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
    WHERE relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass = @v_usageClass

	ELSE IF @v_configCount_2 > 0
    SELECT
      @v_miscitemkey1 = miscitemkey1, @v_miscitemkey2 = miscitemkey2, 
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
    WHERE	relationshiptabcode = @v_relationshipTabCode AND itemtypecode = @v_itemType AND usageclass IS NULL

	ELSE IF @v_configCount_3 > 0
    SELECT
      @v_miscitemkey1 = miscitemkey1, @v_miscitemkey2 = miscitemkey2, 
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
  SELECT r.taqprojectformatkey,
    r.taqprojectkey, 
    r.bookkey, 
    r.printingkey, 
    r.projectrolecode, 
    dbo.get_gentables_desc(604,r.projectrolecode,'long') projectroledesc,
    r.titlerolecode, 
    dbo.get_gentables_desc(605,r.titlerolecode,'long') titleroledesc,
    COALESCE(c.projecttitle,r.relateditem2name) projectdisplayname,  
    COALESCE(c.projectstatusdesc,r.relateditem2status) projectstatus,  
    COALESCE(c.projectstatus,0) projectstatuscode,  
    COALESCE(c.projectparticipants,r.relateditem2participants) projectparticipants,  
    r.keyind, r.sortorder, r.taqprojectformatdesc,
    c.searchitemcode projectitemtypecode, c.usageclasscode projectusageclasscode, 
    cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) projectitemtypeusageclass,
    c.usageclasscodedesc projectusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder, 
    r.quantity1, r.quantity2, r.decimal1, @v_decimal1format as decimal1format, r.decimal2, @v_decimal2format as decimal2format, r.indicator1, r.indicator2, 
    @v_miscitemkey1 as miscitemkey1, 
    dbo.qproject_get_misc_value( r.taqprojectkey, @v_miscitemkey1 ) miscItem1value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey1 ) miscItem1sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey1) misctype1,   
    dbo.qutl_get_misc_label(@v_miscitemkey1) misclabel1, 
    dbo.qutl_get_miscname(@v_miscitemkey1) miscname1,	          
    dbo.qproject_get_misc_numeric_value( r.taqprojectkey, @v_miscitemkey1 ) miscItem1numericvalue,
    dbo.qproject_get_misc_float_value( r.taqprojectkey, @v_miscitemkey1 ) miscItem1floatvalue,        
    dbo.qproject_get_misc_text_value( r.taqprojectkey, @v_miscitemkey1 ) miscItem1textvalue,        
    dbo.qproject_get_misc_checkbox_value( r.taqprojectkey, @v_miscitemkey1 ) miscItem1checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( r.taqprojectkey, @v_miscitemkey1 ) miscItem1datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( r.taqprojectkey, @v_miscitemkey1 ) miscItem1datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( r.taqprojectkey, @v_miscitemkey1 ) miscItem1calculatedvalue, 
    dbo.qproject_get_misc_updateind( r.taqprojectkey, @v_miscitemkey1 ) updateind1,     
	dbo.qproject_exists_misc_entry( r.taqprojectkey, @v_miscitemkey1 ) existsmiscentry1,      
	dbo.qproject_exists_misc_default_entry( r.taqprojectkey, @v_miscitemkey1 ) existsmiscdefaultentry1,   
	dbo.qproject_exists_misc_section_entry( r.taqprojectkey, @v_miscitemkey1 ) existsmiscsectionentry1,    
    
    @v_miscitemkey2 as miscitemkey2, 
    dbo.qproject_get_misc_value( r.taqprojectkey, @v_miscitemkey2 ) miscItem2value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey2 ) miscItem2sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey2) misctype2,    
    dbo.qutl_get_misc_label(@v_miscitemkey2) misclabel2,    
    dbo.qutl_get_miscname(@v_miscitemkey2) miscname2,    
    dbo.qproject_get_misc_numeric_value( r.taqprojectkey, @v_miscitemkey2 ) miscItem2numericvalue,
    dbo.qproject_get_misc_float_value( r.taqprojectkey, @v_miscitemkey2 ) miscItem2floatvalue,        
    dbo.qproject_get_misc_text_value( r.taqprojectkey, @v_miscitemkey2 ) miscItem2textvalue,        
    dbo.qproject_get_misc_checkbox_value( r.taqprojectkey, @v_miscitemkey2 ) miscItem2checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( r.taqprojectkey, @v_miscitemkey2 ) miscItem2datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( r.taqprojectkey, @v_miscitemkey2 ) miscItem2datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( r.taqprojectkey, @v_miscitemkey2 ) miscItem2calculatedvalue, 
    dbo.qproject_get_misc_updateind( r.taqprojectkey, @v_miscitemkey2 ) updateind2, 
	dbo.qproject_exists_misc_entry( r.taqprojectkey, @v_miscitemkey2 ) existsmiscentry2,     
	dbo.qproject_exists_misc_default_entry( r.taqprojectkey, @v_miscitemkey2 ) existsmiscdefaultentry2,  
	dbo.qproject_exists_misc_section_entry( r.taqprojectkey, @v_miscitemkey2 ) existsmiscsectionentry2,             
    
    @v_miscitemkey3 as miscitemkey3, 
    dbo.qproject_get_misc_value( r.taqprojectkey, @v_miscitemkey3 ) miscItem3value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey3 ) miscItem3sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey3) misctype3,
    dbo.qutl_get_misc_label(@v_miscitemkey3) misclabel3, 
    dbo.qutl_get_miscname(@v_miscitemkey3) miscname3,        
    dbo.qproject_get_misc_numeric_value( r.taqprojectkey, @v_miscitemkey3 ) miscItem3numericvalue,
    dbo.qproject_get_misc_float_value( r.taqprojectkey, @v_miscitemkey3 ) miscItem3floatvalue,        
    dbo.qproject_get_misc_text_value( r.taqprojectkey, @v_miscitemkey3 ) miscItem3textvalue,        
    dbo.qproject_get_misc_checkbox_value( r.taqprojectkey, @v_miscitemkey3 ) miscItem3checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( r.taqprojectkey, @v_miscitemkey3 ) miscItem3datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( r.taqprojectkey, @v_miscitemkey3 ) miscItem3datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( r.taqprojectkey, @v_miscitemkey3 ) miscItem3calculatedvalue,    
    dbo.qproject_get_misc_updateind( r.taqprojectkey, @v_miscitemkey3 ) updateind3,
    dbo.qproject_exists_misc_entry( r.taqprojectkey, @v_miscitemkey3 ) existsmiscentry3,      
	dbo.qproject_exists_misc_default_entry( r.taqprojectkey, @v_miscitemkey3 ) existsmiscdefaultentry3,  
	dbo.qproject_exists_misc_section_entry( r.taqprojectkey, @v_miscitemkey3 ) existsmiscsectionentry3,	       
    
    @v_miscitemkey4 as miscitemkey4, 
    dbo.qproject_get_misc_value( r.taqprojectkey, @v_miscitemkey4 ) miscItem4value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey4 ) miscItem4sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey4) misctype4,    
    dbo.qutl_get_misc_label(@v_miscitemkey4) misclabel4,  
    dbo.qutl_get_miscname(@v_miscitemkey4) miscname4,       
    dbo.qproject_get_misc_numeric_value( r.taqprojectkey, @v_miscitemkey4 ) miscItem4numericvalue,
    dbo.qproject_get_misc_float_value( r.taqprojectkey, @v_miscitemkey4 ) miscItem4floatvalue,        
    dbo.qproject_get_misc_text_value( r.taqprojectkey, @v_miscitemkey4 ) miscItem4textvalue,        
    dbo.qproject_get_misc_checkbox_value( r.taqprojectkey, @v_miscitemkey4 ) miscItem4checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( r.taqprojectkey, @v_miscitemkey4 ) miscItem4datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( r.taqprojectkey, @v_miscitemkey4 ) miscItem4datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( r.taqprojectkey, @v_miscitemkey4 ) miscItem4calculatedvalue,
    dbo.qproject_get_misc_updateind( r.taqprojectkey, @v_miscitemkey4 ) updateind4,     
    dbo.qproject_exists_misc_entry( r.taqprojectkey, @v_miscitemkey4 ) existsmiscentry4,   
	dbo.qproject_exists_misc_default_entry( r.taqprojectkey, @v_miscitemkey4 ) existsmiscdefaultentry4,
	dbo.qproject_exists_misc_section_entry( r.taqprojectkey, @v_miscitemkey4 ) existsmiscsectionentry4,         
    
    @v_miscitemkey5 as miscitemkey5, 
    dbo.qproject_get_misc_value( r.taqprojectkey, @v_miscitemkey5 ) miscItem5value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey5 ) miscItem5sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey5) misctype5,  
    dbo.qutl_get_misc_label(@v_miscitemkey5) misclabel5,   
    dbo.qutl_get_miscname(@v_miscitemkey5) miscname5,         
    dbo.qproject_get_misc_numeric_value( r.taqprojectkey, @v_miscitemkey5 ) miscItem5numericvalue,
    dbo.qproject_get_misc_float_value( r.taqprojectkey, @v_miscitemkey5 ) miscItem5floatvalue,        
    dbo.qproject_get_misc_text_value( r.taqprojectkey, @v_miscitemkey5 ) miscItem5textvalue,        
    dbo.qproject_get_misc_checkbox_value( r.taqprojectkey, @v_miscitemkey5 ) miscItem5checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( r.taqprojectkey, @v_miscitemkey5 ) miscItem5datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( r.taqprojectkey, @v_miscitemkey5 ) miscItem5datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( r.taqprojectkey, @v_miscitemkey5 ) miscItem5calculatedvalue,  
    dbo.qproject_get_misc_updateind( r.taqprojectkey, @v_miscitemkey5 ) updateind5,   
    dbo.qproject_exists_misc_entry( r.taqprojectkey, @v_miscitemkey5 ) existsmiscentry5, 
	dbo.qproject_exists_misc_default_entry( r.taqprojectkey, @v_miscitemkey5 ) existsmiscdefaultentry5,
	dbo.qproject_exists_misc_section_entry( r.taqprojectkey, @v_miscitemkey5 ) existsmiscsectionentry5,	            
    
    @v_miscitemkey6 as miscitemkey6, 
    dbo.qproject_get_misc_value( r.taqprojectkey, @v_miscitemkey6 ) miscItem6value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey6 ) miscItem6sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey6) misctype6,  
    dbo.qutl_get_misc_label(@v_miscitemkey6) misclabel6,  
    dbo.qutl_get_miscname(@v_miscitemkey6) miscname6,          
    dbo.qproject_get_misc_numeric_value( r.taqprojectkey, @v_miscitemkey6 ) miscItem6numericvalue,
    dbo.qproject_get_misc_float_value( r.taqprojectkey, @v_miscitemkey5 ) miscItem6floatvalue,        
    dbo.qproject_get_misc_text_value( r.taqprojectkey, @v_miscitemkey6 ) miscItem6textvalue,        
    dbo.qproject_get_misc_checkbox_value( r.taqprojectkey, @v_miscitemkey6 ) miscItem6checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( r.taqprojectkey, @v_miscitemkey6 ) miscItem6datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( r.taqprojectkey, @v_miscitemkey6 ) miscItem6datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( r.taqprojectkey, @v_miscitemkey6 ) miscItem6calculatedvalue, 
    dbo.qproject_get_misc_updateind( r.taqprojectkey, @v_miscitemkey6 ) updateind6, 
    dbo.qproject_exists_misc_entry( r.taqprojectkey, @v_miscitemkey6 ) existsmiscentry6, 
	dbo.qproject_exists_misc_default_entry( r.taqprojectkey, @v_miscitemkey6 ) existsmiscdefaultentry6,
	dbo.qproject_exists_misc_section_entry( r.taqprojectkey, @v_miscitemkey6 ) existsmiscsectionentry6,	              
    
	dbo.qutl_get_misc_fieldformat(@v_miscitemkey1) fieldformat1, 
	dbo.qutl_get_misc_fieldformat(@v_miscitemkey2) fieldformat2, 
	dbo.qutl_get_misc_fieldformat(@v_miscitemkey3) fieldformat3, 
	dbo.qutl_get_misc_fieldformat(@v_miscitemkey4) fieldformat4, 
	dbo.qutl_get_misc_fieldformat(@v_miscitemkey5) fieldformat5, 
	dbo.qutl_get_misc_fieldformat(@v_miscitemkey6) fieldformat6,    
    @v_datetypecode1 as datetypecode1, dbo.qproject_get_last_taskdate2( r.taqprojectkey, @v_datetypecode1 ) as date1value, dbo.qproject_get_taskdate_access(@i_userkey, r.taqprojectkey, @v_datetypecode1) as date1access,
    @v_datetypecode2 as datetypecode2, dbo.qproject_get_last_taskdate2( r.taqprojectkey, @v_datetypecode2 ) as date2value, dbo.qproject_get_taskdate_access(@i_userkey, r.taqprojectkey, @v_datetypecode2) as date2access,
    @v_datetypecode3 as datetypecode3, dbo.qproject_get_last_taskdate2( r.taqprojectkey, @v_datetypecode3 ) as date3value, dbo.qproject_get_taskdate_access(@i_userkey, r.taqprojectkey, @v_datetypecode3) as date3access,
    @v_datetypecode4 as datetypecode4, dbo.qproject_get_last_taskdate2( r.taqprojectkey, @v_datetypecode4 ) as date4value, dbo.qproject_get_taskdate_access(@i_userkey, r.taqprojectkey, @v_datetypecode4) as date4access,
    @v_datetypecode5 as datetypecode5, dbo.qproject_get_last_taskdate2( r.taqprojectkey, @v_datetypecode5 ) as date5value, dbo.qproject_get_taskdate_access(@i_userkey, r.taqprojectkey, @v_datetypecode5) as date5access,
    @v_datetypecode6 as datetypecode6, dbo.qproject_get_last_taskdate2( r.taqprojectkey, @v_datetypecode6 ) as date6value, dbo.qproject_get_taskdate_access(@i_userkey, r.taqprojectkey, @v_datetypecode6) as date6access,
    @v_pricetypecode1 as pricetypecode1, dbo.qproject_get_price_by_pricetype( r.taqprojectkey, @v_pricetypecode1 ) as pricetypecode1Value,
    @v_pricetypecode2 as pricetypecode2, dbo.qproject_get_price_by_pricetype( r.taqprojectkey, @v_pricetypecode2 ) as pricetypecode2Value,
    @v_pricetypecode3 as pricetypecode3, dbo.qproject_get_price_by_pricetype( r.taqprojectkey, @v_pricetypecode3 ) as pricetypecode3Value,
    @v_pricetypecode4 as pricetypecode4, dbo.qproject_get_price_by_pricetype( r.taqprojectkey, @v_pricetypecode4 ) as pricetypecode4Value,
    @v_productidcode1 as productidcode1, 
    (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey AND productidcode = @v_productidcode1) as productIdCode1Value,
    @v_productidcode2 as productidcode2, 
    (SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = r.taqprojectkey AND productidcode = @v_productidcode2) as productIdCode2Value,
    @v_roletypecode1 as roletypecode1, dbo.qproject_get_participant_name_by_role( r.taqprojectkey, @v_roletypecode1) as roletypecode1Value,
    @v_roletypecode2 as roletypecode2, dbo.qproject_get_participant_name_by_role( r.taqprojectkey, @v_roletypecode2) as roletypecode2Value,
    @v_tableid1 as tableid1, r.datacode1, dbo.get_gentables_desc(@v_tableid1,r.datacode1,'long') as datacode1Value,
    @v_tableid2 as tableid2, r.datacode2, dbo.get_gentables_desc(@v_tableid2,r.datacode2,'long') as datacode2Value,
    @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid, @v_hidedeletebuttonind as hidedeletebuttonind   
  INTO #temp_relationships            
  FROM taqprojecttitle r LEFT OUTER JOIN coreprojectinfo c ON r.taqprojectkey = c.projectkey   
  WHERE r.bookkey = @i_bookkey  
    AND projectrolecode IN 
      (SELECT datacode FROM gentables
       WHERE tableid = 604
       AND ((datacode IN (SELECT DISTINCT code1 FROM gentablesrelationshipdetail
                          WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey
                          AND code2 = @v_relationshipTabCode)) OR
      -- Case #18293 - Only show project roles not configured for any tab if we are on the 
      -- generic projects tab on titles (qsicode = 14)
      (@v_qsicode = 14 
       AND datacode NOT IN (SELECT DISTINCT code1 FROM gentablesrelationshipdetail
                            WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey))))
  ORDER BY r.keyind DESC, r.sortorder ASC, projectroledesc ASC

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on taqprojecttitle (' + cast(@error_var AS VARCHAR) + '): bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 
  
   -- Loop through all relationships and execute the misc calc sql, if any of the misc items are calculated
  DECLARE cur_relationship CURSOR FOR
    SELECT bookkey, printingkey, taqprojectkey, titlerolecode, projectrolecode
    FROM #temp_relationships
    
  OPEN cur_relationship
  
  FETCH NEXT FROM cur_relationship 
  INTO @v_thisbookkey, @v_thisprintingkey, @v_othertaqprojectkey, @v_thistitlerolecode, @v_otherprojectrolecode

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN 
     
    IF @v_miscitemkey1 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey1
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_othertaqprojectkey, @v_miscitemkey1, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem1value = @v_calcvalue, miscItem1calculatedvalue = @v_calcvalue, updateind1 = 0, miscItem1sortvalue = @v_sortvalue
          WHERE bookkey = @v_thisbookkey
            AND printingkey = @v_thisprintingkey
            AND taqprojectkey = @v_othertaqprojectkey
            AND titlerolecode = @v_thistitlerolecode
            AND projectrolecode = @v_otherprojectrolecode
      END      
    END
    
    IF @v_miscitemkey2 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey2
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_othertaqprojectkey, @v_miscitemkey2, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem2value = @v_calcvalue, miscItem2calculatedvalue = @v_calcvalue, updateind2 = 0, miscItem2sortvalue = @v_sortvalue
          WHERE bookkey = @v_thisbookkey
            AND printingkey = @v_thisprintingkey
            AND taqprojectkey = @v_othertaqprojectkey
            AND titlerolecode = @v_thistitlerolecode
            AND projectrolecode = @v_otherprojectrolecode
      END      
    END
    
    IF @v_miscitemkey3 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey3
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_othertaqprojectkey, @v_miscitemkey3, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem3value = @v_calcvalue, miscItem3calculatedvalue = @v_calcvalue, updateind3 = 0, miscItem3sortvalue = @v_sortvalue
          WHERE bookkey = @v_thisbookkey
            AND printingkey = @v_thisprintingkey
            AND taqprojectkey = @v_othertaqprojectkey
            AND titlerolecode = @v_thistitlerolecode
            AND projectrolecode = @v_otherprojectrolecode
      END      
    END
    
    IF @v_miscitemkey4 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey4
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_othertaqprojectkey, @v_miscitemkey4, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem4value = @v_calcvalue, miscItem4calculatedvalue = @v_calcvalue, updateind4 = 0, miscItem4sortvalue = @v_sortvalue
          WHERE bookkey = @v_thisbookkey
            AND printingkey = @v_thisprintingkey
            AND taqprojectkey = @v_othertaqprojectkey
            AND titlerolecode = @v_thistitlerolecode
            AND projectrolecode = @v_otherprojectrolecode
      END      
    END
    
    IF @v_miscitemkey5 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey5
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_othertaqprojectkey, @v_miscitemkey5, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem5value = @v_calcvalue, miscItem5calculatedvalue = @v_calcvalue, updateind5 = 0, miscItem5sortvalue = @v_sortvalue
          WHERE bookkey = @v_thisbookkey
            AND printingkey = @v_thisprintingkey
            AND taqprojectkey = @v_othertaqprojectkey
            AND titlerolecode = @v_thistitlerolecode
            AND projectrolecode = @v_otherprojectrolecode
      END      
    END
    
    IF @v_miscitemkey6>0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey6
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_othertaqprojectkey, @v_miscitemkey6, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem6value = @v_calcvalue, miscItem6calculatedvalue = @v_calcvalue, updateind6 = 0, miscItem6sortvalue = @v_sortvalue
          WHERE bookkey = @v_thisbookkey
            AND printingkey = @v_thisprintingkey
            AND taqprojectkey = @v_othertaqprojectkey
            AND titlerolecode = @v_thistitlerolecode
            AND projectrolecode = @v_otherprojectrolecode
      END      
    END              
  
    FETCH NEXT FROM cur_relationship
    INTO @v_thisbookkey, @v_thisprintingkey, @v_othertaqprojectkey, @v_thistitlerolecode, @v_otherprojectrolecode
  END
  
  CLOSE cur_relationship
  DEALLOCATE cur_relationship

  -- *******************************************************************
  SELECT *
  FROM #temp_relationships
  ORDER BY keyind DESC, sortorder ASC, projectroledesc ASC  

END
GO

GRANT EXEC ON qtitle_get_relationships_project_title TO PUBLIC
GO




