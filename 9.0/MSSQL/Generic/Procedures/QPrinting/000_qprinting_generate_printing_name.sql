if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_generate_printing_name') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qprinting_generate_printing_name
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qprinting_generate_printing_name
 (@i_printing_projectkey     integer,
  @i_bookkey                 integer,
  @i_printingnum             integer,
  @o_projectitle             varchar(255)  output,
  @o_error_code              integer       output,
  @o_error_desc              varchar(2000) output)
AS

/******************************************************************************
**  Name: qprinting_generate_printing_name
**  Desc: This procedure will generate the printing project title
**        NOTE: If printingnum is passed in, then it will be used in the title
**              Otherwise, book.nextprintingnbr will be used 
**
**    Auth: Alan Katzen
**    Date: Sept 16 2014
*******************************************************************************/

  DECLARE 
    @error_var             INT,
    @rowcount_var          INT,
    @v_count               INT,
    @v_bookkey             INT,
    @v_printing_projectkey INT,
    @v_book_title          VARCHAR(255),
    @v_max_printingnum     INT,
    @v_printingnum         INT,
    @v_printingnum_str     VARCHAR(50),
    @v_printing_title      VARCHAR(255)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_projectitle = ''
  
  SET @v_bookkey = COALESCE(@i_bookkey,0)
  SET @v_printing_projectkey = COALESCE(@i_printing_projectkey,0) 
  SET @v_printingnum = COALESCE(@i_printingnum,0)

  IF @v_bookkey = 0 AND @v_printing_projectkey > 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error generating printing name.  Must pass in printing projectkey or bookkey.'  
    RETURN 
  END  
  
  IF @v_bookkey = 0 AND @v_printing_projectkey > 0 BEGIN
    -- get the bookkey from taqprojectprinting_view
    SELECT @v_count = count(*)
      FROM taqprojectprinting_view
     WHERE taqprojectkey = @v_printing_projectkey
     
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error generating printing name: taqprojectkey = ' + cast(@v_printing_projectkey AS VARCHAR)  
      RETURN 
    END 
    
    IF @v_count = 0 BEGIN
      SET @o_projectitle = 'No Related Title'
      RETURN
    END
    
    SELECT @v_bookkey = bookkey
      FROM taqprojectprinting_view
     WHERE taqprojectkey = @v_printing_projectkey
     
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error generating printing name: taqprojectkey = ' + cast(@v_printing_projectkey AS VARCHAR)  
      RETURN 
    END     
  END
  
  IF COALESCE(@v_bookkey,0) = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error generating printing name (bookkey is 0): taqprojectkey = ' + cast(@v_printing_projectkey AS VARCHAR)  
    RETURN 
  END
  
  SELECT @v_book_title = title
    FROM book
   WHERE bookkey = @v_bookkey
  
  IF COALESCE(@v_book_title,'') = '' BEGIN
    SET @o_projectitle = 'No Related Title'
    RETURN
  END

  IF @v_printingnum = 0 BEGIN
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
  
    SELECT @v_printingnum = COALESCE(nextprintingnbr,@v_max_printingnum + 1,1)
      FROM book
     WHERE bookkey = @v_bookkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error generating printing name(nextprintingnbr): bookkey = ' + cast(@v_printing_projectkey AS VARCHAR)  
      RETURN 
    END     
  END
  
  SET @v_printingnum_str = ' #' + cast(@v_printingnum as varchar)
  
  -- projectitle is varchar(255) - may need to chop off some of book title  
  IF len(@v_book_title) + len(@v_printingnum_str) > 255 BEGIN
    SET @v_book_title = substring(@v_book_title,1,(len(@v_book_title) - len(@v_printingnum_str)))
  END
  
  SET @o_projectitle = @v_book_title + @v_printingnum_str
  RETURN
  
GO
GRANT EXEC ON qprinting_generate_printing_name TO PUBLIC
GO


