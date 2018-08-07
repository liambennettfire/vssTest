SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_after_itemnumber_update')
  BEGIN
    DROP PROCEDURE qean_after_itemnumber_update
  END
GO

CREATE PROCEDURE dbo.qean_after_itemnumber_update
  @i_itemnumber   VARCHAR(20),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
**  Name: qean_after_itemnumber_update
**  Desc: Updates itemnumber sequence on defaults table after the passed itemnumber 
**        has been assigned to a title/project.
**
**  Auth: Kate J. Wiewiora
**  Date: 15 January 2007
******************************************************************************************/

DECLARE
  @v_itemnumber_sequence  INT,
  @v_error  INT
  
BEGIN
 
  SET @v_itemnumber_sequence = CONVERT(INT, @i_itemnumber)
       
  UPDATE defaults
  SET itemnumberseq = @v_itemnumber_sequence
    
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Could not update itemnumber sequence on defaults table.'
    RETURN
  END
  
END
GO

GRANT EXEC ON dbo.qean_after_itemnumber_update TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
