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
**  Name: qean_after_itemnumber_update  (for ISLAND PRESS only)
**  Desc: Updates itemnumber sequence on defaults table after the passed itemnumber 
**        has been assigned to a title/project.
**
**  Auth: Kate J. Wiewiora
**  Date: 15 January 2007
******************************************************************************************/

DECLARE
  @v_current_alpha  CHAR(1),
  @v_error  INT,
  @v_new_alpha  CHAR(1),
  @v_new_sequence INT,
  @v_rowcount INT,
  @v_tempstring VARCHAR(255)
  
BEGIN
 
  /**** For ISLAND PRESS, itemnumber is a custom Accounting Code: ***/
  /**** Digit 9, alpha character, followed by 3-digit sequence.   ***/
  
  -- Parse out alpha and numeric sequence  
  SET @v_tempstring = SUBSTRING(@i_itemnumber, 3, 10)
  SET @v_new_sequence = CONVERT(INT, @v_tempstring)  
  SET @v_new_alpha = SUBSTRING(@i_itemnumber, 2, 1)
  
  -- Update new itemnumber sequence number on defaults table
  UPDATE defaults
  SET itemnumberseq = @v_new_sequence
    
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Could not update itemnumber sequence on defaults table.'
    RETURN
  END
  
  /* Get the current alpha character from clientdefaults (clientdefaultid=10) */
  SELECT @v_tempstring = stringvalue
  FROM clientdefaults
  WHERE clientdefaultid = 10
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Could not access clientdefaults table to get current alpha sequence.'
    RETURN
  END
  
  IF @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Record missing on clientdefaults table (clientdefaultid=10).' 
    RETURN
  END    

  /* Alpha sequence (stringvalue on clientdefaults) should be a single character */
  SET @v_current_alpha = LTRIM(RTRIM(@v_tempstring))
  
  /* Update alpha sequence on clientdefaults table if necessary */
  IF @v_current_alpha <> @v_new_alpha
  BEGIN
    UPDATE clientdefaults
    SET stringvalue = @v_new_alpha
    WHERE clientdefaultid = 10

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0
    BEGIN
      SET @o_error_code = -1 
      SET @o_error_desc = 'Could not update alpha sequence on clientdefaults table (clientdefaultid=10).'
      RETURN
    END
  END

END
GO

GRANT EXEC ON dbo.qean_after_itemnumber_update TO PUBLIC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
