if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_title_relationship_tabs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_title_relationship_tabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_title_relationship_tabs
 (@i_itemtypecode   integer,
  @i_usageclasscode integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_get_title_relationship_tabs
**  Desc: This stored procedure returns title relationship tabs from qsiwindows.
**
**  Auth: Kate
**  Date: 09/09/09
*************************************************************************************/

BEGIN

  DECLARE
    @v_datacode INT,
    @v_error  INT,
    @v_rowcount INT,
    @v_title  VARCHAR(80)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT * FROM dbo.qtitle_get_existing_relationship_tabs(@i_itemtypecode, @i_usageclasscode)

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not get title relationship tabs from qsiwindows.'
  END
  
END
GO

GRANT EXEC ON qtitle_get_title_relationship_tabs TO PUBLIC
GO
