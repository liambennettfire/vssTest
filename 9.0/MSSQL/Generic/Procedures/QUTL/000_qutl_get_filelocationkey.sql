if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_filelocationkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_filelocationkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_filelocationkey
 (@i_filetypecode     integer,
  @i_userkey          integer,
  @o_filelocationkey  integer output,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_filelocationkey
**  Desc: This procedure returns the filelocationkey for a filetype/orgentry.
**        If there is no filelocation setup for the filetype/orgentry, then
**        the default row (0 orgentry) for that filetype (if it exists) will 
**        be used. Orgentrykey comes from the user's primary orgentry structure.
**
**	Auth: Alan Katzen
**	Date: 28 October 2009
*******************************************************************************/
BEGIN
  DECLARE @v_error	INT,
          @v_rowcount INT,
          @v_count INT,
          @v_orglevelkey int,
          @v_orgentrykey int

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_filelocationkey = 0
  SET @v_orglevelkey = 0
  SET @v_orgentrykey = 0
  
  SELECT @v_orglevelkey = filterorglevelkey 
    FROM filterorglevel
   WHERE filterkey = 33
   
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_filelocationkey = 0
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning filelocationkey (filterorglevel) (filetype=' + cast(@i_filetypecode as varchar) + ', userkey=' + cast(@i_userkey as varchar) + ')'
    RETURN  
  END 
  
  IF @v_orglevelkey is null BEGIN
    SET @v_orglevelkey = 0
  END 

  IF @v_orglevelkey > 0 BEGIN
    -- get orgentrykey from userprimaryorgentry
    SELECT @v_count = count(*)
      FROM userprimaryorgentry
     WHERE userkey = @i_userkey
       AND orglevelkey = @v_orglevelkey
       
    IF @v_count > 0 BEGIN
      SELECT @v_orgentrykey = orgentrykey
        FROM userprimaryorgentry
       WHERE userkey = @i_userkey
         AND orglevelkey = @v_orglevelkey
         
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error accessing userprimaryorgentry (filetype=' + cast(@i_filetypecode as varchar) + ', userkey=' + cast(@i_userkey as varchar) + ')'
        RETURN  
      END 

      IF @v_orgentrykey is null BEGIN
        SET @v_orgentrykey = 0         
      END
    END
  END
 
  IF @v_orglevelkey > 0 AND @v_orgentrykey > 0 BEGIN
    SELECT @v_count = count(*)
      FROM filelocationorgentry
     WHERE filetypecode = @i_filetypecode
       AND orglevelkey = @v_orglevelkey
       AND orgentrykey = @v_orgentrykey
       
    IF @v_count > 0 BEGIN
      SELECT @o_filelocationkey = filelocationkey
        FROM filelocationorgentry
       WHERE filetypecode = @i_filetypecode
         AND orglevelkey = @v_orglevelkey
         AND orgentrykey = @v_orgentrykey

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
        SET @o_filelocationkey = 0
        SET @o_error_code = -1
        SET @o_error_desc = 'Error returning filelocationkey (filetype=' + cast(@i_filetypecode as varchar) + ', userkey=' + cast(@i_userkey as varchar) + ')'
        RETURN  
      END 
    END

    IF @o_filelocationkey > 0 BEGIN
      RETURN
    END
  END
  
  -- look for default row
  SELECT @v_count = count(*)
    FROM filelocationorgentry
   WHERE filetypecode = @i_filetypecode
     AND orglevelkey = 0
     AND orgentrykey = 0
     
  IF @v_count > 0 BEGIN
    SELECT @o_filelocationkey = filelocationkey
      FROM filelocationorgentry
     WHERE filetypecode = @i_filetypecode
       AND orglevelkey = 0
       AND orgentrykey = 0

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 BEGIN
      SET @o_filelocationkey = 0
      SET @o_error_code = -1
      SET @o_error_desc = 'Error returning filelocationkey (filetype=' + cast(@i_filetypecode as varchar) + ', userkey=' + cast(@i_userkey as varchar) + ')'
      RETURN  
    END 
  END
END  
GO

GRANT EXEC ON qutl_get_filelocationkey TO PUBLIC
GO


