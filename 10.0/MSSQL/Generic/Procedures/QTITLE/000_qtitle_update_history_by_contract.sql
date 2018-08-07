if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_update_history_by_contract') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_update_history_by_contract
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_update_history_by_contract
 (@i_contractprojectkey	integer,
  @i_tablename					varchar(50),
  @i_actiontype					varchar(20),
  @i_userid							varchar(30),
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_update_history_by_contract
**  Desc: 
**
**  Auth: Dustin Miller
**  Date: 8/10/12
*************************************************************************************/

BEGIN

  DECLARE
		@v_bookkey				INT,
		@v_bookkey_count	INT,
		@v_printingkey		INT,
    @v_error					INT,
    @v_rowcount				INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
	DECLARE @booktable TABLE
	(
		bookkey	int,
		printingkey int
	)
	
	INSERT INTO @booktable
	EXEC qtitle_get_titles_from_contract @i_contractprojectkey, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  SELECT @v_bookkey_count = COUNT(bookkey)
  FROM @booktable
  
  IF @v_bookkey_count IS NOT NULL AND @v_bookkey_count > 0
  BEGIN
		DECLARE book_cursor CURSOR FAST_FORWARD FOR
		SELECT bookkey, printingkey
		FROM @booktable
		
		OPEN book_cursor
		
		FETCH book_cursor
		INTO @v_bookkey, @v_printingkey
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			EXEC qtitle_update_titlehistory @i_tablename, '(multiple)', @v_bookkey, @v_printingkey, 0,
				NULL, @i_actiontype, @i_userid, 0, NULL, @o_error_code OUTPUT, @o_error_desc OUTPUT
			
			FETCH book_cursor
			INTO @v_bookkey, @v_printingkey
		END
		
		CLOSE book_cursor
		DEALLOCATE book_cursor
	 
	END
  
END
GO

GRANT EXEC ON qtitle_update_history_by_contract TO PUBLIC
GO
