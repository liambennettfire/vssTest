if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_title_authorkeys') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_title_authorkeys
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_title_authorkeys
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/****************************************************************************************************
**  Name: qtitle_get_title_authorkeys
**  Desc: This stored procedure returns all associatedtitles records for the given title - used in 
**        Copy Titles/Related Items wizard.
**
**  Auth: Kate
**  Date: 07/16/12
*****************************************************************************************************/

DECLARE
  @v_error INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT authorkey FROM bookauthor 
  WHERE bookkey = @i_bookkey
    
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error retrieving associatedtitles for bookkey=' + CONVERT(VARCHAR, @i_bookkey) + '.'
  END
  
END
GO

GRANT EXEC ON qtitle_get_title_authorkeys TO PUBLIC
GO
    