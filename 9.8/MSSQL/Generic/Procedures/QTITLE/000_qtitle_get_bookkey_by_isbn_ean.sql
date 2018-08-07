if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_bookkey_by_isbn_ean') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_bookkey_by_isbn_ean
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_bookkey_by_isbn_ean
 (@i_isbn_ean       varchar(20),
  @o_bookkey        integer output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_bookkey_by_isbn_ean
**  Desc: This stored procedure returns the bookkey for a given isbn or ean.
**        NOTE: this proc will accept isbn or ean with or without hyphens.
**              if hyphens are included, then all hyphens are expected.
**
**    Auth: Alan Katzen
**    Date: 31 July 2009
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_bookkey = 0
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_isbn_ean varchar(20),
          @v_bookkey INT,
          @v_workkey INT

  set @v_isbn_ean = rtrim(ltrim(@i_isbn_ean))
  set @v_bookkey = 0
  
  if len(@v_isbn_ean) = 17 begin
    -- ean with hyphens
    SELECT @v_bookkey = bookkey
      FROM isbn
     WHERE ean = @v_isbn_ean
  end
  else if len(@v_isbn_ean) = 10 begin
    -- isbn with no hyphens
    SELECT @v_bookkey = bookkey
      FROM isbn
     WHERE isbn10 = @v_isbn_ean
  end
  else if len(@v_isbn_ean) = 13 begin
    if charindex('-',@v_isbn_ean) > 0 begin
      -- isbn with hyphens
      SELECT @v_bookkey = bookkey
        FROM isbn
       WHERE isbn = @v_isbn_ean
    end
    else begin
      -- ean with no hyphens
      SELECT @v_bookkey = bookkey
        FROM isbn
       WHERE ean13 = @v_isbn_ean
    end
  end
  else begin
    SET @o_error_code = -1
    SET @o_error_desc = 'No title found - Invalid EAN/ISBN (' + @v_isbn_ean + ')'
    SET @o_bookkey = 0    
    return
  end

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    IF @rowcount_var = 0 BEGIN
      SET @o_error_code = 0
    END
    ELSE BEGIN
      SET @o_error_code = -1
    END
            
    SET @o_error_desc = 'No title found with EAN/ISBN of ' + @v_isbn_ean
    SET @o_bookkey = 0    
    return
  END 

  IF @v_bookkey > 0 BEGIN
    -- make sure this is a primary title
    SELECT @v_workkey = COALESCE(workkey,0)
      FROM book
     WHERE bookkey = @v_bookkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 or @rowcount_var = 0 BEGIN
      IF @rowcount_var = 0 BEGIN
        SET @o_error_code = 0
      END
      ELSE BEGIN
        SET @o_error_code = -1
      END
              
      SET @o_error_desc = 'Primary title verification failed (' + @v_isbn_ean + ')'
      SET @o_bookkey = 0    
      return
    END 

    IF @v_bookkey <> @v_workkey BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = @v_isbn_ean + ' is not a Primary Title'
      SET @o_bookkey = 0    
      return
    END
  
    SET @o_bookkey = @v_bookkey
    SET @o_error_code = 1
    SET @o_error_desc = ''
    return
  END
  
GO
GRANT EXEC ON qtitle_get_bookkey_by_isbn_ean TO PUBLIC
GO



