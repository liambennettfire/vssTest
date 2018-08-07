IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_delete_cloudfolderadmin')
BEGIN
  PRINT 'Dropping Procedure qelement_delete_element'
  DROP  Procedure  qutl_delete_cloudfolderadmin
END
GO

PRINT 'Creating Procedure qutl_delete_cloudfolderadmin'
GO

CREATE PROCEDURE qutl_delete_cloudfolderadmin
 (@i_folderkey         integer,
  @i_userkey            integer,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_delete_cloudfolderadmin
**              
**    Parameters:
**    Input              
**    ----------         
**    folderkey - Key of Element Being Deleted - Required
**    userkey - userkey of user deleting element - NOT Required 
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Uday Khisty
**    Date: 04/17/13  
*******************************************************************************/
  
  -- verify folderkey is filled in
  IF @i_folderkey IS NULL OR @i_folderkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to Delete cloudfolderadmin: folderkey is empty.'
    RETURN
  END 

  DECLARE @error_var    INT,
          @rowcount_var INT,
          @errormsg_var varchar(2000),
          @is_error_var TINYINT,
          @lastmaintdate_var DATETIME,
          @lastuserid_var VARCHAR(30),
          @count_var INT,
          @count2_var INT,
          @countoverride_var INT,
          @taqtaskkey_var INT,
          @taqelementkey_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_userkey >= 0 BEGIN
    -- get userid from qsiusers
    SELECT @lastuserid_var = userid
      FROM qsiusers
     WHERE userkey = @i_userkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to Delete cloudfolderadmin: Error accessing qsiusers table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
    IF @rowcount_var <= 0 BEGIN
      -- User Not Found - just use default userid
      SET @lastuserid_var = 'DeleteCloudfolderadmin'
    END 
  END
  ELSE BEGIN
    SET @lastuserid_var = 'DeleteCloudfolderadmin'
  END

  BEGIN TRANSACTION

  -- comments
  PRINT 'Deleting cloudfolderassetadmin...'

  SELECT @count_var = count(*)
    FROM cloudfolderassetadmin
   WHERE folderkey = @i_folderkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete cloudfolderassetadmin: Error accessing cloudfolderassetadmin table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM cloudfolderassetadmin
    WHERE folderkey = @i_folderkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete cloudfolderassetadmin: Error deleting cloudfolderassetadmin table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectelement
  PRINT 'Deleting cloudfolderadmin...'

  SELECT @count_var = count(*)
    FROM cloudfolderadmin
   WHERE folderkey = @i_folderkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete cloudfolderadmin: Error accessing cloudfolderadmin table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM cloudfolderadmin
    WHERE folderkey = @i_folderkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete cloudfolderadmin: Error deleting cloudfolderadmin table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  COMMIT
  
  ExitHandler:
  IF @is_error_var = 1 BEGIN
    ROLLBACK
    SET @o_error_desc = @errormsg_var
    RETURN
  END
GO

GRANT EXEC ON qutl_delete_cloudfolderadmin TO PUBLIC
GO
