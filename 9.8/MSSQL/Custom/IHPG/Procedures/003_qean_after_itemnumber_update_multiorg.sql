
/****** Object:  StoredProcedure [dbo].[qean_after_itemnumber_update_multiorg]    Script Date: 12/09/2014 15:58:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qean_after_itemnumber_update_multiorg]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qean_after_itemnumber_update_multiorg]
GO



/****** Object:  StoredProcedure [dbo].[qean_after_itemnumber_update_multiorg]    Script Date: 12/09/2014 15:58:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qean_after_itemnumber_update_multiorg] 
	--Added @i_check_orEntryKey for validation on lastseqnumber table
  @i_check_orgEntryKey	INT,
  @i_itemnumber   VARCHAR(20),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
**  Name: qean_after_itemnumber_update_multiorg
**  Desc: Updates itemnumber sequence on lastseqnumber table after the passed itemnumber 
**        has been assigned to a title/project.
**
**  Auth: Kate J. Wiewiora
**  Date: 15 January 2007
**  Modified by: Bill Adams
**  Date: 6 December 2014
******************************************************************************************/

DECLARE
  @v_orgentrykey_holder INT,
  @v_itemnumber_sequence  INT,
  @v_error  INT
  
BEGIN

  SET @v_orgentrykey_holder = @i_check_orgEntryKey
  SET @v_itemnumber_sequence = CONVERT(INT, @i_itemnumber)
       
  UPDATE lastseqnumber
  SET itemnumberseq = @v_itemnumber_sequence
  WHERE orgentrykey = @v_orgentrykey_holder;
    
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'Could not update itemnumber sequence on defaults table.'
    RETURN
  END
  
END


GO


GRANT ALL ON qean_after_itemnumber_update_multiorg TO PUBLIC