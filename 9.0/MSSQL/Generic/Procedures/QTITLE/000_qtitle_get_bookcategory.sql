if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_bookcategory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_bookcategory
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_bookcategory
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_bookcategory
**  Desc: This stored procedure returns info from the bookcategory table. 
**
**  Auth: Kate
**  Date: 11 February 2009
*******************************************************************************/

  DECLARE @v_error  INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT *
  FROM bookcategory
  WHERE bookkey = @i_bookkey 
  ORDER BY sortorder, categorycode

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error retrieving from bookcategory table: bookkey = ' + cast(@i_bookkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qtitle_get_bookcategory TO PUBLIC
GO
