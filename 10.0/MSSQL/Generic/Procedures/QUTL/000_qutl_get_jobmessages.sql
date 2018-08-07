SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_jobmessages')
BEGIN
  PRINT 'Dropping Procedure qutl_get_jobmessages'
  DROP  Procedure  qutl_get_jobmessages
END
GO

PRINT 'Creating Procedure qutl_get_jobmessages'
GO

CREATE PROCEDURE dbo.qutl_get_jobmessages
  @ean_with_dashes   varchar(50),
  @o_error_code      int	output,
  @o_error_desc      varchar(2000) output
AS

DECLARE
  @error int
	 
BEGIN

  SET @o_error_code = 0
  SET @o_error_code = ''

  -- get the job messages
  SELECT * from jobmessages_view WHERE bookkey = (SELECT bookkey FROM coretitleinfo WHERE LTRIM(RTRIM(ean)) = LTRIM(RTRIM(@ean_with_dashes)) AND printingkey = 1)
  
  select @error = @@error
  if @error <> 0 begin
    select @o_error_code = @error
    select @o_error_desc = 'Could not select from jobmessages_view view.'
  end
  
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON dbo.qutl_get_jobmessages TO PUBLIC
GO
