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
**  Name: qean_generate_itemnumber (for ISLAND PRESS only)
**  Desc: Generates itemnumber based on defaults.itemnumberseq if the clientoption
**        for itemnumber auto-generation is turned ON.
**
**  Auth: Kate J. Wiewiora
**  Date: 12 January 2007
******************************************************************************************/

-- DOIT_AGAIN Label:
-- When the generated itemnumber already exists (was entered manually elsewhere), 
-- this procedure will get executed again to try to generate new itemnumber.
DOIT_AGAIN:

DECLARE
  @v_ascii_alpha  INT,
  @v_ascii_a  INT,
  @v_ascii_z  INT,
  @v_count  INT,
  @v_error  INT,
  @v_itemnumber_alpha CHAR(1),
  @v_itemnumber_sequence INT,
  @v_new_alpha  CHAR(1),
  @v_new_itemnumber VARCHAR(20),
  @v_rowcount INT,
  @v_string_length  INT,
  @v_tempstring VARCHAR(255)

BEGIN
 
  SET @o_new_itemnumber = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  SET @v_ascii_a = ASCII('A')
  SET @v_ascii_z = ASCII('Z')
  
  /* Get the last itemnumber sequence used */
  SELECT @v_itemnumber_sequence = itemnumberseq 
  FROM defaults;

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
    
    
  /**** CUSTOM CODE FOR ISLAND PRESS ****/
  /**** For Island Press, itemnumber is a custom Accounting Code: ***/
  /**** Digit 9, alpha character, followed by 3-digit sequence.   ***/
    
  /* Get the current alpha character from clientdefaults (clientdefaultid=10) */
  SELECT @v_tempstring = stringvalue
  FROM clientdefaults
  WHERE clientdefaultid = 10
    
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Could not access clientdefaults table to get alpha sequence.'
    RETURN
  END
    
  IF @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Record missing on clientdefaults table (clientdefaultid=10).' 
    RETURN
  END    

  /* Alpha sequence (stringvalue on clientdefaults) should be a single character */
  SET @v_itemnumber_alpha = LTRIM(RTRIM(@v_tempstring))
    
  /* Get the ASCII equivalent of the current alpha sequence */
  SET @v_ascii_alpha = ASCII(@v_itemnumber_alpha)
    
  IF LEN(@v_tempstring) > 1 OR @v_ascii_alpha < @v_ascii_a OR @v_ascii_alpha > @v_ascii_z
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Itemnumber Alpha character is invalid on clientdefaults table (clientdefaultid=10).' 
    RETURN
  END
        
  /* If the current numeric sequence is 999, use 1 and next alpha sequence. */
  /* Otherwise, use current alpha and increment the numeric sequence. */
  IF @v_itemnumber_sequence = 999
    BEGIN
      SET @v_itemnumber_sequence = 1
      /* If the current alpha sequence is Z, start again from A. */
      /* Otherwise, just increment the alpha sequence to next letter. */
      IF @v_ascii_alpha = @v_ascii_z
        SET @v_new_alpha = @v_ascii_a
      ELSE
        SET @v_new_alpha = CHAR(@v_ascii_alpha + 1)
    END
  ELSE
    BEGIN
      SET @v_itemnumber_sequence = @v_itemnumber_sequence + 1
      SET @v_new_alpha = @v_itemnumber_alpha
    END
    
  /* Pad the numeric sequence with leading zeros to form a 3-character string */
  SET @v_tempstring = CONVERT(VARCHAR, @v_itemnumber_sequence)
  SET @v_string_length = LEN(@v_tempstring)
  IF @v_string_length < 3
  BEGIN
    SET @v_tempstring = SPACE(3 - @v_string_length) + @v_tempstring
    SET @v_tempstring = REPLACE(@v_tempstring, ' ', '0')
  END 
    
  /* Generate new itemnumber */
  SET @v_new_itemnumber = CONVERT(VARCHAR, @v_tempstring)
  SET @v_new_itemnumber = '9' + @v_new_alpha + @v_new_itemnumber
        
  /***** END CUSTOM CODE FOR ISLAND PRESS *****/

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
    EXEC qean_after_itemnumber_update @v_new_itemnumber, 
      @o_error_code OUTPUT, @o_error_desc OUTPUT
      
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
