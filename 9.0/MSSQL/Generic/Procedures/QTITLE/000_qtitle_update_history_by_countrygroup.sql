if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_update_history_by_countrygroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_update_history_by_countrygroup
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_update_history_by_countrygroup
 (@i_countrygroup				integer,
  @i_tablename					varchar(50),
  @i_actiontype					varchar(20),
  @i_userid							varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_update_history_by_countrygroup
**  Desc: This stored procedure returns all title bookkeys that would be affected by
					the given country code.
**
**  Auth: Dustin Miller
**  Date: 7/30/12
*************************************************************************************/

BEGIN

  DECLARE
		@v_bookkey				INT,
		@v_bookkey_count	INT,
    @v_error					INT,
    @v_rowcount				INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
	DECLARE @booktable TABLE
	(
		bookkey	int
	)
	
	INSERT INTO @booktable
	EXEC qtitle_get_titles_by_countrygroup @i_countrygroup, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  SELECT @v_bookkey_count = COUNT(bookkey)
  FROM @booktable
  
  IF @v_bookkey_count IS NOT NULL AND @v_bookkey_count > 0
  BEGIN
		DECLARE book_cursor CURSOR FAST_FORWARD FOR
		SELECT bookkey
		FROM @booktable
		
		OPEN book_cursor
		
		FETCH book_cursor
		INTO @v_bookkey
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			EXEC qtitle_update_titlehistory @i_tablename, '(multiple)', @v_bookkey, 0, 0,
				NULL, @i_actiontype, @i_userid, 0, NULL, @o_error_code OUTPUT, @o_error_desc OUTPUT
			
			FETCH book_cursor
			INTO @v_bookkey
		END
		
		CLOSE book_cursor
		DEALLOCATE book_cursor
	 
	END
  
END
GO

GRANT EXEC ON qtitle_update_history_by_countrygroup TO PUBLIC
GO
