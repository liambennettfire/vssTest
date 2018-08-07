IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_sub2gentables_all')
  BEGIN
    PRINT 'Dropping Procedure qutl_get_sub2gentables_all'
    DROP  Procedure  qutl_get_sub2gentables_all
  END

GO

PRINT 'Creating Procedure qutl_get_sub2gentables_all'
GO

CREATE PROCEDURE qutl_get_sub2gentables_all
 (@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qutl_get_sub2gentables_all
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

  SELECT distinct o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, g.*,
    COALESCE(g.datadescshort,g.datadesc) shortdesc
    FROM sub2gentables g LEFT OUTER JOIN sub2gentablesorglevel o
    ON (g.tableid = o.tableid and g.datacode = o.datacode and g.datasubcode = o.datasubcode and g.datasub2code = o.datasub2code) 
    LEFT OUTER JOIN gentablesdesc d ON (g.tableid = d.tableid)
    ORDER BY g.tableid ASC, g.datacode ASC, g.datasubcode ASC, g.sortorder ASC, g.datadesc ASC, g.datasub2code ASC 


  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: sub2 '
  END 
GO

GRANT EXEC ON qutl_get_sub2gentables_all TO PUBLIC

GO


