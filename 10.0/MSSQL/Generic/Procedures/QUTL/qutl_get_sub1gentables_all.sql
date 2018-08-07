IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_sub1gentables_all')
  BEGIN
    PRINT 'Dropping Procedure qutl_get_sub1gentables_all'
    DROP  Procedure  qutl_get_sub1gentables_all
  END

GO

PRINT 'Creating Procedure qutl_get_sub1gentables_all'
GO

CREATE PROCEDURE qutl_get_sub1gentables_all
 (@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_sub1gentables_all
**  Desc: This stored procedure returns all of the gentable
**        information for a single level gentable, and is
**        the basis for doing multi-level gentable 
**        development.
**
**    Auth: James P. Weber
**    Date: 25 Feb 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  -- Misc dropdowns with orgentry filtering on some databases cause huge wait times for the data to be retrieved
  -- so we will not put the orgentry info into the cache for that tableid (525)
  -- To get orgentry filtering for misc dropdowns call qutl_get_sub1gentables_by_org
  SELECT DISTINCT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, 
                  g.qsicode gen_qsicode, g.sortorder gen_sortorder, s.*,
                  COALESCE(s.datadescshort,s.datadesc) shortdesc
  FROM gentables g, subgentables s
	  LEFT OUTER JOIN subgentablesorglevel o ON (s.tableid = o.tableid and s.datacode = o.datacode and s.datasubcode = o.datasubcode) 
	  JOIN gentablesdesc d ON (s.tableid = d.tableid)
  WHERE g.tableid = s.tableid AND g.datacode = s.datacode AND s.tableid <> 525
  UNION
  SELECT DISTINCT null orgentrykey, desc_tablemnemonic=d.tablemnemonic, 
                    g.qsicode gen_qsicode, g.sortorder gen_sortorder, s.*,
                    COALESCE(s.datadescshort,s.datadesc) shortdesc
    FROM gentables g, subgentables s
	    JOIN gentablesdesc d ON (s.tableid = d.tableid)
    WHERE g.tableid = s.tableid AND g.datacode = s.datacode and s.tableid = 525
  ORDER BY s.tableid ASC, gen_sortorder ASC, s.datacode ASC, s.sortorder ASC, s.datadesc ASC, s.datasubcode ASC 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: sub1gentables.'
  END 
GO

GRANT EXEC ON qutl_get_sub1gentables_all TO PUBLIC
GO


