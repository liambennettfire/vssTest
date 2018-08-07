IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_taqrelationshiptabconfig') )
DROP PROCEDURE dbo.qtitle_get_taqrelationshiptabconfig
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qtitle_get_taqrelationshiptabconfig]
 (@i_bookkey        integer,
  @i_datacode       integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/********************************************************************************************************************
**  Name: qtitle_get_taqrelationshiptabconfig
**  Desc: This stored procedure returns data based on configured fields in the
**        taqrelationshiptabconfig table for the given title's usage class.
**
**  Auth: Kate W.
**  Date: 21 May 2012
**********************************************************************************************************************
**  Change History
**********************************************************************************************************************
**  Date:       Author:  Description:
**  --------    ------   ---------------------------------------------------------------------------------------------
**  04/25/16    Uday	  Case 37102 - 37585 More Web Relationship Tab Config Settings
**  06/04/18    Colman   Case 43675
**  06/21/18    Colman   Case 51661
********************************************************************************************************************/

DECLARE
  @v_configCount_1 INT,
  @v_configCount_2 INT,
  @v_configCount_3 INT,
  @v_error  INT,
  @v_itemtype INT,
  @v_rowcount INT,
  @v_usageclass INT,
  @v_hidedeletebuttonind TINYINT    
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_hidedeletebuttonind = NULL  

  -- Get itemtype and usage class for this project 
  SELECT @v_itemtype = itemtypecode, @v_usageclass = usageclasscode
  FROM coretitleinfo
  WHERE bookkey = @i_bookkey
		
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
  
  SELECT quantity1label, quantity2label, quantity3label, quantity4label, decimal1label, decimal2label, decimal1format, decimal2format, indicator1label, indicator2label, 
    miscitemkey1,
    CASE
      WHEN miscitemkey1 > 0 AND miscitem1label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey1)
      ELSE miscitem1label
    END miscitem1label, 
    miscitemkey2, 
    CASE
      WHEN miscitemkey2 > 0 AND miscitem2label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey2)
      ELSE miscitem2label
    END miscitem2label,
    miscitemkey3, 
    CASE
      WHEN miscitemkey3 > 0 AND miscitem3label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey3)
      ELSE miscitem3label
    END miscitem3label,
    miscitemkey4, 
    CASE
      WHEN miscitemkey4 > 0 AND miscitem4label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey4)
      ELSE miscitem4label
    END miscitem4label,
    miscitemkey5, 
    CASE
      WHEN miscitemkey5 > 0 AND miscitem5label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey5)
      ELSE miscitem5label
    END miscitem5label,
    miscitemkey6, 
    CASE
      WHEN miscitemkey6 > 0 AND miscitem6label IS NULL THEN dbo.qutl_get_misc_label(miscitemkey6)
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
    tableid3, 
    CASE
      WHEN tableid3 > 0 AND tableidlabel3 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid3)
      ELSE tableidlabel3
    END tableidlabel3,
    tableid4, 
    CASE
      WHEN tableid4 > 0 AND tableidlabel4 IS NULL THEN (SELECT COALESCE(tabledesclong, NULL) FROM gentablesdesc WHERE tableid = tableid4)
      ELSE tableidlabel4
    END tableidlabel4,
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
    defaultfilteritemtype,defaultfilterusageclass,defaultsortorder,COALESCE(alloweditablefieldsind,0) alloweditablefieldsind
    ,scrollbarheight,displaytemplatesonlyind
  FROM dbo.qproject_get_filtered_tabconfig_table(@i_datacode, @v_itemType, @v_usageClass, NULL, NULL)

END
go

GRANT EXEC ON dbo.qtitle_get_taqrelationshiptabconfig TO PUBLIC
GO