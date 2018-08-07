if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_delete_subordinate_comments') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_delete_subordinate_comments
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_delete_subordinate_comments
 (@i_bookkey						integer,
	@i_printingkey				integer,
	@i_commenttypecode		integer,
	@i_commenttypesubcode	integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS


/******************************************************************************
**  Name: qtitle_delete_subordinate_comments
**  Desc: This stored procedure removes the matching comment for each of the books subordinates if they have one  
**           
**    Auth: Dustin Miller
**    Date: April 5, 2012
**
**    Modified: Kusum Basra
**    Date: November 3, 2014
**    Desc: Only delete comments if propagate to subordinate titles enabled (Case 30256)
*******************************************************************************/

DECLARE @error_var    INT,
        @v_bookkey_from INT,
        @v_bookkey_to INT,
        @v_workfieldind INT

BEGIN
	SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_bookkey > 0 BEGIN
    SET @v_bookkey_from = @i_bookkey
  END
  ELSE BEGIN
    -- invalid bookkey
    RETURN    
  END
  
  IF @i_commenttypecode = 1 BEGIN  -- Marketing
	SELECT @v_workfieldind = workfieldind
	  FROM titlehistorycolumns 
	 WHERE columnkey = 260
  END
  ELSE IF @i_commenttypecode = 3 BEGIN  -- Editorial
	SELECT @v_workfieldind = workfieldind
	  FROM titlehistorycolumns 
	 WHERE columnkey = 261
  END 
  ELSE IF @i_commenttypecode = 4 BEGIN  -- Title
	SELECT @v_workfieldind = workfieldind
	  FROM titlehistorycolumns 
	 WHERE columnkey = 70
  END 
  ELSE IF @i_commenttypecode = 5 BEGIN  -- Publicitiy
	SELECT @v_workfieldind = workfieldind
	  FROM titlehistorycolumns 
	 WHERE columnkey = 262
  END 
  
  IF @v_workfieldind = 1 BEGIN

	  DECLARE book_cur CURSOR FOR
	   SELECT bookkey
		 FROM book 
		WHERE propagatefrombookkey = @v_bookkey_from
	  
	  OPEN book_cur
	  
	  FETCH NEXT FROM book_cur INTO @v_bookkey_to
	  WHILE (@@FETCH_STATUS <> -1)
	  BEGIN
		DELETE FROM bookcomments
		WHERE bookkey = @v_bookkey_to
				AND printingkey = @i_printingkey
				AND commenttypecode = @i_commenttypecode
				AND commenttypesubcode = @i_commenttypesubcode

		FETCH NEXT FROM book_cur INTO @v_bookkey_to
	  END

	  CLOSE book_cur
	  DEALLOCATE book_cur
  END

END
GO
GRANT EXEC ON qtitle_delete_subordinate_comments TO PUBLIC
GO


