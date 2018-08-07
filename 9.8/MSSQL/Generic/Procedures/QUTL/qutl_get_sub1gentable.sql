IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_sub1gentable')
  DROP  Procedure  qutl_get_sub1gentable
GO

CREATE PROCEDURE qutl_get_sub1gentable
 (@i_tableid        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_sub1gentable
**  Desc: This stored procedure returns gentable information for given tableid.
**
**  Auth: James P. Weber
**  Date: 25 Feb 2004
*******************************************************************************
**  9/18/07 - KW - Also return gentables / subgentables description (fulldesc).
*******************************************************************************/

  DECLARE
    @error_var  INT,
    @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT DISTINCT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, g.datadesc + '/' + s.datadesc fulldesc, 
                  g.qsicode gen_qsicode, g.sortorder gen_sortorder, s.*,
                  COALESCE(s.datadescshort,s.datadesc) shortdesc
  FROM gentables g, subgentables s
      LEFT OUTER JOIN subgentablesorglevel o ON (s.tableid = o.tableid AND s.datacode = o.datacode AND s.datasubcode = o.datasubcode) 
      LEFT OUTER JOIN gentablesdesc d ON (s.tableid = d.tableid)
  WHERE g.tableid = s.tableid AND
      g.datacode = s.datacode AND
      s.tableid = @i_tableid
  ORDER BY s.tableid ASC, g.sortorder ASC, s.datacode ASC, s.sortorder ASC, s.datadesc ASC, s.datasubcode ASC 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: tableid = ' + CONVERT(varchar, @i_tableid)
  END 
GO

GRANT EXEC ON qutl_get_sub1gentable TO PUBLIC
GO
