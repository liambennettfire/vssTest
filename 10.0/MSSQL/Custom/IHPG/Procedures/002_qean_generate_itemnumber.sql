
/****** Object:  StoredProcedure [dbo].[qean_generate_itemnumber]    Script Date: 12/09/2014 15:56:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qean_generate_itemnumber]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qean_generate_itemnumber]
GO



/****** Object:  StoredProcedure [dbo].[qean_generate_itemnumber]    Script Date: 12/09/2014 15:56:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[qean_generate_itemnumber]
  /* added input of current orgnumber */
  @i_check_orgEntryKey	INT,
  @o_new_itemnumber     VARCHAR(20) OUTPUT,
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT
AS
/*********************************************************************************************
**  Name: qean_generate_itemnumber
**  Desc: Generates itemnumber based on lastseqnumber.itemnumberseq, where the orgainization
**  is valid and itemnumber set is predefined in altdesc2.orgentry altpodesc.orgentry if the clientoption
**  for itemnumber auto-generation is turned ON.
**
**  Auth: Bill Adams
**  Date: 5 December 2014
******************************************************************************************/

/* DOIT_AGAIN Label:
   When the generated itemnumber already exists (was entered manually elsewhere), 
   this procedure will get executed again to try to generate new itemnumber. */
DOIT_AGAIN:

DECLARE
  @v_count  INT,
  @v_error  INT,
  @v_itemnumber_sequence INT,
  @v_generate_new INT,
  @v_new_itemnumber VARCHAR(20),
  @v_rowcount INT,
  /* added variable for the lowest possible item number */
  @v_lowestId varchar(20),
  /* added variable for the lowest possible item number */
  @v_highestId varchar(20),
  @v_orgentrykey_holder INT

-------------------------------

BEGIN
 
  SET @o_new_itemnumber = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''

  /* Assume that new itemnumber will be generated - default to 1 */
  SET @v_generate_new = 1
  SET @v_orgentrykey_holder = @i_check_orgEntryKey
    
  /* Select rows that as long as both altpodesc.orgentry and altdesc2.orgentry have a value and if
  the org matches, then validate if any rows are returned, end if no rows return */
  SELECT * 
  FROM orgentry 
  WHERE altdesc2 IS NOT NULL AND altpodesc IS NOT NULL AND orgentrykey = @v_orgentrykey_holder
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1 
    SET @o_error_desc = 'The Current Organization has no pre-defined Itemnumbers.'
    RETURN
  END

  IF @v_rowcount = 0
    SET @v_generate_new = 0 
  
  /* if @v_generate_new = 1 then enter in the final begin group to update itemnumber */
  IF @v_generate_new = 1
  BEGIN
    /* Get the lowest possible itemnumber in range */
    SELECT @v_lowestId = CAST((altdesc2 + '' + LEFT(altpodesc,4)) AS varchar(20))
    FROM dbo.orgentry 
    WHERE orglevelkey = 2 AND orgentrykey = @v_orgentrykey_holder AND altpodesc IS NOT NULL
  
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0
    BEGIN
      SET @o_error_code = -1 
      SET @o_error_desc = 'Could not access orgentry table to get lowest itemnumber.'
      RETURN
    END
    
    IF @v_rowcount = 0
    BEGIN
      SET @o_error_code = -1 
      SET @o_error_desc = 'Record missing on orgentry table.' 
      RETURN
    END
    
    PRINT @v_lowestId
 
    /* Get the highest possible itemnumber in range */
    SELECT @v_highestId = CAST((altdesc2 + '' + RIGHT(altpodesc,4)) AS varchar(20))
    from dbo.orgentry 
    where orglevelkey = 2 AND orgentrykey = @v_orgentrykey_holder AND altpodesc IS NOT NULL
  
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0
    BEGIN
      SET @o_error_code = -1 
      SET @o_error_desc = 'Could not access orgentry table to get highest itemnumber.'
      RETURN
    END
    
    IF @v_rowcount = 0
    BEGIN
      SET @o_error_code = -1 
      SET @o_error_desc = 'Record missing on orgentry table.' 
      RETURN
    END
    
    PRINT @v_highestId
       
    /* load local variable @v_itemnumber_sequence from itemnumberseq where the orgentrykey matches */
    SELECT @v_itemnumber_sequence = itemnumberseq 
    FROM lastseqnumber
    WHERE orgentrykey = @v_orgentrykey_holder
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0
    BEGIN
      SET @o_error_code = -1 
      SET @o_error_desc = 'Could not access lastseqnumber table to get last itemnumber sequence.'
      RETURN
    END
    
    IF @v_rowcount = 0
    BEGIN
      SET @o_error_code = -1 
      SET @o_error_desc = 'Record missing on lastseqnumber table for orgentrykey=' + CONVERT(VARCHAR, @v_orgentrykey_holder) + '.' 
      RETURN
    END
	
    PRINT @v_itemnumber_sequence	
	
    
    /* check for null itemnumber or lower itemnumber than lowest number on defined scale of itemnumbers 
       IF TRUE it will also update the dbo.itemseqnumber table with the lowest possible number
       The minus one takes into account the iteration of the number at the end of this procedure*/    
    IF @v_itemnumber_sequence IS NULL OR @v_itemnumber_sequence < @v_lowestId
      BEGIN
      SET @v_itemnumber_sequence = @v_lowestId - 1
	  SET @v_new_itemnumber = CONVERT(VARCHAR, @v_itemnumber_sequence)
	  EXEC qean_after_itemnumber_update_multiorg @v_orgentrykey_holder, @v_new_itemnumber, 
        @o_error_code OUTPUT, @o_error_desc OUTPUT
      END
      
    /* check if itemnumber is higher than the highest number on defined scale of itemnumbers, error is so */    
    IF @v_itemnumber_sequence > @v_highestId
    BEGIN
      SET @o_error_code = -1 
      SET @o_error_desc = 'There are no more itemnumbers available, the highest number has been reached.'
      RETURN
    END  
      
    /* Generate new itemnumber */
    SET @v_itemnumber_sequence = @v_itemnumber_sequence + 1
    SET @v_new_itemnumber = CONVERT(VARCHAR, @v_itemnumber_sequence)
    
    
    --If it shorter than 6 it will add preceeding zeros
    IF LEN(@v_new_itemnumber) < 6
		SET @v_new_itemnumber = RIGHT('000000'+ CONVERT(VARCHAR,@v_new_itemnumber),6)
    
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
      /*  Update this sequence number on defaults table - for DOIT_AGAIN next select */
      EXEC qean_after_itemnumber_update_multiorg @v_orgentrykey_holder, @v_new_itemnumber, 
        @o_error_code OUTPUT, @o_error_desc OUTPUT
      
      /*  Call itself again to generate another itemnumber */
      GOTO DOIT_AGAIN
    END
          
   SET @o_new_itemnumber = @v_new_itemnumber    
    
  END 

END 
GO


GRANT ALL ON qean_generate_itemnumber TO PUBLIC