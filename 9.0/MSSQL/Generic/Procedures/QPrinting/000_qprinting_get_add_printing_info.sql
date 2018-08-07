if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_get_add_printing_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qprinting_get_add_printing_info
GO

CREATE PROCEDURE qprinting_get_add_printing_info
 (@i_bookkey                 integer,
  @o_error_code              integer       output,
  @o_error_desc              varchar(2000) output)
AS

/******************************************************************************
**  Name: qprinting_get_add_printing_info
**  Desc: This procedure will return info for the add printing process 
**
**    Auth: Alan Katzen
**    Date: Sept 16 2014
*******************************************************************************/

  DECLARE 
    @error_var             INT,
    @rowcount_var          INT,
    @v_error_desc          varchar(2000),
    @v_count               INT,
    @v_bookkey             INT,
    @v_book_title          VARCHAR(255),
    @v_next_printingnum    INT,
    @v_max_printingnum     INT,
    @v_printing_title      VARCHAR(255),
    @v_printingnum_str     VARCHAR(50)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SET @v_bookkey = COALESCE(@i_bookkey,0)
  
  IF @v_bookkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing printing info (add printing).  Must pass in printing bookkey.'  
    RETURN 
  END  
  
  SELECT @v_max_printingnum = max(printingnum)
    FROM printing
   WHERE bookkey = @v_bookkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing printing info (max printing): bookkey = ' + cast(@v_bookkey AS VARCHAR)  
    RETURN 
  END     
   
  SET @v_max_printingnum = COALESCE(@v_max_printingnum,0)
    
  SELECT @v_next_printingnum = COALESCE(nextprintingnbr,@v_max_printingnum + 1,1),@v_book_title = title
    FROM book
   WHERE bookkey = @v_bookkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing printing info: bookkey = ' + cast(@v_bookkey AS VARCHAR)  
    RETURN 
  END     
  
  SET @v_printingnum_str = ' #' + cast(@v_next_printingnum as varchar)
  
  -- projectitle is varchar(255) - may need to chop off some of book title  
  IF len(@v_book_title) + len(@v_printingnum_str) > 255 BEGIN
    SET @v_book_title = substring(@v_book_title,1,(len(@v_book_title) - len(@v_printingnum_str)))
  END
  
  SET @v_printing_title = @v_book_title + @v_printingnum_str

  SELECT @v_book_title as 'booktitle', @v_next_printingnum as 'printingnum', @v_printing_title as 'projecttitle'

GO

GRANT EXEC ON qprinting_get_add_printing_info TO PUBLIC
GO


