if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_auto_verify_title') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_auto_verify_title
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_auto_verify_title
 (@i_bookkey         integer,
  @i_printingkey     integer,
  @i_userid          varchar(30),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_auto_verify_title
**  Desc: This stored procedure calls the title verification procedure for 
**        all verificationtypecodes with autorun (gen2ind = 1 tableid 556) 
**        turned on. 
**
**           
**    Auth: Alan Katzen
**    Date: 12 December 2007
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       -------------------------------------------
**    02/17/2016  UK             Case 36432
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var               INT,
          @error_code              INT,
          @error_msg               varchar(2000),
          @rowcount_var            INT,
          @v_titleverifystatuscode INT,
          @v_verificationtypecode  INT,
          @v_StoredProcName        varchar(1000),
          @v_nextkey               INT,
          @v_Error                 INT,
          @v_Warning               INT,
          @v_Information           INT
         

  IF @i_bookkey IS NULL OR @i_bookkey <= 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'Unable to auto verify title: bookkey is empty.'
    RETURN
  END 

  SET @v_Error = 2
  SET @v_Warning = 3
  SET @v_Information = 4

  -- get stored procedure names with auto run turned on
  DECLARE cur_name CURSOR FOR
   SELECT datacode, COALESCE(alternatedesc1,'') storedprocname
     FROM gentables
    WHERE tableid = 556 
      AND COALESCE(gen2ind,0) = 1
      AND LOWER(deletestatus) = 'n'

  OPEN cur_name 
  FETCH NEXT FROM cur_name INTO @v_verificationtypecode, @v_StoredProcName
  WHILE (@@FETCH_STATUS <> -1) BEGIN
  
    IF (@v_StoredProcName is null OR ltrim(rtrim(@v_StoredProcName)) = '') BEGIN
      --SET @o_error_code = -1
      SET @error_msg = 'Auto Verification Process Failed - stored procedure name is blank:' + 
                       ' verificationtypecode = ' + cast(@v_verificationtypecode AS VARCHAR)
      -- put message on bookverificationmessage
      EXECUTE get_next_key @i_userid, @v_nextkey out
      INSERT INTO bookverificationmessage
             (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate, messagecategorycode)
      VALUES (@v_nextkey, @i_bookkey, @v_verificationtypecode, @v_Error, @error_msg, @i_userid, getdate(), 0 )

      GOTO next_row
    END

    IF (@v_verificationtypecode > 0) BEGIN
      EXECUTE qtitle_verify_title @i_bookkey,@i_printingkey,@v_verificationtypecode,
                                  @i_userid,@error_code output,@error_msg output
    
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        --SET @o_error_code = -1
        SET @error_msg = 'Auto Verification Process Failed - error executing stored procedure ' + @v_StoredProcName + ':' + 
                         ' verificationtypecode = ' + cast(@v_verificationtypecode AS VARCHAR)
        -- put message on bookverificationmessage
        EXECUTE get_next_key @i_userid, @v_nextkey out
        INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate, messagecategorycode)
        VALUES(@v_nextkey, @i_bookkey, @v_verificationtypecode, @v_Error, @error_msg, @i_userid, getdate(), 0 )

        GOTO next_row
      END 

      IF @error_code < 0 BEGIN
        -- error
        -- put message on bookverificationmessage
        EXECUTE get_next_key @i_userid, @v_nextkey out
        INSERT INTO bookverificationmessage
               (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate, messagecategorycode)
        VALUES (@v_nextkey, @i_bookkey, @v_verificationtypecode, @v_Error, @error_msg, @i_userid, getdate(), 0 )

        GOTO next_row
      END
      ELSE BEGIN
        -- status returned from proc
        SET @v_titleverifystatuscode = @error_code

        IF @v_titleverifystatuscode is null BEGIN
          SET @v_titleverifystatuscode = 0
        END
      END
    END

    next_row:
    FETCH NEXT FROM cur_name INTO @v_verificationtypecode, @v_StoredProcName
  END /* WHILE FECTHING */

  CLOSE cur_name
  DEALLOCATE cur_name

GO
GRANT EXEC ON qtitle_auto_verify_title TO PUBLIC
GO


