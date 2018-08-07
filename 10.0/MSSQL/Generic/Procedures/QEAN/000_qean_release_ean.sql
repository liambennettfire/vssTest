SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_release_ean')
BEGIN
  PRINT 'Dropping Procedure qean_release_ean'
  DROP  Procedure  qean_release_ean
END
GO

PRINT 'Creating Procedure qean_release_ean'
GO

CREATE PROCEDURE dbo.qean_release_ean
  @ean_with_dashes   varchar(50),
  @o_error_code      int	output,
  @o_error_desc      varchar(2000) output
AS

/* AH 08/02/04 Innitial development
   Description: update release_reuseisbns table and set locked indicator
		to 'N' if user press cancel so isbn can be used by other users
*/

DECLARE
  @error int
	 
BEGIN

  SET @o_error_code = 0
  SET @o_error_code = ''

  -- Unlock this number
  update reuseisbns
  set locked = 'N', lastuserid = suser_sname(),lastmaintdate = getdate()
  where REPLACE(ean, '-', '') = REPLACE(@ean_with_dashes, '-', '')
  
  select @error = @@error
  if @error <> 0 begin
    select @o_error_code = @error
    select @o_error_desc = 'Could not update reuseisbns table.'
  end
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON dbo.qean_release_ean TO PUBLIC
GO
