SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_reuse_ean')
  BEGIN   
    print 'Dropping dbo.qean_reuse_ean'
    DROP PROCEDURE  dbo.qean_reuse_ean
  END
GO


--print 'Creating dbo.qean_reuse_ean'
CREATE PROCEDURE dbo.qean_reuse_ean
	@ean_prefix_code   int, 
	@isbn_prefix_code  int,
	@ean_with_dashes   varchar(50),
	@o_error_code      int	output,
	@o_error_desc      varchar(2000) output
AS

DECLARE	
@v_pos int,
@isbn varchar(50),
@ean varchar(50),
@isbn_with_dashes varchar(50),
@gtin_with_dashes varchar(50),
@gtin varchar(50),
@rowcount int,
@error  varchar(2000),
@cnt int,
@isbn_prefix_end    int,
@ean_prefix varchar(3),
@isbn_prefix varchar(10),
@isbn_no_checksum varchar(12),
@isbn_checksum varchar(1)

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  if (@ean_prefix_code is null or @ean_prefix_code = 0)
  BEGIN
    --print 'Finding ean prefix code'
    SET @ean_prefix = SUBSTRING(@ean_with_dashes, 1, 3)
    SELECT @ean_prefix_code=datacode from gentables where tableid = 138 and datadesc = @ean_prefix
  END

  if (@ean_prefix_code is null )
  BEGIN
    SET @ean_prefix_code = 0
  END

  if (@isbn_prefix_code is null or @isbn_prefix_code = 0)
  BEGIN
    --print 'Finding "ISBN" prefix code'
    SET @isbn_prefix_end = CHARINDEX('-', @ean_with_dashes, 5)
    --print @isbn_prefix_end
    SET @isbn_prefix_end = CHARINDEX('-', @ean_with_dashes, @isbn_prefix_end+1)
    --print @isbn_prefix_end
    SET @isbn_prefix = SUBSTRING(@ean_with_dashes, 5, @isbn_prefix_end-5)
    --print @isbn_prefix
    SELECT @isbn_prefix_code=datasubcode from subgentables where tableid = 138 and datadesc = @isbn_prefix
  END

  if (@isbn_prefix_code is null)
  BEGIN
    SET @isbn_prefix_code = 0
  END


  -- Final codes
  --print @ean_prefix_code
  --print @isbn_prefix_code

  if (@ean_prefix_code != 0 and @isbn_prefix_code != 0)
 
  BEGIN
    -- Generate ISBN/GTIN FROM EAN.
    SET @gtin_with_dashes = '0-' + @ean_with_dashes;
    SET @isbn_no_checksum = SUBSTRING(@ean_with_dashes, 5, 12)
    --print 'ISBN No Checksum'
    --print @isbn_no_checksum
    exec dbo.qean_generate_check_digit @isbn_no_checksum, @isbn_checksum output, 0 
    --print 'checksum'
    --print @isbn_checksum
    SET @isbn_with_dashes = @isbn_no_checksum + @isbn_checksum 
    
    -- get @isbn, @ean, @gtin removing dashes
    SET @isbn = replace(@isbn_with_dashes, '-', '')
    SET @ean = replace(@ean_with_dashes, '-', '')
    SET @gtin = replace(@gtin_with_dashes, '-', '')

    --print @ean_with_dashes
    --print @isbn_with_dashes
    --print @gtin_with_dashes
    --print @ean
    --print @isbn
    --print @gtin

    
    insert reuseisbns (isbnprefixcode, isbnsubprefixcode, isbn, ean, gtin, locked, lastuserid, lastmaintdate ) 
      values (@ean_prefix_code, @isbn_prefix_code, @isbn_with_dashes, @ean_with_dashes, @gtin_with_dashes, 'N',  'REUSEEAN', getdate())
    

  END
  ELSE
  BEGIN
   SET @o_error_code = 1
   SET @o_error_desc = 'Data codes cannot be matched to valid gentable entries for tableid = 138.'
  END

END
   

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on dbo.qean_reuse_ean  to public
go