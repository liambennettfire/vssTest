if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_copy_rel_tabs') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_copy_rel_tabs
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_copy_rel_tabs
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/****************************************************************************************************
**  Name: qtitle_get_copy_rel_tabs
**  Desc: This stored procedure returns title relationship tabs with existing saved
**        titles/related items for a given title - used in Copy Titles/Related Items wizard.
**
**  Auth: Kate
**  Date: 07/13/12
*****************************************************************************************************/

DECLARE
  @v_error INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT datacode, datadesc
  FROM gentables 
  WHERE tableid = 440 AND 
    deletestatus = 'N' AND
    datacode IN (SELECT DISTINCT associationtypecode FROM associatedtitles WHERE bookkey = @i_bookkey)
  ORDER BY sortorder

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error getting Title Relationship tabs for bookkey=' + CONVERT(VARCHAR, @i_bookkey) + '.'
  END
  
END
GO

GRANT EXEC ON qtitle_get_copy_rel_tabs TO PUBLIC
GO
