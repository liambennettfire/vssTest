/****** Object:  StoredProcedure [dbo].[qean_generate_itemnumber_ks]    Script Date: 03/25/2009 15:21:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qean_generate_itemnumber_ks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qean_generate_itemnumber_ks]

/****** Object:  StoredProcedure [dbo].[qean_generate_itemnumber_ks]    Script Date: 03/25/2009 15:21:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qean_generate_itemnumber_ks]
  @i_check_auto_option  TINYINT,
  @i_bookkey            int,
  @o_new_itemnumber     VARCHAR(20) OUTPUT,
  @o_error_code         INT OUTPUT,
  @o_error_desc         VARCHAR(2000) OUTPUT
AS

/*********************************************************************************************
**  Name: qean_generate_itemnumber_ks
**  Desc: Generates itemnumber based on defaults.itemnumberseq if the clientoption
**        for itemnumber auto-generation is turned ON.
**
**  Auth: Kate J. Wiewiora
**  Date: 12 January 2007
**  Auth: Jennifer Hurd
**  Date: 25 March 2009
**  Desc:  Made changes to this version specifically for Kamehameha Publishing
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
**  --------    --------    -------------------------------------------
**  09/13/2017   Colman     Case 47207 - Procedure needs custom name
******************************************************************************************/



-- DOIT_AGAIN Label:
-- When the generated itemnumber already exists (was entered manually elsewhere), 
-- this procedure will get executed again to try to generate new itemnumber.


DOIT_AGAIN:

DECLARE
  @v_count  INT,
  @v_error  INT,
  @v_itemnumber_sequence INT,
  @v_generate_new INT,  
  @v_new_itemnumber VARCHAR(20),
  @v_rowcount INT,
  @char5  char(10),
  @prefix  char(2)

BEGIN
 
  SET @o_new_itemnumber = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  /* Assume that new itemnumber will be generated - default to 1 */
  SET @v_generate_new = 1
  
  /* Based on passed input parameter, check the client option to make sure that itemnumber */
  /* should be automatically generated */
  IF @i_check_auto_option = 1
  BEGIN
    SELECT @v_generate_new = optionvalue
    FROM clientoptions
    WHERE optionid = 60
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0
    BEGIN
      SET @o_error_code = -1 
      SET @o_error_desc = 'Could not access clientoptions table (optionid = 60).'
      RETURN
    END
    
    IF @v_rowcount = 0
      SET @v_generate_new = 0
  END
  
  IF @v_generate_new = 1
  BEGIN
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
      
    /* Generate new itemnumber */
    SET @v_itemnumber_sequence = @v_itemnumber_sequence + 1
    SET @v_new_itemnumber = CONVERT(VARCHAR, @v_itemnumber_sequence)
        
  set @char5 = substring(@v_new_itemnumber,len(@v_new_itemnumber)-4,5)

  set @char5 = case when len(@char5) = 4 then '0' + @char5
    when len(@char5) = 3 then '00' + @char5
    when len(@char5) = 2 then '000' + @char5
    when len(@char5) = 1 then '0000' + @char5
    else @char5
  end

  select @prefix = isnull(substring(s.datadescshort, 1,2),'')
  from bookdetail b
  join subgentables s
  on b.mediatypecode = s.datacode
  and b.mediatypesubcode = s.datasubcode
  and s.tableid = 312
  where bookkey = @i_bookkey

    IF @v_rowcount = 0 or @prefix = ''
    BEGIN
    set @prefix = 'NA'
    END

  set @v_new_itemnumber = @prefix+@char5

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
    
  END --@v_generate_new = 1
  
END
