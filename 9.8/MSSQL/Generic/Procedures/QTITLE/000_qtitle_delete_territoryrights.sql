if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_delete_territoryrights') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_delete_territoryrights
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_delete_territoryrights
 (@i_bookkey							integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_delete_territoryrights
**  Desc: This procedure deletes all rows on territoryrights and territoryrightcountries with the corresponding bookkey
**
**	Auth: Dustin Miller
**	Date: July 9 2012
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
	BEGIN TRAN
	
	DELETE
	FROM territoryrightcountries
	WHERE bookkey = @i_bookkey
	
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error deleting territoryrightcountries rows (bookkey=' + cast(@i_bookkey as varchar) + ')'
    ROLLBACK TRAN
    RETURN  
  END 
	
	DELETE
	FROM territoryrights
	WHERE bookkey = @i_bookkey
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error deleting territoryrights rows (bookkey=' + cast(@i_bookkey as varchar) + ')'
    ROLLBACK TRAN
    RETURN  
  END 
  
  COMMIT TRAN  
GO

GRANT EXEC ON qtitle_delete_territoryrights TO PUBLIC
GO