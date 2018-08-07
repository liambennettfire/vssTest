if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_projectdetails_sect_config') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_projectdetails_sect_config
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: qutl_get_projectdetails_sect_config
**  Desc: Case 37409
**  Auth: Colman
**  Date: 04/06/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
*   07/21/16     Colman      Case 37409 - Add usageclass param as alternative to getting from projectkey
*   07/22/16     Uday        Case 39277
*   08/23/16     Colman      Case 39892
*   11/07/16     Colman      Case 39892 - gentablesitemtype field name override not implemented
*   03/22/17     Colman      Case 44001 - Series project uses same detail section as a TAQ
*******************************************************************************/

CREATE PROCEDURE [dbo].[qutl_get_projectdetails_sect_config]
(@i_itemtype    integer,
 @i_usageclass    integer,
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	DECLARE @v_datacode INT,
          @v_tableid INT,
          @v_itemtypenumericdesc1label VARCHAR(30),
          @v_IsOverrideColumn INT

	SET @o_error_code = 0
	SET @o_error_desc = ''
	SET @v_tableid = 636
	SET @v_IsOverrideColumn = 0
	
  CREATE TABLE #gentablesitemtypeinfo (
    datacode int null,
    datasubcode int null,     
    datadesc VARCHAR(120) null,
    sortorder int null,
    relateddatacode int null,
    indicator1 tinyint null,
    numericdesc1 float null,
    alternatedesc1 VARCHAR (255) null)  	

	IF EXISTS (SELECT 1 FROM subgentables WHERE tableid=550 AND datacode=@i_itemtype AND datasubcode=@i_usageclass AND qsicode IN (1, 47))
	BEGIN
		SET @v_datacode = 12 -- TAQ Project or Series Project
	END
	ELSE BEGIN
		SET @v_datacode = 13 -- Other Project
	END
	
	SELECT @v_itemtypenumericdesc1label = LTRIM(RTRIM(LOWER(COALESCE(itemtypenumericdesc1label, '')))) 
	FROM gentablesdesc WHERE tableid = 636
	
	IF @v_itemtypenumericdesc1label = 'column override' BEGIN
		SET @v_IsOverrideColumn = 1
	END
	      
  INSERT INTO #gentablesitemtypeinfo	  
  SELECT DISTINCT  gi.datacode, gi.datasubcode, s.datadesc, COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) sortorder,
  gi.relateddatacode, gi.indicator1, 
  CASE
     WHEN @v_IsOverrideColumn = 1 THEN COALESCE(COALESCE(gi.numericdesc1, s.numericdesc1), 9999)
     ELSE s.numericdesc1
  END numericdesc1, 
  CASE
    WHEN gi.text1 IS NOT NULL THEN gi.text1
    ELSE s.alternatedesc1
  END alternatedesc1
  FROM gentablesitemtype gi INNER JOIN subgentables s ON      
      gi.tableid = s.tableid AND
      gi.datacode = s.datacode AND
      gi.datasubcode = s.datasubcode  
  INNER JOIN dbo.qutl_get_gentable_itemtype_filtering(@v_tableid, @i_itemtype, @i_usageclass) gif ON
	  gif.datacode = s.datacode AND
	  gif.datasubcode = s.datasubcode AND 
	  gif.tableid = s.tableid 
  WHERE s.tableid = @v_tableid	AND
		s.datacode = @v_datacode AND
    gi.itemtypecode = @i_itemtype AND
    gi.itemtypesubcode = @i_usageclass
  
  INSERT INTO #gentablesitemtypeinfo	  
  SELECT DISTINCT  gi.datacode, gi.datasubcode, s.datadesc, COALESCE(COALESCE(gi.sortorder, s.sortorder), 9999) sortorder,
  gi.relateddatacode, gi.indicator1, 
  CASE
     WHEN @v_IsOverrideColumn = 1 THEN COALESCE(COALESCE(gi.numericdesc1, s.numericdesc1), 9999)
     ELSE s.numericdesc1
  END numericdesc1,   
  CASE
    WHEN gi.text1 IS NOT NULL THEN gi.text1
    ELSE s.alternatedesc1
  END alternatedesc1
  FROM gentablesitemtype gi INNER JOIN subgentables s ON      
      gi.tableid = s.tableid AND
      gi.datacode = s.datacode AND
      gi.datasubcode = s.datasubcode  
  INNER JOIN dbo.qutl_get_gentable_itemtype_filtering(@v_tableid, @i_itemtype, @i_usageclass) gif ON
	  gif.datacode = s.datacode AND
	  gif.datasubcode = s.datasubcode AND 
	  gif.tableid = s.tableid 
  WHERE s.tableid = @v_tableid	AND
		s.datacode = @v_datacode AND
    gi.itemtypecode = @i_itemtype AND
      (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
      AND NOT EXISTS(SELECT * FROM #gentablesitemtypeinfo t WHERE t.datacode = gi.datacode AND t.datasubcode = gi.datasubcode)  
 
  SELECT * FROM #gentablesitemtypeinfo
  WHERE sortorder > 0
  AND datacode = @v_datacode
  ORDER BY numericdesc1 ASC, sortorder ASC
 	
  IF @@ERROR <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Failed to retrieve itemtype data from qutl_get_projectdetails_sect_config.'
    RETURN
  END
	
GO

GRANT EXEC ON qutl_get_projectdetails_sect_config TO PUBLIC
GO

