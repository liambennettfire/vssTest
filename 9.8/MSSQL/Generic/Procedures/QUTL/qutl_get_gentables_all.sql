IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_gentables_all')
  BEGIN
    PRINT 'Dropping Procedure qutl_get_gentables_all'
    DROP  Procedure  qutl_get_gentables_all
  END

GO

PRINT 'Creating Procedure qutl_get_gentables_all'
GO

CREATE PROCEDURE qutl_get_gentables_all
 (@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qutl_get_gentables_all
**  Desc: This stored procedure returns all of the gentable
**        information for a single level gentable, and is
**        the basis for doing multi-level gentable 
**        development.
**
**              
**
**    Auth: James P. Weber
**    Date: 25 Feb 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT DISTINCT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, d.itemtypefilterind, 
  COALESCE(g.datadescshort,g.datadesc) shortdesc, COALESCE(g.gen1ind,0) gen1ind, g.*
  FROM gentables g 
    LEFT OUTER JOIN gentablesorglevel o ON (g.tableid = o.tableid and g.datacode = o.datacode) 
    LEFT OUTER JOIN gentablesdesc d ON (g.tableid = d.tableid)
  ORDER BY g.tableid ASC, g.sortorder ASC, g.datadesc ASC, g.datacode ASC 


  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: tableid = all' 
  END 
GO

GRANT EXEC ON qutl_get_gentables_all TO PUBLIC

GO


