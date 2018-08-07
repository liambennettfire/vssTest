 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_gentable_by_mapping')
  BEGIN
    PRINT 'Dropping Procedure qutl_get_gentable_by_mapping'
    DROP  Procedure  qutl_get_gentable_by_mapping
  END

GO

PRINT 'Creating Procedure qutl_get_gentable_by_mapping'
GO

CREATE PROCEDURE qutl_get_gentable_by_mapping
 (@i_genrelationshipkey   integer,
  @i_nofilter             integer,
  @o_showallvalues        integer output,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_gentable_by_mapping
**  Desc: This stored procedure returns gentable values for gentable2id
**        on gentablesrelationshipdetail table.
**
**  Auth: Kate J. Wiewiora
**  Date: March 14 2005
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_showallvalues = 1
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_showallind INT
  DECLARE @v_tableid INT

  SELECT @v_showallind = showallind, @v_tableid = gentable2id
    FROM gentablesrelationships r
   WHERE r.gentablesrelationshipkey = @i_genrelationshipkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'could not get gentables based on gentable relationship mapping: ' + 
	CONVERT(varchar, @i_genrelationshipkey) 
    RETURN
  END 

  IF @v_showallind = 1 OR @i_nofilter = 1
    BEGIN
      -- show all datacodes/desc for gentable2id
      SELECT g.datacode code1, g.datacode code2, 0 defaultind, o.orgentrykey, i.itemtypecode, i.itemtypesubcode, g.*
      FROM gentables g 
        LEFT OUTER JOIN gentablesorglevel o ON g.tableid = o.tableid AND g.datacode = o.datacode
        LEFT OUTER JOIN gentablesitemtype i ON g.tableid = i.tableid AND g.datacode = i.datacode
      WHERE g.tableid = @v_tableid 
      ORDER BY g.sortorder ASC, g.datadesc ASC, g.datacode ASC

      -- flag returned to calling location that tells if there is a relationship setup
      SET @o_showallvalues = 1
    END
    
  ELSE 
    BEGIN
      -- show maped datacodes/desc
      SELECT rd.code1, rd.code2, rd.defaultind, o.orgentrykey, i.itemtypecode, i.itemtypesubcode, g.*
      FROM gentables g
        LEFT OUTER JOIN gentablesorglevel o ON g.tableid = o.tableid AND g.datacode = o.datacode   
        LEFT OUTER JOIN gentablesitemtype i ON g.tableid = i.tableid AND g.datacode = i.datacode,
        gentablesrelationshipdetail rd,   
        gentablesrelationships r
      WHERE r.gentable2id = g.tableid AND
        rd.gentablesrelationshipkey = r.gentablesrelationshipkey AND 
        rd.code2 = g.datacode AND 
        rd.gentablesrelationshipkey = @i_genrelationshipkey 
      ORDER BY g.sortorder ASC, g.datadesc ASC, g.datacode ASC

      -- flag returned to calling location that tells if there is a relationship setup
      SET @o_showallvalues = 0
    END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'could not get gentables based on gentable relationship mapping: ' + 
	CONVERT(varchar, @i_genrelationshipkey) 
  END 
GO

GRANT EXEC ON qutl_get_gentable_by_mapping TO PUBLIC
GO
