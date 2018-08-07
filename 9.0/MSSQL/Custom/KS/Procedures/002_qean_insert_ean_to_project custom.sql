/****** Object:  StoredProcedure [dbo].[qean_insert_ean_to_project]    Script Date: 03/25/2009 17:19:49 ******/਍ഀ
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qean_insert_ean_to_project]') AND type in (N'P', N'PC'))਍ഀ
DROP PROCEDURE [dbo].[qean_insert_ean_to_project]਍ഀ
਍ഀ
਍ഀ
SET ANSI_NULLS ON਍ഀ
GO਍ഀ
SET QUOTED_IDENTIFIER ON਍ഀ
GO਍ഀ
਍ഀ
CREATE PROCEDURE [dbo].[qean_insert_ean_to_project]਍ഀ
  @i_projectkey INT,		਍ഀ
  @i_formatkey  INT,਍ഀ
  @i_isbn_prefix_code INT,਍ഀ
  @i_ean_prefix_code  INT, ਍ഀ
  @i_isbn_with_dashes VARCHAR(50),਍ഀ
  @i_ean_with_dashes  VARCHAR(50),਍ഀ
  @i_gtin_with_dashes VARCHAR(50),਍ഀ
  @o_error_code INT	OUTPUT,਍ഀ
  @o_error_desc VARCHAR(2000) OUTPUT਍ഀ
AS਍ഀ
਍ഀ
/* AK 05/10/05 Initial development਍ഀ
   Description: Procedure extract and insert ISBN numbers to taqprojecttitle table਍ഀ
*/਍ഀ
਍ഀ
DECLARE	਍ഀ
  @v_pos int,਍ഀ
  @isbn varchar(50),਍ഀ
  @ean varchar(50),਍ഀ
  @gtin varchar(50),਍ഀ
  @rowcount int,਍ഀ
  @i_bookkey int,਍ഀ
  @error  varchar(2000),਍ഀ
  @cnt int,਍ഀ
  @v_sqlstring  NVARCHAR(4000),਍ഀ
  @v_cur_itemnumber VARCHAR(20),਍ഀ
  @v_new_itemnumber VARCHAR(20)਍ഀ
਍ഀ
BEGIN਍ഀ
  SET @o_error_code = 0਍ഀ
  SET @o_error_desc = ''਍ഀ
  SET @v_cur_itemnumber = NULL਍ഀ
਍ഀ
  -- get @isbn, @ean, @gtin removing dashes਍ഀ
  select @isbn = replace(@i_isbn_with_dashes, '-', '')਍ഀ
  select @ean = replace(@i_ean_with_dashes, '-', '')਍ഀ
  select @gtin = replace(@i_gtin_with_dashes, '-', '')਍ഀ
਍ഀ
  -- Delete isbn from reuseisbns਍ഀ
  exec qean_remove_from_isbn_reuse @i_ean_with_dashes, @o_error_code output, @o_error_desc output਍ഀ
਍ഀ
  print @i_projectkey਍ഀ
  print @i_formatkey਍ഀ
  ਍ഀ
  -- When isbn values are being passed in, call the itemnumber generation procedure ਍ഀ
  -- which may generate a new itemnumber (based on Itemnumber Auto-Generated clientoption)਍ഀ
  IF @isbn IS NOT NULL  --at least ISBN has been passed in - generate new itemnumber਍ഀ
  BEGIN਍ഀ
਍ഀ
	select @i_bookkey = isnull(bookkey,0)਍ഀ
	from isbn਍ഀ
	where isbn10 = @isbn਍ഀ
਍ഀ
	if @i_bookkey > 0਍ഀ
		EXEC qean_generate_itemnumber 1, @i_bookkey, @v_new_itemnumber OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT਍ഀ
  END  ਍ഀ
਍ഀ
  --update or insert row਍ഀ
  select @cnt = count(*)਍ഀ
  from taqprojecttitle਍ഀ
  where taqprojectkey = @i_projectkey and਍ഀ
        taqprojectformatkey = @i_formatkey਍ഀ
਍ഀ
  --print 'count'਍ഀ
  --print @cnt਍ഀ
਍ഀ
  if @cnt > 0 begin਍ഀ
    --print 'updating'਍ഀ
    --print 'isbn:' + @i_isbn_with_dashes਍ഀ
    --print 'isbn10:' + @isbn਍ഀ
    --print 'ean13:' + @ean਍ഀ
    --print 'ean:' + @i_ean_with_dashes਍ഀ
    --print 'gtin:' + @i_gtin_with_dashes਍ഀ
    --print 'gtin14:' + @gtin਍ഀ
    --print 'isbnprefixcode:' + CAST(@i_isbn_prefix_code as varchar)਍ഀ
    --print 'eanprefixcode:' + CAST(@i_ean_prefix_code as varchar)਍ഀ
