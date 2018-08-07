if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_verify_title') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_verify_title
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_verify_title
 (@i_bookkey         integer,
  @i_printingkey     integer,
  @i_verifytypecode  integer,
  @i_userid          varchar(30),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  Name: qtitle_verify_title
**  Desc: This stored procedure calls the title verification procedure
**        based on the verificationtypecode. 
**
**    Returns -1 for an error
**    Otherwise, returns titleverifystatuscode
**           
**    Auth: Alan Katzen
**    Date: 28 November 2007
*******************************************************************************/

DECLARE @error_var    INT,
        @rowcount_var INT,
        @titleverifystatuscode_var INT,
        @v_StoredProcName  varchar(1000),
        @SQLString NVARCHAR(4000),
        @v_count  INT,
        @v_csverifytype INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- get stored procedure name
  SELECT @v_StoredProcName = COALESCE(alternatedesc1,'')
    FROM gentables
   WHERE tableid = 556
     and datacode = @i_verifytypecode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error looking for stored procedure name: bookkey = ' + cast(@i_bookkey AS VARCHAR) + 
                        ' printingkey = ' + cast(@i_printingkey AS VARCHAR) +
                        ' verificationtypecode = ' + cast(@i_verifytypecode AS VARCHAR)
    RETURN
  END 
  
  IF (@v_StoredProcName is null OR ltrim(rtrim(@v_StoredProcName)) = '') BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'stored procedure name is blank: bookkey = ' + cast(@i_bookkey AS VARCHAR) + 
                        ' printingkey = ' + cast(@i_printingkey AS VARCHAR) +
                        ' verificationtypecode = ' + cast(@i_verifytypecode AS VARCHAR)
    RETURN
  END

  SET @v_csverifytype = 0
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 556 AND qsicode = 3
  
  IF @v_count > 0  
    SELECT @v_csverifytype = datacode
    FROM gentables
    WHERE tableid = 556 AND qsicode = 3

  IF @i_verifytypecode = @v_csverifytype BEGIN
    SET @SQLString = N'exec ' + @v_StoredProcName + 
      ' @i_bookkey, @i_printingkey, @i_verificationtypecode, @i_username, @v_error_code OUTPUT, @v_error_desc OUTPUT'
          
    EXECUTE sp_executesql @SQLString, 
      N'@i_bookkey int, @i_printingkey int, @i_verificationtypecode int,
        @i_username varchar(15), @v_error_code INT OUTPUT, @v_error_desc VARCHAR(2000) OUTPUT', 
      @i_bookkey = @i_bookkey, 
      @i_printingkey = @i_printingkey, 
      @i_verificationtypecode = @i_verifytypecode, 
      @i_username = @i_userid,
      @v_error_code = @o_error_code OUTPUT,
      @v_error_desc = @o_error_desc OUTPUT
  END
  ELSE BEGIN
    SET @SQLString = N'exec ' + @v_StoredProcName + ' @i_bookkey, @i_printingkey, @i_verificationtypecode, @i_username'
          
    EXECUTE sp_executesql @SQLString, 
      N'@i_bookkey int, @i_printingkey int, @i_verificationtypecode int,
        @i_username varchar(15)', 
      @i_bookkey = @i_bookkey, 
      @i_printingkey = @i_printingkey, 
      @i_verificationtypecode = @i_verifytypecode, 
      @i_username = @i_userid  
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error executing stored procedure ' + @v_StoredProcName + ': bookkey = ' + cast(@i_bookkey AS VARCHAR) + 
                        ' printingkey = ' + cast(@i_printingkey AS VARCHAR) +
                        ' verificationtypecode = ' + cast(@i_verifytypecode AS VARCHAR)
    RETURN
  END

  IF @o_error_code < 0
    RETURN

  SELECT @titleverifystatuscode_var = COALESCE(titleverifystatuscode,0)
    FROM bookverification
   WHERE bookkey = @i_bookkey
     AND verificationtypecode = @i_verifytypecode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get status from bookverification: bookkey = ' + cast(@i_bookkey AS VARCHAR) + 
                        ' verificationtypecode = ' + cast(@i_verifytypecode AS VARCHAR)
    RETURN
  END 

  IF @titleverifystatuscode_var is null BEGIN
    SET @titleverifystatuscode_var = 0
  END

  -- return statuscode thru @o_error_code
  SET @o_error_code = @titleverifystatuscode_var
  
END
GO

GRANT EXEC ON qtitle_verify_title TO PUBLIC
GO


