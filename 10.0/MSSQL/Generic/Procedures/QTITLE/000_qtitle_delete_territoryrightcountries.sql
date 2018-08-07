if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_delete_territoryrightcountries') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_delete_territoryrightcountries
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_delete_territoryrightcountries
 (@i_bookkey							integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_delete_territoryrightcountries
**  Desc: This procedure deletes all rows on territoryrightcountries with the corresponding bookkey
**
**	Auth: Dustin Miller
**	Date: May 24 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  DELETE
	FROM territoryrightcountries
	WHERE bookkey = @i_bookkey
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error deleting territoryrightcountries rows (bookkey=' + cast(@i_bookkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qtitle_delete_territoryrightcountries TO PUBLIC
GO