਍ഀ
    -- Check if itemnumber is currently populated for this isbn row਍ഀ
    SELECT @v_cur_itemnumber = itemnumber਍ഀ
    FROM taqprojecttitle਍ഀ
    WHERE taqprojectkey = @i_projectkey AND਍ഀ
        taqprojectformatkey = @i_formatkey਍ഀ
਍ഀ
    IF LTRIM(RTRIM(@v_cur_itemnumber)) = ''਍ഀ
      SET @v_cur_itemnumber = NULL਍ഀ
਍ഀ
    -- If new itemnumber was generated above and current itemnumber is null, ਍ഀ
    -- include the newly generated itemnumber in the UPDATE statement਍ഀ
    IF @v_cur_itemnumber IS NULL AND @v_new_itemnumber IS NOT NULL਍ഀ
      UPDATE taqprojecttitle਍ഀ
      SET isbn = @i_isbn_with_dashes, ਍ഀ
          isbn10 = @isbn,਍ഀ
          ean13 = @ean,਍ഀ
          ean = @i_ean_with_dashes,਍ഀ
          gtin = @i_gtin_with_dashes,਍ഀ
          gtin14 = @gtin,਍ഀ
          isbnprefixcode = @i_isbn_prefix_code,਍ഀ
          eanprefixcode = @i_ean_prefix_code,਍ഀ
          itemnumber = @v_new_itemnumber,਍ഀ
          lastuserid = suser_sname(),਍ഀ
          lastmaintdate = getdate()਍ഀ
      WHERE taqprojectkey = @i_projectkey AND਍ഀ
          taqprojectformatkey = @i_formatkey਍ഀ
    ELSE  ਍ഀ
      UPDATE taqprojecttitle਍ഀ
      SET isbn = @i_isbn_with_dashes, ਍ഀ
          isbn10 = @isbn,਍ഀ
          ean13 = @ean,਍ഀ
          ean = @i_ean_with_dashes,਍ഀ
          gtin = @i_gtin_with_dashes,਍ഀ
          gtin14 = @gtin,਍ഀ
          isbnprefixcode = @i_isbn_prefix_code,਍ഀ
          eanprefixcode = @i_ean_prefix_code,਍ഀ
          lastuserid = suser_sname(),਍ഀ
          lastmaintdate = getdate()਍ഀ
      WHERE taqprojectkey = @i_projectkey AND਍ഀ
          taqprojectformatkey = @i_formatkey਍ഀ
਍ഀ
    select @error = @@error਍ഀ
    if @error <> 0 begin਍ഀ
      select @o_error_code = @error਍ഀ
      select @o_error_desc = 'Could not update taqprojecttitle table.'਍ഀ
      return਍ഀ
    end਍ഀ
    ਍ഀ
  end  ਍ഀ
  else begin਍ഀ
    --print 'inserting'਍ഀ
    --insert new row in taqprojecttitle table਍ഀ
    insert into taqprojecttitle(isbn,taqprojectkey,taqprojectformatkey,਍ഀ
        isbnprefixcode,isbn10,lastuserid,lastmaintdate,਍ഀ
        ean,ean13,gtin,gtin14,itemnumber)਍ഀ
    values(@i_isbn_with_dashes,@i_projectkey,@i_formatkey,਍ഀ
        @i_isbn_prefix_code,@isbn,suser_sname(),getdate(),਍ഀ
        @i_ean_with_dashes,@ean,@i_gtin_with_dashes,@gtin,@v_new_itemnumber)਍ഀ
਍ഀ
    select @error = @@error਍ഀ
    if @error <> 0 begin਍ഀ
      select @o_error_code = @error਍ഀ
      select @o_error_desc = 'Could not insert into taqprojecttitle table.'਍ഀ
      return਍ഀ
    end਍ഀ
  end਍ഀ
  ਍ഀ
  ਍ഀ
  /*** If new itemnumber was generated above, call the cleanup stored procedure ***/਍ഀ
  /*** that will update itemnumber numeric and/or alpha sequence ***/਍ഀ
  IF @v_cur_itemnumber IS NULL AND @v_new_itemnumber IS NOT NULL਍ഀ
  BEGIN਍ഀ
    EXEC qean_after_itemnumber_update @v_new_itemnumber, @o_error_code OUTPUT, @o_error_desc OUTPUT਍ഀ
  END਍ഀ
  ਍ഀ
    ਍ഀ
END਍ഀ
