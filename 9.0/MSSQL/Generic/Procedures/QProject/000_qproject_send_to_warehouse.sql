if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_send_to_warehouse') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_send_to_warehouse
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_send_to_warehouse
 (@i_projectkey      integer,
  @i_userid          varchar(30),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_send_to_warehouse
**  Desc: This stored procedure calls the send to warehouse procedure
**        based on clientdefaults. 
**
**    Returns -1 for an error
**           
**    Auth: Alan Katzen
**    Date: 3 February 2012
*******************************************************************************
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    7/3/2013 Kusum            CASE 18175
**                              When Send to Warehouse has completed successfully, it 
**                              should update all tasks with the date type code from 
**                              client default for Send to Warehouse Date type code for 
**                              the current project to the current date and set actual
**                              ind to set to yes. 
**                             
*******************************************************************************/

DECLARE @error_var    INT,
        @rowcount_var INT,
        @verificationstatuscode_var INT,
        @v_StoredProcName  varchar(1000),
        @SQLString NVARCHAR(4000),
        @v_count  INT,
        @v_csverifytype INT,
        @v_sendtowarehouse_datetypecode  INT,
        @v_error_code INT,
        @v_error_desc varchar(2000)
        
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF (@i_projectkey is null OR @i_projectkey <= 0) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to send to warehouse: Invalid projectkey' 
    RETURN
  END
  
  -- get stored procedure name
  SELECT @v_StoredProcName = COALESCE(stringvalue,'')
    FROM clientdefaults
   WHERE clientdefaultid = 63

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error looking for stored procedure name: projectkey = ' + cast(@i_projectkey AS VARCHAR) 
    RETURN
  END 
  
  IF (@v_StoredProcName is null OR ltrim(rtrim(@v_StoredProcName)) = '') BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'stored procedure name is blank: projectkey = ' + cast(@i_projectkey AS VARCHAR) 
    RETURN
  END

  SET @SQLString = N'exec ' + @v_StoredProcName + ' @i_projectkey, @i_username, @v_error_code OUTPUT, @v_error_desc OUTPUT'
        
  EXECUTE sp_executesql @SQLString, 
    N'@i_projectkey int, @i_username varchar(30), @v_error_code INT OUTPUT, @v_error_desc VARCHAR(2000) OUTPUT', 
    @i_projectkey = @i_projectkey, 
    @i_username = @i_userid, 
    @v_error_code = @o_error_code OUTPUT,
    @v_error_desc = @o_error_desc OUTPUT

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error executing stored procedure ' + @v_StoredProcName + ': projectkey = ' + cast(@i_projectkey AS VARCHAR)
    RETURN
  END
  
  IF @v_error_code < 0 BEGIN
    SET @o_error_code = @v_error_code
    SET @o_error_desc = @v_error_desc
    RETURN
  END

  /* Get the datetypecode for Send to Warehouse from clientdefautlts */  
  SELECT @v_count = COUNT(*)
  FROM clientdefaults WHERE clientdefaultid = 75
  
  SET @v_sendtowarehouse_datetypecode = 0
  IF @v_count > 0
    SELECT @v_sendtowarehouse_datetypecode = clientdefaultvalue
      FROM clientdefaults 
     WHERE clientdefaultid = 75
  
  IF @v_sendtowarehouse_datetypecode IS NULL 
     SELECT @v_sendtowarehouse_datetypecode = 0

  -- For Send to Warehouse Date on tasks, also set actualind 
  IF @v_sendtowarehouse_datetypecode > 0 
  BEGIN
      UPDATE taqprojecttask
         SET activedate = getdate(), 
             actualind = 1,
             lastuserid = @i_userid,
             lastmaintdate = getdate()
       WHERE taqprojectkey = @i_projectkey 
         AND datetypecode = @v_sendtowarehouse_datetypecode
  END
  
END
GO

GRANT EXEC ON qproject_send_to_warehouse TO PUBLIC
GO


