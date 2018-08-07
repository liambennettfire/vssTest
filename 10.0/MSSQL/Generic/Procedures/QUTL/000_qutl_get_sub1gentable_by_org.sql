IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_sub1gentable_by_org')
  DROP  Procedure  qutl_get_sub1gentable_by_org
GO

CREATE PROCEDURE qutl_get_sub1gentable_by_org
 (@i_tableid        integer,
  @i_datacode       integer,
  @i_orgentrykey    integer,  
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_sub1gentable_by_org
**  Desc: This stored procedure returns gentable information for given 
**        tableid, datacode, and possibly orgentrykey
**
**  Auth: Alan Katzen
**  Date: 07 February 2018
*******************************************************************************
**
*******************************************************************************/

  DECLARE
    @error_var  INT,
    @rowcount_var INT,
    @v_filterorglevelkey INT,
    @v_security_count INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- is org security allowed to be configured for this gentable
  SELECT @v_filterorglevelkey = coalesce(filterorglevelkey,0) FROM gentablesdesc
   WHERE tableid = @i_tableid

  SET @v_security_count = 0

  IF @v_filterorglevelkey > 0 BEGIN
    -- is org security actually setup for this gentable
    SELECT top 1 @v_security_count = orgentrykey FROM subgentablesorglevel
     WHERE tableid = @i_tableid and datacode = @i_datacode
  END

  IF coalesce(@i_orgentrykey,0) != 0 AND @v_security_count > 0 BEGIN
    SELECT DISTINCT o.orgentrykey, g.datadesc + '/' + s.datadesc fulldesc, 
                    g.qsicode gen_qsicode, g.sortorder gen_sortorder, s.*,
                    COALESCE(s.datadescshort,s.datadesc) shortdesc
    FROM gentables g, subgentables s
        LEFT OUTER JOIN subgentablesorglevel o ON (s.tableid = o.tableid AND s.datacode = o.datacode AND s.datasubcode = o.datasubcode)        
    WHERE g.tableid = s.tableid AND
        g.datacode = s.datacode AND
        s.tableid = @i_tableid AND
        s.datacode = @i_datacode AND
        coalesce(o.orgentrykey,0) in (0, @i_orgentrykey)
    ORDER BY s.tableid ASC, g.sortorder ASC, s.datacode ASC, s.sortorder ASC, s.datadesc ASC, s.datasubcode ASC   
  END
  ELSE BEGIN
    SELECT DISTINCT o.orgentrykey, g.datadesc + '/' + s.datadesc fulldesc, 
                    g.qsicode gen_qsicode, g.sortorder gen_sortorder, s.*,
                    COALESCE(s.datadescshort,s.datadesc) shortdesc
    FROM gentables g, subgentables s
        LEFT OUTER JOIN subgentablesorglevel o ON (s.tableid = o.tableid AND s.datacode = o.datacode AND s.datasubcode = o.datasubcode) 
    WHERE g.tableid = s.tableid AND
        g.datacode = s.datacode AND
        s.tableid = @i_tableid AND
        s.datacode = @i_datacode
    ORDER BY s.tableid ASC, g.sortorder ASC, s.datacode ASC, s.sortorder ASC, s.datadesc ASC, s.datasubcode ASC 
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error retrieving subgentable data for tableid = ' + CONVERT(varchar, @i_tableid) + ' and datacode = ' + CONVERT(varchar, @i_datacode)
  END 
GO

GRANT EXEC ON qutl_get_sub1gentable_by_org TO PUBLIC
GO
