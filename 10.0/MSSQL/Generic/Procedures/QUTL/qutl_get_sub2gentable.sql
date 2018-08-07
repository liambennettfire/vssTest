IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_sub2gentable')
  DROP  Procedure  qutl_get_sub2gentable
GO

CREATE PROCEDURE qutl_get_sub2gentable
 (@i_tableid        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************************
**  Name: qutl_get_sub1gentable
**  Desc: This stored procedure returns sub2gentables information for given tableid.
**
**  Auth: James P. Weber
**  Date: 25 Feb 2004
**************************************************************************************************
**  9/29/11 - KW - Also return gentables / subgentables / sub2gentables description (fulldesc).
**************************************************************************************************/

  DECLARE
    @error_var  INT,
    @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  SELECT DISTINCT o.orgentrykey, desc_tablemnemonic=d.tablemnemonic, g.datadesc + '/' + s.datadesc + '/' + s2.datadesc fulldesc, 
    COALESCE(s2.datadescshort,s2.datadesc) shortdesc, s2.*
  FROM gentables g, subgentables s, sub2gentables s2 
    LEFT OUTER JOIN sub2gentablesorglevel o ON (s2.tableid = o.tableid AND s2.datacode = o.datacode AND s2.datasubcode = o.datasubcode AND s2.datasub2code = o.datasub2code) 
    LEFT OUTER JOIN gentablesdesc d ON (s2.tableid = d.tableid)
  WHERE g.tableid = s.tableid AND
    g.datacode = s.datacode AND
    s.tableid = s2.tableid AND
    s.datacode = s2.datacode AND
    s.datasubcode = s2.datasubcode AND
    s2.tableid = @i_tableid 
  ORDER BY s2.tableid ASC, s2.datacode ASC, s2.datasubcode ASC, s2.sortorder ASC, s2.datadesc ASC, s2.datasub2code ASC 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: tableid = ' + CONVERT(varchar, @i_tableid) 
  END 
GO

GRANT EXEC ON qutl_get_sub2gentable TO PUBLIC

GO
