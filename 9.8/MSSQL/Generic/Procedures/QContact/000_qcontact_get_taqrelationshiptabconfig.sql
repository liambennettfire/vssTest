IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_taqrelationshiptabconfig') )
DROP PROCEDURE dbo.qcontact_get_taqrelationshiptabconfig
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qcontact_get_taqrelationshiptabconfig]
 (@i_datacode       integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************************
**  Name: qcontact_get_taqrelationshiptabconfig
**  Desc: This stored procedure returns data based on configured fields in the
**        taqrelationshiptabconfig table.
**
**  Auth: Kate W.
**  Date: 3 December 2012
**
**  (copied from qproject_get_taqrelationshiptabconfig)
*****************************************************************************************************/

DECLARE
  @v_error  INT,
  @v_rowcount INT
    
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Make sure we have only one config row for this configuration
  SELECT @v_rowcount = COUNT(*) 
  FROM taqrelationshiptabconfig 
  WHERE relationshiptabcode = @i_datacode AND itemtypecode = 2  --contacts

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
  
  SELECT quantity1label, quantity2label, indicator1label, indicator2label, 
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
    createitemtypecode, createclasscode, createnewrelatecode, createexistrelatecode, createprojrolecode, createtitlerolecode,
    create2itemtypecode, create2classcode, create2newrelatecode, create2existrelatecode, create2projrolecode, create2titlerolecode,
    create3itemtypecode, create3classcode, create3newrelatecode, create3existrelatecode, create3projrolecode, create3titlerolecode,      
    relateitemtypecode, relateclasscode, relate2itemtypecode, relate2classcode, relate3itemtypecode, relate3classcode, 
    hidefiltersind, hideclassind, hidetypeind, hidethisrelind, hideotherrelind, hidenotesind, hideownerind, addrelateditemind,
    lastmaintdate, lastuserid,COALESCE(alloweditablefieldsind,0) alloweditablefieldsind
  FROM taqrelationshiptabconfig
  WHERE relationshiptabcode = @i_datacode AND itemtypecode = 2 AND usageclass IS NULL

END
go

GRANT EXEC ON dbo.qcontact_get_taqrelationshiptabconfig TO PUBLIC
GO
