SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_insert_ean_to_project')
BEGIN
  DROP PROCEDURE  qean_insert_ean_to_project
END
GO

CREATE PROCEDURE dbo.qean_insert_ean_to_project
  @i_projectkey INT,		
  @i_formatkey  INT,
  @i_isbn_prefix_code INT,
  @i_ean_prefix_code  INT, 
  @i_isbn_with_dashes VARCHAR(50),
  @i_ean_with_dashes  VARCHAR(50),
  @i_gtin_with_dashes VARCHAR(50),
  @i_itemnumber       VARCHAR(50),
  @i_itemnumbergen    TINYINT,  
  @o_error_code INT	OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
AS

/*************************************************************************************************************
**  Name: qean_insert_ean
**  Desc: Inserts/Updates to taqprojecttitle table with the passed standard Product ID values (EAN,ISBN,GTIN)
**        as well as all newly auto-generated non-standard Product IDs (currently itemnumber only).
**
**  AK 05/10/05 Initial development
**  
**************************************************************************************
**	Change History
**************************************************************************************
**  Date	    Author  Description
**	--------	------	-----------
**  08/21/15  KW      Added itemnumber input parameter - see case 33163
**  05/02/17  Colman  44815 - generating duplicate item numbers
*************************************************************************************************************/

DECLARE	
  @isbn varchar(50),
  @ean varchar(50),
  @gtin varchar(50),
  @error  varchar(2000),
  @cnt int,
  @v_sqlstring  NVARCHAR(4000),
  @v_new_itemnumber VARCHAR(20),
  @v_lastuserid VARCHAR(50)

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_new_itemnumber = @i_itemnumber
  SET @v_lastuserid = (select lastuserid from keys)

  -- get @isbn, @ean, @gtin removing dashes
  select @isbn = replace(@i_isbn_with_dashes, '-', '')
  select @ean = replace(@i_ean_with_dashes, '-', '')
  select @gtin = replace(@i_gtin_with_dashes, '-', '')

  -- Delete isbn from reuseisbns
  exec qean_remove_from_isbn_reuse @i_ean_with_dashes, @o_error_code output, @o_error_desc output

  --print @i_projectkey
  --print @i_formatkey

  --update or insert row
  select @cnt = count(*)
  from taqprojecttitle
  where taqprojectkey = @i_projectkey and
        taqprojectformatkey = @i_formatkey

  --print 'count'
  --print @cnt

  if @cnt > 0 begin
    --print 'updating'
    --print 'isbn:' + @i_isbn_with_dashes
    --print 'isbn10:' + @isbn
    --print 'ean13:' + @ean
    --print 'ean:' + @i_ean_with_dashes
    --print 'gtin:' + @i_gtin_with_dashes
    --print 'gtin14:' + @gtin
    --print 'isbnprefixcode:' + CAST(@i_isbn_prefix_code as varchar)
    --print 'eanprefixcode:' + CAST(@i_ean_prefix_code as varchar)

    IF @i_isbn_prefix_code > 0 
      UPDATE taqprojecttitle
      SET isbn = @i_isbn_with_dashes, 
          isbn10 = @isbn,
          ean13 = @ean,
          ean = @i_ean_with_dashes,
          gtin = @i_gtin_with_dashes,
          gtin14 = @gtin,
          isbnprefixcode = @i_isbn_prefix_code,
          eanprefixcode = @i_ean_prefix_code,
          itemnumber = @v_new_itemnumber,
          lastuserid = @v_lastuserid,
          lastmaintdate = getdate()
      WHERE taqprojectkey = @i_projectkey AND
          taqprojectformatkey = @i_formatkey
    ELSE  
      UPDATE taqprojecttitle
      SET itemnumber = @v_new_itemnumber,
          lastuserid = @v_lastuserid,
          lastmaintdate = getdate()
      WHERE taqprojectkey = @i_projectkey AND
          taqprojectformatkey = @i_formatkey

    select @error = @@error
    if @error <> 0 begin
      select @o_error_code = @error
      select @o_error_desc = 'Could not update taqprojecttitle table.'
      return
    end
    
  end  
  else begin
    --print 'inserting'
    
    IF @i_isbn_prefix_code > 0
      insert into taqprojecttitle
        (taqprojectformatkey, taqprojectkey, eanprefixcode, isbnprefixcode, 
        isbn, isbn10, ean, ean13, gtin, gtin14, itemnumber, lastuserid, lastmaintdate)
		  values
        (@i_formatkey, @i_projectkey, @i_ean_prefix_code, @i_isbn_prefix_code,
        @i_isbn_with_dashes, @isbn, @i_ean_with_dashes, @ean, @i_gtin_with_dashes, @gtin, @v_new_itemnumber, @v_lastuserid, getdate())
    ELSE
      insert into taqprojecttitle
        (taqprojectformatkey, taqprojectkey, itemnumber, lastuserid, lastmaintdate)
		  values
        (@i_formatkey, @i_projectkey, @v_new_itemnumber, @v_lastuserid, getdate())

    select @error = @@error
    if @error <> 0 begin
      select @o_error_code = @error
      select @o_error_desc = 'Could not insert into taqprojecttitle table.'
      return
    end
  end
  
  -- NOTE: this happens in qean_generate_itemnumber now as soon as the itemnumber is generated
  -- If the new itemnumber was generated, call the cleanup stored procedure that will update itemnumber numeric and/or alpha sequence
  -- IF @v_new_itemnumber IS NOT NULL AND @i_itemnumbergen = 1
  -- BEGIN
    -- EXEC qean_after_itemnumber_update @v_new_itemnumber, @o_error_code OUTPUT, @o_error_desc OUTPUT
  -- END  
    
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qean_insert_ean_to_project  to public
go
