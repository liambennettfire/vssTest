IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qelement_delete_element')
BEGIN
  PRINT 'Dropping Procedure qelement_delete_element'
  DROP  Procedure  qelement_delete_element
END
GO

PRINT 'Creating Procedure qelement_delete_element'
GO

CREATE PROCEDURE qelement_delete_element
 (@i_elementkey         integer,
  @i_userkey            integer,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qelement_delete_element
**              
**    Parameters:
**    Input              
**    ----------         
**    elementkey - Key of Element Being Deleted - Required
**    userkey - userkey of user deleting element - NOT Required 
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Alan Katzen
**    Date: 07/01/08  
*******************************************************************************/
  
  -- verify elementkey is filled in
  IF @i_elementkey IS NULL OR @i_elementkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to Delete Element: elementkey is empty.'
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
      SET @o_error_desc = 'Unable to Delete Element: Error accessing qsiusers table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
    IF @rowcount_var <= 0 BEGIN
      -- User Not Found - just use default userid
      SET @lastuserid_var = 'DeleteElement'
    END 
  END
  ELSE BEGIN
    SET @lastuserid_var = 'DeleteElement'
  END

  BEGIN TRANSACTION

  -- comments
  PRINT 'Deleting comments...'

  SELECT @count_var = count(*)
    FROM qsicomments
   WHERE commentkey = @i_elementkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Element: Error accessing qsicomments table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM qsicomments
    WHERE commentkey = @i_elementkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Element: Error deleting qsicomments table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqelementmisc
  PRINT 'Deleting taqelementmisc...'

  SELECT @count_var = count(*)
    FROM taqelementmisc
   WHERE taqelementkey = @i_elementkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Element: Error accessing taqelementmisc table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqelementmisc
    WHERE taqelementkey = @i_elementkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Element: Error deleting taqelementmisc table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- filelocation
  PRINT 'Deleting filelocation...'

  SELECT @count_var = count(*)
    FROM filelocation
   WHERE taqelementkey = @i_elementkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Element: Error accessing filelocation table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM filelocation
    WHERE taqelementkey = @i_elementkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Element: Error deleting filelocation table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqproductnumbers
  PRINT 'Deleting taqproductnumbers...'

  SELECT @count_var = count(*)
    FROM taqproductnumbers
   WHERE elementkey = @i_elementkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Element: Error accessing taqproductnumbers table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqproductnumbers
    WHERE elementkey = @i_elementkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Element: Error deleting taqproductnumbers table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectreaderiteration
  PRINT 'Deleting taqprojectreaderiteration...'

  SELECT @count_var = count(*)
    FROM taqprojectreaderiteration
   WHERE taqelementkey = @i_elementkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Element: Error accessing taqprojectreaderiteration table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectreaderiteration
    WHERE taqelementkey = @i_elementkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Element: Error deleting taqprojectreaderiteration table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END
    
  -- taqprojecttask
  PRINT 'Deleting taqprojecttaskoverride / Setting taqprojecttask.taqelementkey to NULL / Deleting taqprojecttask...'

  SELECT @count_var = count(*)
    FROM taqprojecttask
   WHERE taqelementkey = @i_elementkey

  SELECT @count2_var = count(*)
    FROM taqprojecttaskoverride
   WHERE taqelementkey = @i_elementkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Element: Error accessing taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 

  IF @count_var > 0 BEGIN

	DECLARE TaqprojecttaskKeys_cur CURSOR FOR
	  SELECT taqtaskkey 
	  FROM taqprojecttask WHERE taqelementkey = @i_elementkey
	  
	OPEN TaqprojecttaskKeys_cur
		
	FETCH NEXT FROM TaqprojecttaskKeys_cur into @taqtaskkey_var
		
	WHILE (@@FETCH_STATUS <> -1) BEGIN
		IF EXISTS (SELECT * FROM taqprojecttaskoverride WHERE taqtaskkey = @taqtaskkey_var) OR
		   EXISTS (SELECT * FROM taqprojecttask t, gentablesitemtype g 
		           WHERE t.datetypecode = g.datacode AND g.itemtypecode <> 7 AND g.relateddatacode > 1 AND t.taqtaskkey = @taqtaskkey_var) BEGIN
			UPDATE taqprojecttask SET taqelementkey = NULL 
			WHERE taqtaskkey = @taqtaskkey_var
		END
	  ELSE BEGIN
			DELETE FROM taqprojecttask
			WHERE taqtaskkey = @taqtaskkey_var

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
			  SET @is_error_var = 1
			  SET @o_error_code = -1
			  SET @errormsg_var = 'Unable to Delete Element: Error deleting taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
			  GOTO ExitHandler
			END 
		END		
	  FETCH NEXT FROM TaqprojecttaskKeys_cur into @taqtaskkey_var
	END
	CLOSE TaqprojecttaskKeys_cur
	DEALLOCATE TaqprojecttaskKeys_cur
  END

  IF @count2_var > 0 BEGIN

	DECLARE TaqprojecttaskoverrideKeys_cur CURSOR FOR
	  SELECT taqtaskkey 
		FROM taqprojecttaskoverride WHERE taqelementkey = @i_elementkey
		
	OPEN TaqprojecttaskoverrideKeys_cur
  
	FETCH NEXT FROM TaqprojecttaskoverrideKeys_cur into @taqtaskkey_var
	
	WHILE (@@FETCH_STATUS <> -1) BEGIN

		SELECT @countoverride_var = Count(*) FROM taqprojecttaskoverride WHERE taqtaskkey = @taqtaskkey_var
		IF @countoverride_var = 1 BEGIN
			SELECT @taqelementkey_var = taqelementkey FROM taqprojecttask
			WHERE taqtaskkey = @taqtaskkey_var

			IF @taqelementkey_var IS NULL BEGIN
				DELETE FROM taqprojecttask
				WHERE taqtaskkey = @taqtaskkey_var
				SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
				IF @error_var <> 0 BEGIN
				  SET @is_error_var = 1
				  SET @o_error_code = -1
				  SET @errormsg_var = 'Unable to Delete Element: Error deleting taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
				  GOTO ExitHandler
				END 
			END
		END

		DELETE FROM taqprojecttaskoverride WHERE taqtaskkey = @taqtaskkey_var AND taqelementkey = @i_elementkey	
		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
		  SET @is_error_var = 1
		  SET @o_error_code = -1
		  SET @errormsg_var = 'Unable to Delete Element: Error deleting taqprojecttaskoverride table (' + cast(@error_var AS VARCHAR) + ').'
		  GOTO ExitHandler
		END 
	  FETCH NEXT FROM TaqprojecttaskoverrideKeys_cur into @taqtaskkey_var
	END
	CLOSE TaqprojecttaskoverrideKeys_cur
	DEALLOCATE TaqprojecttaskoverrideKeys_cur
  END

  -- taqprojectelement
  PRINT 'Deleting taqprojectelement...'

  SELECT @count_var = count(*)
    FROM taqprojectelement
   WHERE taqelementkey = @i_elementkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Element: Error accessing taqprojectelement table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectelement
    WHERE taqelementkey = @i_elementkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Element: Error deleting taqprojectelement table (' + cast(@error_var AS VARCHAR) + ').'
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

GRANT EXEC ON qelement_delete_element TO PUBLIC
GO
