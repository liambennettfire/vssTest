IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_relationships_project_grid') )
DROP PROCEDURE dbo.qproject_get_relationships_project_grid
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_get_relationships_project_grid]
 (@i_projectkey     integer,
  @i_datacode       integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_relationships_project_grid
**  Desc: This stored procedure returns data based on configured fields in the
**        taqprelationshiptabconfig table.
**
**  NOTE:   There are two types of controls that are added to the relationship
**          tab controls found on near the middle of the summary (journal/title/project/generic project)
**          pages.  One is a Form-type layout and the other is a Grid-type layout.
**          The Form-type layout is indicated in the table with multiple data rows in
**          taqrelationshiptabconfig with the same relationshiptabcode/itemtypecode/usageclass values.
**          In this case, the formTabUsageClass (subgen code from table 550) will make
**          each panel of the form unique and tell it which type of data to load.
**
**          THIS STORED PROCEDURE WILL NOT WORK FOR Form-Type CONTROLS
**
**          This procedure is written ONLY for Grid-type controls.  It assumes that there
**          will only be one entry in the table with a row uniqueness found in the 
**          relationshiptabcode/itemtypecode/usageclass columns.  The formTabUsageClass
**          column will be null and is not needed.
**
**          This allows the user to configure multiple rows in gentable 583 that will be
**          loaded via this procedure by passing the projectkey and datacode for the configured
**          row.
**
**    Orig.Auth: Alan Katzen
**    Date: 18 February 2008
**	  Revised: Lisa Cormier - 04/04/09 for case 10502 in netsuite.
**
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  03/16/2016   UK          Case 36739
**	05/11/2016   Colman      Added userkey input for taskdate accesscode output
**	06/06/2016   Colman      38278 - Return sortable string value for numeric misc columns
**  08/03/2016   Colman      39608 - Run misc calc on calculated dates
**  06/29/2017   Colman      45761 - Return statusrequiresvalidation flag
**  08/10/2017   Colman      46221 - New behavior for hideparticipantsind value = 2
**  09/22/2017   Colman      47364 - Protect against duplicate work product numbers
**  10/02/2017   Colman      47364 - Undo previous change. Don't protect against bad data. Let it crash.
**  06/21/2018   Colman      51661
*******************************************************************************/

DECLARE @error_var    INT,
  @rowcount_var INT,
  @v_calcvalue	VARCHAR(255),
  @v_sortvalue	VARCHAR(255),
  @v_configCount_1 INT,
  @v_configCount_2 INT,
  @v_configCount_3 INT,
  @v_datetypecode1 INT,
  @v_datetypecode2 INT,
  @v_datetypecode3 INT,
  @v_datetypecode4 INT,
  @v_datetypecode5 INT,
  @v_datetypecode6 INT,
  @v_gentablesrelationshipkey INT,
  @v_itemType INT,
  @v_lastmaintdate datetime,
  @v_lastuserid varchar(100),  
  @v_miscitemkey1 INT,
  @v_miscitemkey2 INT,
  @v_miscitemkey3 INT,
  @v_miscitemkey4 INT,
  @v_miscitemkey5 INT,
  @v_miscitemkey6 INT,
  @v_miscitemtype INT,
  @v_miscvalue1 VARCHAR(255),
  @v_miscvalue2 VARCHAR(255),
  @v_miscvalue3 VARCHAR(255),
  @v_miscvalue4 VARCHAR(255),
  @v_miscvalue5 VARCHAR(255),
  @v_miscvalue6 VARCHAR(255),
  @v_otherprojectkey  INT,
  @v_otherrelationshipcode  INT,
  @v_pricetypecode1 INT,
  @v_pricetypecode2 INT,
  @v_pricetypecode3 INT,
  @v_pricetypecode4 INT,
  @v_decimal1 INT,
  @v_decimal2 INT,
  @v_decimal1format VARCHAR(40),
  @v_decimal2format VARCHAR(40),   
  @v_productidcode1 INT,
  @v_productidcode2 INT,
  @v_qsicode INT,
  @v_relationshipTabCode INT,
  @v_roletypecode1 INT,
  @v_roletypecode2 INT,
  @v_tableid1 INT,
  @v_tableid2 INT,
  @v_tableid3 INT,
  @v_tableid4 INT,
  @v_thisprojectkey INT,
  @v_thisrelationshipcode INT,
  @v_usageClass INT,
  @v_hidedeletebuttonind TINYINT,
  @v_hideparticipantsind TINYINT,
  @v_sortdescendingind INT      

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_hidedeletebuttonind = NULL
  SET @v_hideparticipantsind = 0

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
  
  -- coreprojectinfo with project key and get itemtype/searchitem and usage class  
	SELECT @v_itemType = searchitemcode, @v_usageClass = usageclasscode
	FROM  coreprojectinfo
	WHERE projectkey = @i_projectkey
		
		
  --********************************************************************
  -- now make sure we have only one row for this project/configuration (see notes in procedure description)      
  select @rowcount_var = ( select count(*) from taqrelationshiptabconfig 
                           where ( relationshiptabcode = @i_datacode AND
                                   itemtypecode = @v_itemType AND
                                   usageclass = @v_usageClass ) )
                         
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var > 1 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Multiple rows found in taqrelationshiptabconfig for : taqrelationshiptabcode = ' + cast(@i_datacode AS VARCHAR)
      RETURN  
  END 

  SELECT @v_relationshipTabCode = @i_datacode    
    
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
    @v_tableid3 = tableid3, @v_tableid4 = tableid4,
    @v_lastmaintdate = lastmaintdate, @v_lastuserid = lastuserid,
    @v_hidedeletebuttonind = hidedeletebuttonind,
    @v_hideparticipantsind = hideparticipantsind,
    @v_sortdescendingind = COALESCE(sortdescendingind, 0)								
  FROM dbo.qproject_get_filtered_tabconfig_table(@v_relationshipTabCode, @v_itemType, @v_usageClass, NULL, NULL)
		
  -- *******************************************************************
  -- The retrieval needs to be broken down so that misc calc sql can be executed for the related projectkey

  -- retrieve relationships in both directions  
  SELECT 1 projectnumber,
    taqprojectkey1 thisprojectkey, 
    taqprojectkey2 otherprojectkey, 
    relationshipcode1 thisrelationshipcode, 
    dbo.get_gentables_desc(582, relationshipcode1, 'long') thisrelationshipdesc,
    relationshipcode2 otherrelationshipcode, 
    COALESCE(c.projecttitle, r.projectname2) otherprojectdisplayname,  
    COALESCE(c.projectstatusdesc, r.project2status) otherprojectstatus,  
    COALESCE(c.projectstatus, 0) otherprojectstatuscode,  
    CASE WHEN (SELECT TOP(1) 1 FROM gentablesitemtype gi WHERE gi.tableid=522 AND gi.itemtypecode = c.searchitemcode AND gi.itemtypesubcode = c.usageclasscode AND ISNULL(gi.relateddatacode,0) > 0) = 1
    THEN 1 ELSE 0
    END statusrequiresvalidation,
    COALESCE(
      CASE c.searchitemcode
        WHEN 9 THEN 
          (SELECT t.authorname FROM coretitleinfo t, taqproject p WHERE p.taqprojectkey = c.projectkey AND t.bookkey = p.workkey AND t.printingkey = 1)
        ELSE NULL 
        END,
      CASE @v_hideparticipantsind 
        WHEN 2 THEN 
          dbo.qproject_get_participant_names(c.projectkey, 2, 2)
        ELSE 
          ISNULL(c.projectparticipants, r.project2participants) 
        END
    ) otherprojectparticipants,
    r.taqprojectrelationshipkey, r.relationshipaddtldesc, r.keyind, r.sortorder,
    c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
    cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
    c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder, 
    r.quantity1, r.quantity2, r.quantity3, r.quantity4, r.decimal1, @v_decimal1format as decimal1format, r.decimal2, @v_decimal2format as decimal2format, r.indicator1, r.indicator2, 
    dbo.qpl_allow_remove_relationship(taqprojectkey1, taqprojectkey2) allowremoverelationship,
    dbo.qpl_is_master_pl_project(taqprojectkey1) isthisprojectmasterplproject,  
    dbo.qpl_is_master_pl_project(taqprojectkey2) isotherprojectmasterplproject,     
    @v_miscitemkey1 as miscitemkey1, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey1 ) miscItem1value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey1 ) miscItem1sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey1) misctype1,    
    dbo.qutl_get_misc_label(@v_miscitemkey1) misclabel1, 
    dbo.qutl_get_miscname(@v_miscitemkey1) miscname1,	      
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey1 ) miscItem1numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey1 ) miscItem1floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey1 ) miscItem1textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey1 ) miscItem1checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey1 ) miscItem1datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey1 ) miscItem1datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey1 ) miscItem1calculatedvalue,
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey1 ) updateind1,  
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey1 ) existsmiscentry1,        
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey1 ) existsmiscdefaultentry1,
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey1 ) existsmiscsectionentry1,      	    
    
    @v_miscitemkey2 as miscitemkey2, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey2 ) miscItem2value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey2 ) miscItem2sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey2) misctype2,    
    dbo.qutl_get_misc_label(@v_miscitemkey2) misclabel2,   
    dbo.qutl_get_miscname(@v_miscitemkey2) miscname2,	      
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey2 ) miscItem2numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey2 ) miscItem2floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey2 ) miscItem2textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey2 ) miscItem2checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey2 ) miscItem2datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey2 ) miscItem2datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey2 ) miscItem2calculatedvalue, 
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey2 ) updateind2,     
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey2 ) existsmiscentry2,      
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey2 ) existsmiscdefaultentry2,
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey2 ) existsmiscsectionentry2,          
    
    @v_miscitemkey3 as miscitemkey3, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey3 ) miscItem3value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey3 ) miscItem3sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey3) misctype3,
    dbo.qutl_get_misc_label(@v_miscitemkey3) misclabel3,  
    dbo.qutl_get_miscname(@v_miscitemkey3) miscname3,	       
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey3 ) miscItem3numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey3 ) miscItem3floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey3 ) miscItem3textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey3 ) miscItem3checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey3 ) miscItem3datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey3 ) miscItem3datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey3 ) miscItem3calculatedvalue,  
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey3 ) updateind3, 
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey3 ) existsmiscentry3,            
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey3 ) existsmiscdefaultentry3,
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey3 ) existsmiscsectionentry3,	         
    
    @v_miscitemkey4 as miscitemkey4, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey4 ) miscItem4value,
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey4 ) miscItem4sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey4) misctype4,    
    dbo.qutl_get_misc_label(@v_miscitemkey4) misclabel4, 
    dbo.qutl_get_miscname(@v_miscitemkey4) miscname4,	        
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey4 ) miscItem4numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey4 ) miscItem4floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey4 ) miscItem4textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey4 ) miscItem4checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey4 ) miscItem4datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey4 ) miscItem4datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey4 ) miscItem4calculatedvalue, 
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey4 ) updateind4, 
    dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey4 ) existsmiscentry4,     
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey4 ) existsmiscdefaultentry4,
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey4 ) existsmiscsectionentry4,           
     
    @v_miscitemkey5 as miscitemkey5, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey5 ) miscItem5value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey5 ) miscItem5sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey5) misctype5,  
    dbo.qutl_get_misc_label(@v_miscitemkey5) misclabel5,   
    dbo.qutl_get_miscname(@v_miscitemkey5) miscname5,	         
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey5 ) miscItem5numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey5 ) miscItem5floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey5 ) miscItem5textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey5 ) miscItem5checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey5 ) miscItem5datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey5 ) miscItem5datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey5 ) miscItem5calculatedvalue, 
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey5 ) updateind5, 
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey5 ) existsmiscentry5,                 
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey5 ) existsmiscdefaultentry5,
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey5 ) existsmiscsectionentry5,    
    
    @v_miscitemkey6 as miscitemkey6, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey6 ) miscItem6value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey6 ) miscItem6sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey6) misctype6, 
    dbo.qutl_get_misc_label(@v_miscitemkey6) misclabel6, 
    dbo.qutl_get_miscname(@v_miscitemkey6) miscname6,	            
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey6 ) miscItem6numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey6 ) miscItem6floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey6 ) miscItem6textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey6 ) miscItem6checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey6 ) miscItem6datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey6 ) miscItem6datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey6 ) miscItem6calculatedvalue,    
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey6 ) updateind6, 
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey6 ) existsmiscentry6,            
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey6 ) existsmiscdefaultentry6, 
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey6 ) existsmiscsectionentry6,   
    
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey1) fieldformat1, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey2) fieldformat2, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey3) fieldformat3, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey4) fieldformat4, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey5) fieldformat5, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey6) fieldformat6,   
          
    @v_datetypecode1 as datetypecode1, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode1 ) as date1value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode1) as date1access, 
    @v_datetypecode2 as datetypecode2, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode2 ) as date2value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode2) as date2access,
    @v_datetypecode3 as datetypecode3, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode3 ) as date3value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode3) as date3access,
    @v_datetypecode4 as datetypecode4, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode4 ) as date4value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode4) as date4access,
    @v_datetypecode5 as datetypecode5, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode5 ) as date5value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode5) as date5access,
    @v_datetypecode6 as datetypecode6, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode6 ) as date6value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode6) as date6access,
    @v_pricetypecode1 as pricetypecode1, dbo.qproject_get_price_by_pricetype( c.projectkey, @v_pricetypecode1 ) as pricetypecode1Value,
    @v_pricetypecode2 as pricetypecode2, dbo.qproject_get_price_by_pricetype( c.projectkey, @v_pricetypecode2 ) as pricetypecode2Value,
    @v_pricetypecode3 as pricetypecode3, dbo.qproject_get_price_by_pricetype( c.projectkey, @v_pricetypecode3 ) as pricetypecode3Value,
    @v_pricetypecode4 as pricetypecode4, dbo.qproject_get_price_by_pricetype( c.projectkey, @v_pricetypecode4 ) as pricetypecode4Value,
    @v_productidcode1 as productidcode1, 
    ISNULL((SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = c.projectkey AND productidcode = @v_productidcode1), '') as productIdCode1Value,
    @v_productidcode2 as productidcode2, 
    ISNULL((SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = c.projectkey AND productidcode = @v_productidcode2), '') as productIdCode2Value,
    @v_roletypecode1 as roletypecode1, dbo.qproject_get_participant_name_by_role( c.projectkey, @v_roletypecode1) as roletypecode1Value,
    @v_roletypecode2 as roletypecode2, dbo.qproject_get_participant_name_by_role( c.projectkey, @v_roletypecode2) as roletypecode2Value,
    @v_tableid1 as tableid1,
    dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid1, r.datacode1) as datacode1,
    dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid1, r.datacode1) as datacode1Value,
    @v_tableid2 as tableid2,
    dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid2, r.datacode2) as datacode2,
    dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid2, r.datacode2) as datacode2Value,
    @v_tableid3 as tableid3,
    dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid3, r.datacode3) as datacode3,
    dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid3, r.datacode3) as datacode3Value,
    @v_tableid4 as tableid4,
    dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid4, r.datacode4) as datacode4,
    dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid4, r.datacode4) as datacode4Value,
    @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid, @v_hidedeletebuttonind as hidedeletebuttonind,c.templateind,
    (SELECT p.worktemplateprojectkey FROM taqproject p WHERE p.taqprojectkey = c.projectkey) as worktemplateprojectkey
  INTO #temp_relationships
  FROM taqprojectrelationship r LEFT OUTER JOIN coreprojectinfo c ON r.taqprojectkey2 = c.projectkey   
  WHERE r.taqprojectkey1 = @i_projectkey AND
    relationshipcode1 IN (SELECT code1 FROM gentablesrelationshipdetail 
                          WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND code2 = @i_datacode)             

  INSERT INTO #temp_relationships
  SELECT 2 projectnumber, 
    taqprojectkey2 thisprojectkey, 
    taqprojectkey1 otherprojectkey, 
    relationshipcode2 thisrelationshipcode, 
    dbo.get_gentables_desc(582, relationshipcode2, 'long') thisrelationshipdesc,
    relationshipcode1 otherrelationshipcode, 
    c.projecttitle otherprojectdisplayname,
    c.projectstatusdesc otherprojectstatus,  
    COALESCE(c.projectstatus, 0) otherprojectstatuscode,  
    CASE WHEN (SELECT TOP(1) 1 FROM gentablesitemtype gi WHERE gi.tableid=522 AND gi.itemtypecode = c.searchitemcode AND gi.itemtypesubcode = c.usageclasscode AND ISNULL(gi.relateddatacode,0) > 0) = 1
    THEN 1 ELSE 0
    END statusrequiresvalidation,
    COALESCE(
      CASE c.searchitemcode
        WHEN 9 THEN 
          (SELECT t.authorname FROM coretitleinfo t, taqproject p WHERE p.taqprojectkey = c.projectkey AND t.bookkey = p.workkey AND t.printingkey = 1)
        ELSE NULL 
        END,
      CASE @v_hideparticipantsind 
        WHEN 2 THEN 
          dbo.qproject_get_participant_names(c.projectkey, 2, 2)
        ELSE 
          c.projectparticipants
        END
    ) otherprojectparticipants,
    r.taqprojectrelationshipkey, r.relationshipaddtldesc, r.keyind, r.sortorder,
    c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
    cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
    c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder, 	 
    r.quantity1, r.quantity2, r.quantity3, r.quantity4, r.decimal1, @v_decimal1format as decimal1format, r.decimal2, @v_decimal2format as decimal2format, r.indicator1, r.indicator2, 
    dbo.qpl_allow_remove_relationship(taqprojectkey2, taqprojectkey1) allowremoverelationship,
    dbo.qpl_is_master_pl_project(taqprojectkey2) isthisprojectmasterplproject,  
    dbo.qpl_is_master_pl_project(taqprojectkey1) isotherprojectmasterplproject,     
    @v_miscitemkey1 as miscitemkey1, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey1 ) miscItem1value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey1 ) miscItem1sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey1) misctype1,  
    dbo.qutl_get_misc_label(@v_miscitemkey1) misclabel1, 
    dbo.qutl_get_miscname(@v_miscitemkey1) miscname1,	            
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey1 ) miscItem1numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey1 ) miscItem1floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey1 ) miscItem1textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey1 ) miscItem1checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey1 ) miscItem1datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey1 ) miscItem1datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey1 ) miscItem1calculatedvalue, 
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey1 ) updateind1,
    dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey1 ) existsmiscentry1,  
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey1 ) existsmiscdefaultentry1, 
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey1 ) existsmiscsectionentry1,   
        
    @v_miscitemkey2 as miscitemkey2, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey2 ) miscItem2value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey2 ) miscItem2sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey2) misctype2,   
    dbo.qutl_get_misc_label(@v_miscitemkey2) misclabel2,     
    dbo.qutl_get_miscname(@v_miscitemkey2) miscname2,	     
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey2 ) miscItem2numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey2 ) miscItem2floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey2 ) miscItem2textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey2 ) miscItem2checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey2 ) miscItem2datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey2 ) miscItem2datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey2 ) miscItem2calculatedvalue, 
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey2 ) updateind2,  
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey2 ) existsmiscentry2,      
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey2 ) existsmiscdefaultentry2, 
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey2 ) existsmiscsectionentry2,    
        
    @v_miscitemkey3 as miscitemkey3, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey3 ) miscItem3value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey3 ) miscItem3sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey3) misctype3,
    dbo.qutl_get_misc_label(@v_miscitemkey3) misclabel3, 
    dbo.qutl_get_miscname(@v_miscitemkey3) miscname3,	        
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey3 ) miscItem3numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey3 ) miscItem3floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey3 ) miscItem3textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey3 ) miscItem3checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey3 ) miscItem3datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey3 ) miscItem3datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey3 ) miscItem3calculatedvalue, 
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey3 ) updateind3, 
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey3 ) existsmiscentry3,      
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey3 ) existsmiscdefaultentry3, 
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey3 ) existsmiscsectionentry3,      
    
    @v_miscitemkey4 as miscitemkey4, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey4 ) miscItem4value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey4 ) miscItem4sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey4) misctype4,   
    dbo.qutl_get_misc_label(@v_miscitemkey4) misclabel4, 
    dbo.qutl_get_miscname(@v_miscitemkey4) miscname4,	         
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey4 ) miscItem4numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey4 ) miscItem4floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey4 ) miscItem4textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey4 ) miscItem4checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey4 ) miscItem4datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey4 ) miscItem4datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey4 ) miscItem4calculatedvalue,
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey4 ) updateind4, 
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey4 ) existsmiscentry4,        
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey4 ) existsmiscdefaultentry4, 
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey4 ) existsmiscsectionentry4,          
    
    @v_miscitemkey5 as miscitemkey5, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey5 ) miscItem5value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey5 ) miscItem5sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey5) misctype5,    
    dbo.qutl_get_misc_label(@v_miscitemkey5) misclabel5,   
    dbo.qutl_get_miscname(@v_miscitemkey5) miscname5,	       
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey5 ) miscItem5numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey5 ) miscItem5floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey5 ) miscItem5textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey5 ) miscItem5checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey5 ) miscItem5datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey5 ) miscItem5datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey5 ) miscItem5calculatedvalue,  
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey5 ) updateind5, 
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey5 ) existsmiscentry5,      
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey5 ) existsmiscdefaultentry5,  
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey5 ) existsmiscsectionentry5,            
    
    @v_miscitemkey6 as miscitemkey6, 
    dbo.qproject_get_misc_value( c.projectkey, @v_miscitemkey6 ) miscItem6value, 
    dbo.qproject_get_misc_sortvalue( c.projectkey, @v_miscitemkey6 ) miscItem6sortvalue, 
    dbo.qutl_get_misctype(@v_miscitemkey6) misctype6,    
    dbo.qutl_get_misc_label(@v_miscitemkey6) misclabel6,   
    dbo.qutl_get_miscname(@v_miscitemkey6) miscname6,	       
    dbo.qproject_get_misc_numeric_value( c.projectkey, @v_miscitemkey6 ) miscItem6numericvalue,
    dbo.qproject_get_misc_float_value( c.projectkey, @v_miscitemkey6 ) miscItem6floatvalue,        
    dbo.qproject_get_misc_text_value( c.projectkey, @v_miscitemkey6 ) miscItem6textvalue,        
    dbo.qproject_get_misc_checkbox_value( c.projectkey, @v_miscitemkey6 ) miscItem6checkboxvalue,     
	dbo.qproject_get_misc_datacode_value( c.projectkey, @v_miscitemkey6 ) miscItem6datacodevalue,      
	dbo.qproject_get_misc_datasubcode_value( c.projectkey, @v_miscitemkey6 ) miscItem6datasubcodevalue,  
    dbo.qproject_get_misc_calculated_value( c.projectkey, @v_miscitemkey6 ) miscItem6calculatedvalue,   
    dbo.qproject_get_misc_updateind( c.projectkey, @v_miscitemkey6 ) updateind6, 
	dbo.qproject_exists_misc_entry( c.projectkey, @v_miscitemkey6 ) existsmiscentry6,      
	dbo.qproject_exists_misc_default_entry( c.projectkey, @v_miscitemkey6 ) existsmiscdefaultentry6, 
	dbo.qproject_exists_misc_section_entry( c.projectkey, @v_miscitemkey6 ) existsmiscsectionentry6,          
    
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey1) fieldformat1, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey2) fieldformat2, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey3) fieldformat3, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey4) fieldformat4, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey5) fieldformat5, 
    dbo.qutl_get_misc_fieldformat(@v_miscitemkey6) fieldformat6,          
    @v_datetypecode1 as datetypecode1, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode1 ) as date1value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode1) as date1access,
    @v_datetypecode2 as datetypecode2, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode2 ) as date2value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode2) as date2access,
    @v_datetypecode3 as datetypecode3, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode3 ) as date3value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode3) as date3access,
    @v_datetypecode4 as datetypecode4, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode4 ) as date4value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode4) as date4access,
    @v_datetypecode5 as datetypecode5, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode5 ) as date5value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode5) as date5access,
    @v_datetypecode6 as datetypecode6, dbo.qproject_get_last_taskdate2( c.projectkey, @v_datetypecode6 ) as date6value, dbo.qproject_get_taskdate_access(@i_userkey, c.projectkey, @v_datetypecode6) as date6access,
    @v_pricetypecode1 as pricetypecode1, dbo.qproject_get_price_by_pricetype( c.projectkey, @v_pricetypecode1 ) as pricetypecode1Value,
    @v_pricetypecode2 as pricetypecode2, dbo.qproject_get_price_by_pricetype( c.projectkey, @v_pricetypecode2 ) as pricetypecode2Value,
    @v_pricetypecode3 as pricetypecode3, dbo.qproject_get_price_by_pricetype( c.projectkey, @v_pricetypecode3 ) as pricetypecode3Value,
    @v_pricetypecode4 as pricetypecode4, dbo.qproject_get_price_by_pricetype( c.projectkey, @v_pricetypecode4 ) as pricetypecode4Value,
    @v_productidcode1 as productidcode1, 
    ISNULL((SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = c.projectkey AND productidcode = @v_productidcode1), '') as productIdCode1Value,
    @v_productidcode2 as productidcode2, 
    ISNULL((SELECT productnumber FROM taqproductnumbers WHERE taqprojectkey = c.projectkey AND productidcode = @v_productidcode2), '') as productIdCode2Value,
    @v_roletypecode1 as roletypecode1, dbo.qproject_get_participant_name_by_role( c.projectkey, @v_roletypecode1) as roletypecode1Value,
    @v_roletypecode2 as roletypecode2, dbo.qproject_get_participant_name_by_role( c.projectkey, @v_roletypecode2) as roletypecode2Value,
    @v_tableid1 as tableid1,
    dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid1, r.datacode1) as datacode1,
    dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid1, r.datacode1) as datacode1Value,
    @v_tableid2 as tableid2,
    dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid2, r.datacode2) as datacode2,
    dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid2, r.datacode2) as datacode2Value,
    @v_tableid3 as tableid3,
    dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid3, r.datacode3) as datacode3,
    dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid3, r.datacode3) as datacode3Value,
    @v_tableid4 as tableid4,
    dbo.qproject_rel_gentable_datacode(c.projectkey, @v_tableid4, r.datacode4) as datacode4,
    dbo.qproject_rel_gentable_datadesc(c.projectkey, @v_tableid4, r.datacode4) as datacode4Value,
    @v_lastmaintdate as lastMaintDate, @v_lastuserid as lastuserid, @v_hidedeletebuttonind as hidedeletebuttonind,c.templateind,
    (SELECT p.worktemplateprojectkey FROM taqproject p WHERE p.taqprojectkey = c.projectkey) as worktemplateprojectkey
  FROM taqprojectrelationship r LEFT OUTER JOIN coreprojectinfo c ON r.taqprojectkey1 = c.projectkey   
  WHERE r.taqprojectkey2 = @i_projectkey AND
    relationshipcode2 IN (SELECT code1 FROM gentablesrelationshipdetail 
                          WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey AND code2 = @i_datacode)
  
  -- Loop through all relationships and execute the misc calc sql, if any of the misc items are calculated
  DECLARE cur_relationship CURSOR FOR
    SELECT thisprojectkey, otherprojectkey, thisrelationshipcode, otherrelationshipcode
    FROM #temp_relationships
    
  OPEN cur_relationship
  
  FETCH NEXT FROM cur_relationship 
  INTO @v_thisprojectkey, @v_otherprojectkey, @v_thisrelationshipcode, @v_otherrelationshipcode

  WHILE (@@FETCH_STATUS <> -1)
  BEGIN 
     
    IF @v_miscitemkey1 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey1
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_otherprojectkey, @v_miscitemkey1, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem1value = @v_calcvalue, miscItem1calculatedvalue = @v_calcvalue, miscItem1sortvalue = @v_sortvalue
          WHERE thisprojectkey = @v_thisprojectkey
            AND otherprojectkey = @v_otherprojectkey
            AND thisrelationshipcode = @v_thisrelationshipcode
            AND otherrelationshipcode = @v_otherrelationshipcode
      END      
    END
    
    IF @v_miscitemkey2 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey2
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_otherprojectkey, @v_miscitemkey2, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem2value = @v_calcvalue, miscItem2calculatedvalue = @v_calcvalue, miscItem2sortvalue = @v_sortvalue
          WHERE thisprojectkey = @v_thisprojectkey
            AND otherprojectkey = @v_otherprojectkey
            AND thisrelationshipcode = @v_thisrelationshipcode
            AND otherrelationshipcode = @v_otherrelationshipcode
      END      
    END
    
    IF @v_miscitemkey3 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey3
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_otherprojectkey, @v_miscitemkey3, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem3value = @v_calcvalue, miscItem3calculatedvalue = @v_calcvalue, miscItem3sortvalue = @v_sortvalue
          WHERE thisprojectkey = @v_thisprojectkey
            AND otherprojectkey = @v_otherprojectkey
            AND thisrelationshipcode = @v_thisrelationshipcode
            AND otherrelationshipcode = @v_otherrelationshipcode
      END      
    END
    
    IF @v_miscitemkey4 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey4
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_otherprojectkey, @v_miscitemkey4, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem4value = @v_calcvalue, miscItem4calculatedvalue = @v_calcvalue, miscItem4sortvalue = @v_sortvalue
          WHERE thisprojectkey = @v_thisprojectkey
            AND otherprojectkey = @v_otherprojectkey
            AND thisrelationshipcode = @v_thisrelationshipcode
            AND otherrelationshipcode = @v_otherrelationshipcode
      END      
    END
    
    IF @v_miscitemkey5 >0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey5
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_otherprojectkey, @v_miscitemkey5, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem5value = @v_calcvalue, miscItem5calculatedvalue = @v_calcvalue, miscItem5sortvalue = @v_sortvalue
          WHERE thisprojectkey = @v_thisprojectkey
            AND otherprojectkey = @v_otherprojectkey
            AND thisrelationshipcode = @v_thisrelationshipcode
            AND otherrelationshipcode = @v_otherrelationshipcode
      END      
    END
    
    IF @v_miscitemkey6>0
    BEGIN
      SELECT @v_miscitemtype = misctype
      FROM bookmiscitems
      WHERE misckey = @v_miscitemkey6
            
      IF @v_miscitemtype = 6 OR @v_miscitemtype = 8 OR @v_miscitemtype = 9 OR @v_miscitemtype = 10  --calculated decimal, integer, string or date
      BEGIN
        EXEC qproject_run_misc_calc @v_otherprojectkey, @v_miscitemkey6, 0, 'QSI', 
          @v_calcvalue OUTPUT, @v_sortvalue OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
                
        IF @v_calcvalue IS NOT NULL
          UPDATE #temp_relationships
          SET miscItem6value = @v_calcvalue, miscItem6calculatedvalue = @v_calcvalue, miscItem6sortvalue = @v_sortvalue
          WHERE thisprojectkey = @v_thisprojectkey
            AND otherprojectkey = @v_otherprojectkey
            AND thisrelationshipcode = @v_thisrelationshipcode
            AND otherrelationshipcode = @v_otherrelationshipcode
      END      
    END              
  
    FETCH NEXT FROM cur_relationship
    INTO @v_thisprojectkey, @v_otherprojectkey, @v_thisrelationshipcode, @v_otherrelationshipcode
  END
  
  CLOSE cur_relationship
  DEALLOCATE cur_relationship

  -- *******************************************************************  
  IF @v_sortdescendingind = 1 BEGIN
	  SELECT *
	  FROM #temp_relationships
	  ORDER BY keyind DESC, sortorder ASC, thisrelationshipcode ASC, otherrelationshipcode ASC, otherprojectkey DESC	
  END
  ELSE BEGIN
	  SELECT *
	  FROM #temp_relationships
	  ORDER BY keyind DESC, sortorder ASC, thisrelationshipcode ASC, otherrelationshipcode ASC, otherprojectkey ASC	  
  END  

END
go

GRANT EXEC ON dbo.qproject_get_relationships_project_grid TO PUBLIC
GO

