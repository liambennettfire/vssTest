if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_countrygroups') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_countrygroups
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_countrygroups
 (@o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_get_countrygroups
**  Desc: This procedure returns all country groups from gentables (cache not good enough since saved to gentables via the page)
**
**	Auth: Dustin Miller
**	Date: May 15 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT DISTINCT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, d.itemtypefilterind, 
  COALESCE(g.datadescshort,g.datadesc) shortdesc, COALESCE(g.gen1ind,0) gen1ind, g.*
  FROM gentables g 
    LEFT OUTER JOIN gentablesorglevel o ON (g.tableid = o.tableid and g.datacode = o.datacode) 
    LEFT OUTER JOIN gentablesdesc d ON (g.tableid = d.tableid)
  WHERE g.tableid=633
		AND UPPER(COALESCE(g.deletestatus, '')) <> 'Y'
  ORDER BY g.tableid ASC, g.sortorder ASC, g.datadesc ASC, g.datacode ASC 
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning country group data.'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_get_countrygroups TO PUBLIC
GO