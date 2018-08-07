if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_titleinfo_sect_config') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_titleinfo_sect_config
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: qutl_get_titleinfo_sect_config
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  03/28/2016   UK          Case 37237
**  12/16/2016   UK          Case 42268
*******************************************************************************/

CREATE PROCEDURE [dbo].[qutl_get_titleinfo_sect_config]
(@i_bookkey			integer,
 @i_altsection		tinyint,
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	DECLARE @v_datacode INT,
			@v_itemtype INT,
			@v_usageclass INT,
			@v_tableid INT

	SET @o_error_code = 0
	SET @o_error_desc = ''
	SET @v_tableid = 636
	
  CREATE TABLE #gentablesitemtypeinfo (
    datacode int null,
    datasubcode int null,     
	datadesc VARCHAR(120) null,
	sortorder int null,
	relateddatacode int null,
	indicator1 tinyint null,
	text1 VARCHAR(255) null,
	numericdesc1 float null,
	alternatedesc1 VARCHAR (255) null)  	

	IF COALESCE(@i_altsection, 0) = 0
	BEGIN
		SET @v_datacode = 5
	END
	ELSE BEGIN
		SET @v_datacode = 11
	END

	SELECT @v_itemtype = datacode
	FROM gentables
	WHERE tableid = 550
	  AND qsicode = 1

	SELECT @v_usageclass = usageclasscode
	FROM book
	WHERE bookkey = @i_bookkey
	
    IF @v_usageclass > 0 BEGIN 
	  INSERT INTO #gentablesitemtypeinfo	  
	  SELECT gi.datacode, gi.datasubcode, s.datadesc, COALESCE(gi.sortorder, s.sortorder) sortorder, gi.relateddatacode, gi.indicator1, gi.text1, COALESCE(gi.numericdesc1, s.numericdesc1) as numericdesc1, s.alternatedesc1
	  FROM gentablesitemtype gi, subgentables s
	  WHERE gi.tableid = s.tableid AND
		  gi.datacode = s.datacode AND
		  gi.datasubcode = s.datasubcode AND
		  gi.tableid = @v_tableid AND
		  gi.itemtypecode = @v_itemtype AND
		  (gi.itemtypesubcode = @v_usageclass)     
    END	
    
  INSERT INTO #gentablesitemtypeinfo	  
  SELECT gi.datacode, gi.datasubcode, s.datadesc, COALESCE(gi.sortorder, s.sortorder) sortorder, gi.relateddatacode, gi.indicator1, gi.text1, COALESCE(gi.numericdesc1, s.numericdesc1) as numericdesc1, s.alternatedesc1
  FROM gentablesitemtype gi, subgentables s
  WHERE gi.tableid = s.tableid AND
      gi.datacode = s.datacode AND
      gi.datasubcode = s.datasubcode AND
      gi.tableid = @v_tableid AND
      gi.itemtypecode = @v_itemtype AND
      (gi.itemtypesubcode = @v_usageclass OR gi.itemtypesubcode = 0)
      AND NOT EXISTS(SELECT * FROM #gentablesitemtypeinfo t WHERE t.datacode = gi.datacode AND t.datasubcode = gi.datasubcode)      
    	    
 
  SELECT * FROM #gentablesitemtypeinfo
  WHERE sortorder > 0
  and datacode = @v_datacode
  order by sortorder asc, numericdesc1 asc
 	
  IF @@ERROR <> 0
  BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Failed to retrieve itemtype data from qutl_get_titleinfo_sect_config.'
	RETURN
  END
	
GO

GRANT EXEC ON qutl_get_titleinfo_sect_config TO PUBLIC
GO

