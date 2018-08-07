if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_websection_config') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_websection_config
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: qutl_get_websection_config
**  Desc: Get dynamically configurable fields for a websection (control) 
**  Auth: Colman
**  Date: 5/2/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  
*******************************************************************************/

CREATE PROCEDURE [dbo].[qutl_get_websection_config]
(
 @i_itemtypecode    integer,
 @i_itemtypesubcode integer,
 @i_sectioncode     integer,
 @o_error_code	    int output,
 @o_error_desc	    varchar(2000) output)
AS
	DECLARE @v_tableid INT

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
    alternatedesc1 VARCHAR (255) null
  )  	

  IF @i_itemtypesubcode > 0 BEGIN 
    INSERT INTO #gentablesitemtypeinfo	  
    SELECT gi.datacode, gi.datasubcode, s.datadesc, COALESCE(gi.sortorder, s.sortorder) sortorder, gi.relateddatacode, gi.indicator1, gi.text1, s.numericdesc1, s.alternatedesc1
    FROM gentablesitemtype gi, subgentables s
    WHERE gi.tableid = s.tableid AND
          gi.datacode = s.datacode AND
          gi.datasubcode = s.datasubcode AND
          gi.tableid = @v_tableid AND
          gi.itemtypecode = @i_itemtypecode AND
          (gi.itemtypesubcode = @i_itemtypesubcode)     
  END	
    
  INSERT INTO #gentablesitemtypeinfo	  
  SELECT gi.datacode, gi.datasubcode, s.datadesc, COALESCE(gi.sortorder, s.sortorder) sortorder, gi.relateddatacode, gi.indicator1, gi.text1, s.numericdesc1, s.alternatedesc1
  FROM gentablesitemtype gi, subgentables s
  WHERE gi.tableid = s.tableid AND
        gi.datacode = s.datacode AND
        gi.datasubcode = s.datasubcode AND
        gi.tableid = @v_tableid AND
        gi.itemtypecode = @i_itemtypecode AND
        (gi.itemtypesubcode = @i_itemtypesubcode OR gi.itemtypesubcode = 0)
        AND NOT EXISTS(SELECT * FROM #gentablesitemtypeinfo t WHERE t.datacode = gi.datacode AND t.datasubcode = gi.datasubcode)      
    	    
  SELECT * FROM #gentablesitemtypeinfo
  WHERE sortorder > 0
  AND datacode = @i_sectioncode
  ORDER BY sortorder ASC, numericdesc1 ASC
 	
  IF @@ERROR <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Failed to retrieve itemtype data from qutl_get_websection_config.'
    RETURN
  END
	
GO

GRANT EXEC ON qutl_get_websection_config TO PUBLIC
GO

