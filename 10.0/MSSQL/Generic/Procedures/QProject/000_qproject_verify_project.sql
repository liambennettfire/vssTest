if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_verify_project') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_verify_project
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_verify_project
 (@i_projectkey      integer,
  @i_verifytypecode  integer,
  @i_userid          varchar(30),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  Name: qproject_verify_project
**  Desc: This stored procedure calls the title verification procedure
**        based on the verificationtypecode. 
**
**    Returns -1 for an error
**    Otherwise, returns verificationstatuscode
**           
**    Auth: Alan Katzen
**    Date: 3 February 2012
*******************************************************************************/

DECLARE @error_var    INT,
        @rowcount_var INT,
        @verificationstatuscode_var INT,
        @v_StoredProcName  varchar(1000),
        @SQLString NVARCHAR(4000),
        @v_count  INT,
		@v_erroroutputind  INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- get stored procedure name
  SELECT @v_StoredProcName = COALESCE(alternatedesc1,'')
    FROM gentables
   WHERE tableid = 628
     and datacode = @i_verifytypecode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error looking for stored procedure name: projectkey = ' + cast(@i_projectkey AS VARCHAR) + 
                        ' verificationtypecode = ' + cast(@i_verifytypecode AS VARCHAR)
    RETURN
  END 
  
  IF (@v_StoredProcName is null OR ltrim(rtrim(@v_StoredProcName)) = '') BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'stored procedure name is blank: projectkey = ' + cast(@i_projectkey AS VARCHAR) + 
                        ' verificationtypecode = ' + cast(@i_verifytypecode AS VARCHAR)
    RETURN
  END

  SELECT @v_erroroutputind = COALESCE(gen3ind,0)
  FROM gentables_ext
  WHERE tableid = 628 AND datacode=@i_verifytypecode

  IF @v_erroroutputind = 1 BEGIN
    SET @SQLString = N'exec ' + @v_StoredProcName + 
	  ' @i_projectkey, @i_verificationtypecode, @i_username, @v_error_code OUTPUT, @v_error_desc OUTPUT'         

    EXECUTE sp_executesql @SQLString, 
      N'@i_projectkey int, @i_verificationtypecode int, 
	  @i_username varchar(30), @v_error_code INT OUTPUT, @v_error_desc VARCHAR(2000) OUTPUT', 
      @i_projectkey = @i_projectkey, 
      @i_verificationtypecode = @i_verifytypecode, 
      @i_username = @i_userid,
      @v_error_code = @o_error_code OUTPUT,
      @v_error_desc = @o_error_desc OUTPUT	    
  END
  ELSE BEGIN
     SET @SQLString = N'exec ' + @v_StoredProcName + ' @i_projectkey, @i_verificationtypecode, @i_username'
        
     EXECUTE sp_executesql @SQLString, 
       N'@i_projectkey int, @i_verificationtypecode int, @i_username varchar(30)', 
       @i_projectkey = @i_projectkey, 
       @i_verificationtypecode = @i_verifytypecode, 
       @i_username = @i_userid  
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error executing stored procedure ' + @v_StoredProcName + ': projectkey = ' + cast(@i_projectkey AS VARCHAR) + 
                        ' verificationtypecode = ' + cast(@i_verifytypecode AS VARCHAR)
    RETURN
  END

  IF @o_error_code < 0
    RETURN

  SELECT @verificationstatuscode_var = COALESCE(verificationstatuscode,0)
    FROM taqprojectverification
   WHERE taqprojectkey = @i_projectkey
     AND verificationtypecode = @i_verifytypecode

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get status from taqprojectverification: projectkey = ' + cast(@i_projectkey AS VARCHAR) + 
                        ' verificationtypecode = ' + cast(@i_verifytypecode AS VARCHAR)
    RETURN
  END 

  IF @verificationstatuscode_var is null BEGIN
    SET @verificationstatuscode_var = 0
  END

  -- return statuscode thru @o_error_code
  SET @o_error_code = @verificationstatuscode_var
  
END
GO

GRANT EXEC ON qproject_verify_project TO PUBLIC
GO


