if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_gentablesrelationships') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_gentablesrelationships
GO

CREATE PROCEDURE qutl_get_gentablesrelationships
 (@o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_gentablesrelationships
**  Desc: This stored procedure returns gentablesrelationships data.
**
**  Auth: Kate J. Wiewiora
**  Date: August 15 2007
*******************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT r.*, g1.tabledesclong table1desc, g2.tabledesclong table2desc
  FROM gentablesrelationships r, gentablesdesc g1, gentablesdesc g2
  WHERE r.gentable1id = g1.tableid AND 
        r.gentable2id = g2.tableid AND
        (g1.fakeentryind IS NULL OR g1.fakeentryind = 0) AND
        (g2.fakeentryind IS NULL OR g2.fakeentryind = 0)
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error accessing gentablesrelationships table.'
  END
  
  IF @v_rowcount < 1 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'There are no gentablesrelationships records set up.'
  END
  
GO

GRANT EXEC ON qutl_get_gentablesrelationships TO PUBLIC
GO
