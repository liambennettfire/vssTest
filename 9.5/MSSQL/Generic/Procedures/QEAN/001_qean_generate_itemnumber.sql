SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_generate_itemnumber')
  BEGIN
    DROP PROCEDURE qean_generate_itemnumber
  END
GO

CREATE PROCEDURE dbo.qean_generate_itemnumber
  @o_new_itemnumber     VARCHAR(20) OUTPUT,
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
**  Name: qean_generate_itemnumber
**  Desc: Generates itemnumber based on defaults.itemnumberseq.
**
**  Auth: Kate J. Wiewiora
**  Date: 12 January 2007
******************************************************************************************/

-- DOIT_AGAIN Label:
-- When the generated itemnumber already exists (was entered manually elsewhere), 
-- this procedure will get executed again to try to generate new itemnumber.
DOIT_AGAIN:

DECLARE
  @v_count  INT,
  @v_error  INT,
  @v_itemnumber_sequence INT,
  @v_new_itemnumber VARCHAR(20),
  @v_rowcount INT

BEGIN
 
  SET @o_new_itemnumber = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  /* Get the last itemnumber sequence used */
  SELECT @v_itemnumber_sequence = itemnumberseq 
  FROM defaults

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Could not access defaults table to get last itemnumber sequence.'
    RETURN
  END

  IF @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Record missing on defaults table.' 
    RETURN
  END

  IF @v_itemnumber_sequence IS NULL
    SET @v_itemnumber_sequence = 0
  
  /* Generate new itemnumber */
  SET @v_itemnumber_sequence = @v_itemnumber_sequence + 1
  SET @v_new_itemnumber = CONVERT(VARCHAR, @v_itemnumber_sequence)
    
  /* Check if this itemnumber already exists */
  SELECT @v_count = COUNT(*)
  FROM isbn
  WHERE UPPER(LTRIM(RTRIM(itemnumber))) = UPPER(LTRIM(RTRIM(@v_new_itemnumber)))

  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Could not access isbn table to verify uniqueness of itemnumber.'
    RETURN
  END

  IF @v_count > 0  --this itemnumber already exists
  BEGIN
    -- Update this sequence number on defaults table - for DOIT_AGAIN next select
    EXEC qean_after_itemnumber_update @v_new_itemnumber, @o_error_code OUTPUT, @o_error_desc OUTPUT
  
    -- Call itself again to generate another itemnumber
    GOTO DOIT_AGAIN
  END
      
  SET @o_new_itemnumber = @v_new_itemnumber    
     
END
GO

GRANT EXEC ON dbo.qean_generate_itemnumber TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
