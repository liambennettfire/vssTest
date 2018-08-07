IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taqrelationshiptabconfig') )
DROP PROCEDURE dbo.qproject_get_taqrelationshiptabconfig
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_get_taqrelationshiptabconfig]
 (@i_projectkey     integer,
  @i_datacode       integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************************
**  Name: qproject_get_taqrelationshiptabconfig
**  Desc: This stored procedure returns data based on configured fields in the
**        taqrelationshiptabconfig table.
**
**  Auth: Kate W.
**  Date: 17 June 2011
**
** NOTE: (copied from qproject_get_relationships_project_grid)
**      There are two types of controls that are added to the relationship
**      tab controls found on near the middle of the summary (journal/title/project/generic project)
**      pages.  One is a Form-type layout and the other is a Grid-type layout.
**      The Form-type layout is indicated in the table with multiple data rows in
**      taqrelationshiptabconfig with the same relationshiptabcode/itemtypecode/usageclass values.
**      In this case, the formTabUsageClass (subgen code from table 550) will make
**      each panel of the form unique and tell it which type of data to load.
**
**      THIS STORED PROCEDURE WILL NOT WORK FOR Form-Type CONTROLS
**
**      This procedure is written ONLY for Grid-type controls.  It assumes that there
**      will only be one entry in the table with a row uniqueness found in the 
**      relationshiptabcode/itemtypecode/usageclass columns.  The formTabUsageClass
**      column will be null and is not needed.
**
**      This allows the user to configure multiple rows in gentable 583 that will be
**      loaded via this procedure by passing the projectkey and datacode for the configured row.
*****************************************************************************************************/

DECLARE
  @v_configCount_1 INT,
  @v_configCount_2 INT,
  @v_configCount_3 INT,
  @v_error  INT,
  @v_itemtype INT,
  @v_rowcount INT,
  @v_usageclass INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Get itemtype and usage class for this project 
  SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode
  FROM  coreprojectinfo
  WHERE projectkey = @i_projectkey
		
  -- Make sure we have only one config row for this project/configuration
  SELECT @v_rowcount = COUNT(*) 
  FROM taqrelationshiptabconfig 
  WHERE relationshiptabcode = @i_datacode AND itemtypecode = @v_itemtype AND usageclass = @v_usageclass

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqrelationshiptabconfig table.'
    RETURN  
  END
  
  IF @v_rowcount > 1 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Multiple rows found in taqrelationshiptabconfig for : taqrelationshiptabcode = ' + cast(@i_datacode AS VARCHAR)
    RETURN  
  END    
  
	-- Run three counts against tabrelationshiptabconfig, 
	-- 1. Matching relationshiptabcode, itemtypecode and usageclass
	-- 2. Matching relationshiptabcode and itemtype with NULL usageclass
	-- 3. Matching relationshiptabcode and NULL itemtype and usageclass
	-- This will satisfy the spec requirements as written: 
		/** "It will first check for the tab name using the item type/usage class of the current item 
		(for example, the Project Key of the Project you are on in Project Summary) on taqrelationshiptabconfig.  
		If nothing is found for the item type/usage class, check again using the item type with a null usage class; 
		this will find a default for the item type if there is any.  If nothing is selected still, check again with 
		both the item type and usage class set to null; this will find a default for the tab if there is any.
		If nothing is found at all, set all of the configurable columns to invisible. " **/
		
  -- Run through the main logic of determining visibility status as follows per the specs as written below:
  -- If the datetypecode1 is not null, make this column visible. For the label, use date1label if this is not null; 
  -- if it is null, use datelabel from the datetype table .
  -- For the datetypecode stored in datetypecode1, fill the column with the value from taqprojecttasks for the related projectkey and datekey. 
  -- If there is more than one, select the one with the most recent lastmaintdate. If it is null, set this column to invisible.		

  SELECT @v_configCount_1 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE	relationshiptabcode = @i_datacode AND itemtypecode = @v_itemType AND usageclass = @v_usageClass

  SELECT @v_configCount_2 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE relationshiptabcode = @i_datacode AND itemtypecode = @v_itemType AND usageclass IS NULL

  SELECT @v_configCount_3 = COUNT(*)
  FROM taqrelationshiptabconfig
  WHERE	relationshiptabcode = @i_datacode AND itemtypecode IS NULL AND usageclass IS NULL
     
  IF @v_configCount_1 > 0
    SELECT quantity1label, quantity2label, decimal1label, decimal2label, decimal1format, decimal2format, indicator1label, indicator2label, 
      miscitemkey1,
      CASE
        WHEN miscitemkey1 > 0 AND miscitem1label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey1)
        WHEN miscitemkey1 > 0 AND miscitem1label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey1) IS NULL THEN NULL     
        ELSE miscitem1label
      END miscitem1label, 
      miscitemkey2, 
      CASE
        WHEN miscitemkey2 > 0 AND miscitem2label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey2)
        WHEN miscitemkey2 > 0 AND miscitem2label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey2) IS NULL THEN NULL           
        ELSE miscitem2label
      END miscitem2label,
      miscitemkey3, 
      CASE
        WHEN miscitemkey3 > 0 AND miscitem3label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey3)
        WHEN miscitemkey3 > 0 AND miscitem3label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey3) IS NULL THEN NULL         
        ELSE miscitem3label
      END miscitem3label,
      miscitemkey4, 
      CASE
        WHEN miscitemkey4 > 0 AND miscitem4label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey4)
        WHEN miscitemkey4 > 0 AND miscitem4label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey4) IS NULL THEN NULL            
        ELSE miscitem4label
      END miscitem4label,
      miscitemkey5, 
      CASE
        WHEN miscitemkey5 > 0 AND miscitem5label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey5)
        WHEN miscitemkey5 > 0 AND miscitem5label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey5) IS NULL THEN NULL          
        ELSE miscitem5label
      END miscitem5label,
      miscitemkey6, 
      CASE
        WHEN miscitemkey6 > 0 AND miscitem6label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey6)
        WHEN miscitemkey6 > 0 AND miscitem6label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey6) IS NULL THEN NULL           
        ELSE miscitem6label
      END miscitem6label,
      datetypecode1, 
      CASE
        WHEN datetypecode1 > 0 AND date1label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode1)
        ELSE date1label
      END date1label, 
      datetypecode2, 
      CASE
        WHEN datetypecode2 > 0 AND date2label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode2)
        ELSE date2label
      END date2label, 
      datetypecode3, 
      CASE
        WHEN datetypecode3 > 0 AND date3label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode3)
        ELSE date3label
      END date3label,
      datetypecode4, 
      CASE
        WHEN datetypecode4 > 0 AND date4label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode4)
        ELSE date4label
      END date4label,     
      datetypecode5, 
      CASE
        WHEN datetypecode5 > 0 AND date5label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode5)
        ELSE date5label
      END date5label,     
      datetypecode6, 
      CASE
        WHEN datetypecode6 > 0 AND date6label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode6)
        ELSE date6label
      END date6label,     
      productidcode1, 
      CASE
        WHEN productidcode1 > 0 AND productid1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 594 AND datacode = productidcode1)
        ELSE productid1label
      END productid1label,
      productidcode2,
      CASE
        WHEN productidcode2 > 0 AND productid2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 594 AND datacode = productidcode2)
        ELSE productid2label
      END productid2label,
      roletypecode1, 
      CASE
        WHEN roletypecode1 > 0 AND roletype1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 285 AND datacode = roletypecode1)
        ELSE roletype1label
      END roletype1label,
      roletypecode2, 
      CASE
        WHEN roletypecode2 > 0 AND roletype2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 285 AND datacode = roletypecode2)
        ELSE roletype2label
      END roletype2label,
      pricetypecode1, 
      CASE
        WHEN pricetypecode1 > 0 AND price1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode1)
        ELSE price1label
      END price1label,
      pricetypecode2, 
      CASE
        WHEN pricetypecode2 > 0 AND price2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode2)
        ELSE price2label
      END price2label,
      pricetypecode3, 
      CASE
        WHEN pricetypecode3 > 0 AND price3label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode3)
        ELSE price3label
      END price3label,    
      pricetypecode4,
      CASE
        WHEN pricetypecode4 > 0 AND price4label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode4)
        ELSE price4label
      END price4label,
      tableid1, 
      CASE
        WHEN tableid1 > 0 AND tableidlabel1 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid1)
        ELSE tableidlabel1
      END tableidlabel1,
      tableid2, 
      CASE
        WHEN tableid2 > 0 AND tableidlabel2 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid2)
        ELSE tableidlabel2
      END tableidlabel2,
      contactrelationship1, 
      CASE
        WHEN contactrelationship1 > 0 AND contactrelationship1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 519 AND datacode = contactrelationship1)
        ELSE contactrelationship1label
      END contactrelationship1label,
      contactrelationship2, 
      CASE
        WHEN contactrelationship2 > 0 AND contactrelationship2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 519 AND datacode = contactrelationship2)
        ELSE contactrelationship2label
      END contactrelationship2label,
      createitemtypecode, createclasscode, createnewrelatecode, createexistrelatecode, createprojrolecode, createtitlerolecode,
      create2itemtypecode, create2classcode, create2newrelatecode, create2existrelatecode, create2projrolecode, create2titlerolecode,
      create3itemtypecode, create3classcode, create3newrelatecode, create3existrelatecode, create3projrolecode, create3titlerolecode, 
      relateitemtypecode, relateclasscode, relate2itemtypecode, relate2classcode, relate3itemtypecode, relate3classcode, 
      relatecurrentprojrelcode, relaterelatedprojrelcode, relateprojrolecode, relatetitlerolecode,
      relate2currentprojrelcode, relate2relatedprojrelcode, relate2projrolecode, relate2titlerolecode,
      relate3currentprojrelcode, relate3relatedprojrelcode, relate3projrolecode, relate3titlerolecode,
      hidefiltersind, hideclassind, hidetypeind, hidethisrelind, hideotherrelind, hidenotesind, hideownerind, hideparticipantsind,
      addrelateditemind, lastmaintdate, lastuserid, hidedeletebuttonind, hidestatusind, hidekeyind,
      defaultfilteritemtype,defaultfilterusageclass,defaultsortorder,createastemplateind,create2astemplateind,create3astemplateind,
      scrollbarheight,displaytemplatesonlyind,COALESCE(alloweditablefieldsind,0) alloweditablefieldsind
    FROM taqrelationshiptabconfig
    WHERE relationshiptabcode = @i_datacode AND itemtypecode = @v_itemType AND usageclass = @v_usageClass
    
  ELSE IF @v_configCount_2 > 0
    SELECT quantity1label, quantity2label, decimal1label, decimal2label, decimal1format, decimal2format, indicator1label, indicator2label, 
      miscitemkey1,
      CASE
        WHEN miscitemkey1 > 0 AND miscitem1label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey1)
        WHEN miscitemkey1 > 0 AND miscitem1label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey1) IS NULL THEN NULL         
        ELSE miscitem1label
      END miscitem1label, 
      miscitemkey2, 
      CASE
        WHEN miscitemkey2 > 0 AND miscitem2label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey2)
        WHEN miscitemkey2 > 0 AND miscitem2label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey2) IS NULL THEN NULL         
        ELSE miscitem2label
      END miscitem2label,
      miscitemkey3, 
      CASE
        WHEN miscitemkey3 > 0 AND miscitem3label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey3)
        WHEN miscitemkey3 > 0 AND miscitem3label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey3) IS NULL THEN NULL         
        ELSE miscitem3label
      END miscitem3label,
      miscitemkey4, 
      CASE
        WHEN miscitemkey4 > 0 AND miscitem4label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey4)
        WHEN miscitemkey4 > 0 AND miscitem4label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey4) IS NULL THEN NULL         
        ELSE miscitem4label
      END miscitem4label,
      miscitemkey5, 
      CASE
        WHEN miscitemkey5 > 0 AND miscitem5label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey5)
        WHEN miscitemkey5 > 0 AND miscitem5label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey5) IS NULL THEN NULL         
        ELSE miscitem5label
      END miscitem5label,
      miscitemkey6, 
      CASE
        WHEN miscitemkey6 > 0 AND miscitem6label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey6)
        WHEN miscitemkey6 > 0 AND miscitem6label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey6) IS NULL THEN NULL         
        ELSE miscitem6label
      END miscitem6label,
      datetypecode1, 
      CASE
        WHEN datetypecode1 > 0 AND date1label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode1)
        ELSE date1label
      END date1label, 
      datetypecode2, 
      CASE
        WHEN datetypecode2 > 0 AND date2label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode2)
        ELSE date2label
      END date2label, 
      datetypecode3, 
      CASE
        WHEN datetypecode3 > 0 AND date3label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode3)
        ELSE date3label
      END date3label,
      datetypecode4, 
      CASE
        WHEN datetypecode4 > 0 AND date4label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode4)
        ELSE date4label
      END date4label,     
      datetypecode5, 
      CASE
        WHEN datetypecode5 > 0 AND date5label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode5)
        ELSE date5label
      END date5label,     
      datetypecode6, 
      CASE
        WHEN datetypecode6 > 0 AND date6label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode6)
        ELSE date6label
      END date6label,     
      productidcode1, 
      CASE
        WHEN productidcode1 > 0 AND productid1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 594 AND datacode = productidcode1)
        ELSE productid1label
      END productid1label,
      productidcode2,
      CASE
        WHEN productidcode2 > 0 AND productid2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 594 AND datacode = productidcode2)
        ELSE productid2label
      END productid2label,
      roletypecode1, 
      CASE
        WHEN roletypecode1 > 0 AND roletype1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 285 AND datacode = roletypecode1)
        ELSE roletype1label
      END roletype1label,
      roletypecode2, 
      CASE
        WHEN roletypecode2 > 0 AND roletype2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 285 AND datacode = roletypecode2)
        ELSE roletype2label
      END roletype2label,
      pricetypecode1, 
      CASE
        WHEN pricetypecode1 > 0 AND price1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode1)
        ELSE price1label
      END price1label,
      pricetypecode2, 
      CASE
        WHEN pricetypecode2 > 0 AND price2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode2)
        ELSE price2label
      END price2label,
      pricetypecode3, 
      CASE
        WHEN pricetypecode3 > 0 AND price3label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode3)
        ELSE price3label
      END price3label,    
      pricetypecode4,
      CASE
        WHEN pricetypecode4 > 0 AND price4label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode4)
        ELSE price4label
      END price4label,
      tableid1, 
      CASE
        WHEN tableid1 > 0 AND tableidlabel1 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid1)
        ELSE tableidlabel1
      END tableidlabel1,
      tableid2, 
      CASE
        WHEN tableid2 > 0 AND tableidlabel2 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid2)
        ELSE tableidlabel2
      END tableidlabel2,
      contactrelationship1, 
      CASE
        WHEN contactrelationship1 > 0 AND contactrelationship1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 519 AND datacode = contactrelationship1)
        ELSE contactrelationship1label
      END contactrelationship1label,
      contactrelationship2, 
      CASE
        WHEN contactrelationship2 > 0 AND contactrelationship2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 519 AND datacode = contactrelationship2)
        ELSE contactrelationship2label
      END contactrelationship2label,
      createitemtypecode, createclasscode, createnewrelatecode, createexistrelatecode, createprojrolecode, createtitlerolecode,
      create2itemtypecode, create2classcode, create2newrelatecode, create2existrelatecode, create2projrolecode, create2titlerolecode,
      create3itemtypecode, create3classcode, create3newrelatecode, create3existrelatecode, create3projrolecode, create3titlerolecode,      
      relateitemtypecode, relateclasscode, relate2itemtypecode, relate2classcode, relate3itemtypecode, relate3classcode, 
      relatecurrentprojrelcode, relaterelatedprojrelcode, relateprojrolecode, relatetitlerolecode,
      relate2currentprojrelcode, relate2relatedprojrelcode, relate2projrolecode, relate2titlerolecode,
      relate3currentprojrelcode, relate3relatedprojrelcode, relate3projrolecode, relate3titlerolecode,      
      hidefiltersind, hideclassind, hidetypeind, hidethisrelind, hideotherrelind, hidenotesind, hideownerind, hideparticipantsind,
      addrelateditemind, lastmaintdate, lastuserid, hidedeletebuttonind, hidestatusind, hidekeyind,
      defaultfilteritemtype,defaultfilterusageclass,defaultsortorder,createastemplateind,create2astemplateind,create3astemplateind,
      scrollbarheight,displaytemplatesonlyind,COALESCE(alloweditablefieldsind,0) alloweditablefieldsind
    FROM taqrelationshiptabconfig
    WHERE relationshiptabcode = @i_datacode AND itemtypecode = @v_itemType AND usageclass IS NULL
    
  ELSE
    SELECT quantity1label, quantity2label, decimal1label, decimal2label, decimal1format, decimal2format, indicator1label, indicator2label, 
      miscitemkey1,
      CASE
        WHEN miscitemkey1 > 0 AND miscitem1label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey1)
        WHEN miscitemkey1 > 0 AND miscitem1label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey1) IS NULL THEN NULL         
        ELSE miscitem1label
      END miscitem1label, 
      miscitemkey2, 
      CASE
        WHEN miscitemkey2 > 0 AND miscitem2label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey2)
        WHEN miscitemkey2 > 0 AND miscitem2label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey2) IS NULL THEN NULL         
        ELSE miscitem2label
      END miscitem2label,
      miscitemkey3, 
      CASE
        WHEN miscitemkey3 > 0 AND miscitem3label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey3)
        WHEN miscitemkey3 > 0 AND miscitem3label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey3) IS NULL THEN NULL         
        ELSE miscitem3label
      END miscitem3label,
      miscitemkey4, 
      CASE
        WHEN miscitemkey4 > 0 AND miscitem4label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey4)
        WHEN miscitemkey4 > 0 AND miscitem4label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey4) IS NULL THEN NULL         
        ELSE miscitem4label
      END miscitem4label,
      miscitemkey5, 
      CASE
        WHEN miscitemkey5 > 0 AND miscitem5label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey5)
        WHEN miscitemkey5 > 0 AND miscitem5label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey5) IS NULL THEN NULL         
        ELSE miscitem5label
      END miscitem5label,
      miscitemkey6, 
      CASE
        WHEN miscitemkey6 > 0 AND miscitem6label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey6)
        WHEN miscitemkey6 > 0 AND miscitem6label IS NOT NULL AND dbo.qutl_get_misc_label(miscitemkey6) IS NULL THEN NULL         
        ELSE miscitem6label
      END miscitem6label,
      datetypecode1, 
      CASE
        WHEN datetypecode1 > 0 AND date1label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode1)
        ELSE date1label
      END date1label, 
      datetypecode2, 
      CASE
        WHEN datetypecode2 > 0 AND date2label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode2)
        ELSE date2label
      END date2label, 
      datetypecode3, 
      CASE
        WHEN datetypecode3 > 0 AND date3label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode3)
        ELSE date3label
      END date3label,
      datetypecode4, 
      CASE
        WHEN datetypecode4 > 0 AND date4label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode4)
        ELSE date4label
      END date4label,     
      datetypecode5, 
      CASE
        WHEN datetypecode5 > 0 AND date5label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode5)
        ELSE date5label
      END date5label,     
      datetypecode6, 
      CASE
        WHEN datetypecode6 > 0 AND date6label IS NULL THEN dbo.qproject_get_dateype_label(datetypecode6)
        ELSE date6label
      END date6label,     
      productidcode1, 
      CASE
        WHEN productidcode1 > 0 AND productid1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 594 AND datacode = productidcode1)
        ELSE productid1label
      END productid1label,
      productidcode2,
      CASE
        WHEN productidcode2 > 0 AND productid2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 594 AND datacode = productidcode2)
        ELSE productid2label
      END productid2label,
      roletypecode1, 
      CASE
        WHEN roletypecode1 > 0 AND roletype1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 285 AND datacode = roletypecode1)
        ELSE roletype1label
      END roletype1label,
      roletypecode2, 
      CASE
        WHEN roletypecode2 > 0 AND roletype2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 285 AND datacode = roletypecode2)
        ELSE roletype2label
      END roletype2label,
      pricetypecode1, 
      CASE
        WHEN pricetypecode1 > 0 AND price1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode1)
        ELSE price1label
      END price1label,
      pricetypecode2, 
      CASE
        WHEN pricetypecode2 > 0 AND price2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode2)
        ELSE price2label
      END price2label,
      pricetypecode3, 
      CASE
        WHEN pricetypecode3 > 0 AND price3label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode3)
        ELSE price3label
      END price3label,    
      pricetypecode4,
      CASE
        WHEN pricetypecode4 > 0 AND price4label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 306 AND datacode = pricetypecode4)
        ELSE price4label
      END price4label,
      tableid1, 
      CASE
        WHEN tableid1 > 0 AND tableidlabel1 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid1)
        ELSE tableidlabel1
      END tableidlabel1,
      tableid2, 
      CASE
        WHEN tableid2 > 0 AND tableidlabel2 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid2)
        ELSE tableidlabel2
      END tableidlabel2,
      contactrelationship1, 
      CASE
        WHEN contactrelationship1 > 0 AND contactrelationship1label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 519 AND datacode = contactrelationship1)
        ELSE contactrelationship1label
      END contactrelationship1label,
      contactrelationship2, 
      CASE
        WHEN contactrelationship2 > 0 AND contactrelationship2label IS NULL THEN (SELECT COALESCE(datadescshort, datadesc, NULL) FROM gentables WHERE tableid = 519 AND datacode = contactrelationship2)
        ELSE contactrelationship2label
      END contactrelationship2label,
      createitemtypecode, createclasscode, createnewrelatecode, createexistrelatecode, createprojrolecode, createtitlerolecode,
      create2itemtypecode, create2classcode, create2newrelatecode, create2existrelatecode, create2projrolecode, create2titlerolecode,
      create3itemtypecode, create3classcode, create3newrelatecode, create3existrelatecode, create3projrolecode, create3titlerolecode,      
      relateitemtypecode, relateclasscode, relate2itemtypecode, relate2classcode, relate3itemtypecode, relate3classcode, 
      relatecurrentprojrelcode, relaterelatedprojrelcode, relateprojrolecode, relatetitlerolecode,
      relate2currentprojrelcode, relate2relatedprojrelcode, relate2projrolecode, relate2titlerolecode,
      relate3currentprojrelcode, relate3relatedprojrelcode, relate3projrolecode, relate3titlerolecode,      
      hidefiltersind, hideclassind, hidetypeind, hidethisrelind, hideotherrelind, hidenotesind, hideownerind, hideparticipantsind,
      addrelateditemind, lastmaintdate, lastuserid, hidedeletebuttonind, hidestatusind, hidekeyind,
      defaultfilteritemtype,defaultfilterusageclass,defaultsortorder,createastemplateind,create2astemplateind,create3astemplateind,
      scrollbarheight,displaytemplatesonlyind,COALESCE(alloweditablefieldsind,0) alloweditablefieldsind
    FROM taqrelationshiptabconfig
    WHERE relationshiptabcode = @i_datacode AND itemtypecode IS NULL AND usageclass IS NULL

END
go

GRANT EXEC ON dbo.qproject_get_taqrelationshiptabconfig TO PUBLIC
GO
