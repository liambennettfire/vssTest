SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_remove_from_isbn_reuse')
BEGIN
  DROP PROCEDURE  qean_remove_from_isbn_reuse
END
GO

CREATE PROCEDURE dbo.qean_remove_from_isbn_reuse
  @ean_with_dashes  varchar(50),
  @o_error_code      int	output,
  @o_error_desc      varchar(2000) output
AS

DECLARE	
  @error int,
  @rowcount int
	 
BEGIN

  -- Delete isbn from reuseisbns
  delete reuseisbns
  where ean = @ean_with_dashes
  
  select @error = @@error
  if @error <> 0 begin
    select @o_error_code = @error
    select @o_error_desc = 'Could not delete from reuseisbns table (ean=' + @ean_with_dashes + ').'
  end
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qean_remove_from_isbn_reuse  to public
go
