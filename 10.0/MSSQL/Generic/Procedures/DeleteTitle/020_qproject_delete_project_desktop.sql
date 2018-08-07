IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qproject_delete_project_desktop')
BEGIN
  PRINT 'Dropping Procedure qproject_delete_project_desktop'
  DROP  Procedure  qproject_delete_project_desktop
END
GO

PRINT 'Creating Procedure qproject_delete_project_desktop'
GO

CREATE PROCEDURE qproject_delete_project_desktop
 (@i_projectkey         integer,
  @i_userkey            integer,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_delete_project_desktop
**  Desc: 
**              
**    Parameters:
**    Input              
**    ----------         
**    projectkey - Key of Project Being Deleted - Required
**    userkey - userkey of user deleting project - NOT Required 
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Alan Katzen
**    Date: 10/10/05
*******************************************************************************
**    Change History
*******************************************************************************
**    Date: 06/17/2015 Kusum
**    This procedure is identical to qproject_delete_project except for edits
**    put in for delete printing projects on the web (Case 29796)
**    
*******************************************************************************/
  
  -- verify projectkey is filled in
  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to Delete Project: projectkey is empty.'
    RETURN
  END 

  DECLARE @error_var    INT,
          @rowcount_var INT,
          @errormsg_var varchar(2000),
          @is_error_var TINYINT,
          @lastmaintdate_var DATETIME,
          @lastuserid_var VARCHAR(30),
          @count_var INT,
          @v_plstage  INT,
          @v_plversion  INT,
          @v_categorykey INT,
          @v_searchitemcode INT,
          @v_usageclasscode INT,
          @v_printing_searchitemcode INT,
          @v_printing_usageclasscode INT,
          @v_bookkey INT,
          @v_printingkey INT,
          @v_cnt_printings INT,
          @v_otherdefaultrelationshipcode INT,
          @v_count_pos INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- if project status is sent to tmm then can't delete
  SELECT @count_var = count(*)
    FROM gentables g, taqproject p
   WHERE p.taqprojectstatuscode = g.datacode and
         g.tableid = 522 and 
         g.qsicode in (1) and
         p.taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to Delete Project: Error accessing project status on taqproject (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 
  IF @count_var > 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to Delete Project due to the Project Status.'
    RETURN
  END 

  IF @i_userkey >= 0 BEGIN
    -- get userid from qsiusers
    SELECT @lastuserid_var = userid
      FROM qsiusers
     WHERE userkey = @i_userkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to Delete Project: Error accessing qsiusers table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
    IF @rowcount_var <= 0 BEGIN
      -- User Not Found - just use default userid
      SET @lastuserid_var = 'DeleteProject'
    END 
  END
  ELSE BEGIN
    SET @lastuserid_var = 'DeleteProject'
  END
  
  BEGIN TRANSACTION

  -- taqprojectcomments
  PRINT 'Deleting taqprojectcomments...'

  SELECT @count_var = count(*)
    FROM taqprojectcomments
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectcomments table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectcomments
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectcomments table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectcontact
  PRINT 'Deleting taqprojectcontact...'

  SELECT @count_var = count(*)
    FROM taqprojectcontact
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectcontact table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectcontact
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectcontact table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectcontactrole
  PRINT 'Deleting taqprojectcontactrole...'

  SELECT @count_var = count(*)
    FROM taqprojectcontactrole
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectcontactrole table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectcontactrole
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectcontactrole table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectcontract
  PRINT 'Deleting taqprojectcontract...'

  SELECT @count_var = count(*)
    FROM taqprojectcontract
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectcontract table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectcontract
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectcontract table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectelement
  PRINT 'Deleting taqprojectelement...'

  -- delete rows not associated with a title
  SELECT @count_var = count(*)
    FROM taqprojectelement
   WHERE taqprojectkey = @i_projectkey
     AND COALESCE(bookkey,0) <= 0

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectelement table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectelement
    WHERE taqprojectkey = @i_projectkey
      AND COALESCE(bookkey,0) <= 0

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectelement table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- remove link to project if associated with title
  SELECT @count_var = count(*)
    FROM taqprojectelement
   WHERE taqprojectkey = @i_projectkey
     AND bookkey > 0

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectelement table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    UPDATE taqprojectelement
       SET taqprojectkey = 0
     WHERE taqprojectkey = @i_projectkey
       AND bookkey > 0
 
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error updating taqprojectelement table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojecttitle
  PRINT 'Deleting taqprojecttitle...'

  SELECT @count_var = count(*)
    FROM taqprojecttitle
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojecttitle table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojecttitle
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojecttitle table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectlock
  PRINT 'Deleting taqprojectlock...'

  SELECT @count_var = count(*)
    FROM taqprojectlock
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectlock table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectlock
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectlock table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectorgentry
  PRINT 'Deleting taqprojectorgentry...'

  SELECT @count_var = count(*)
    FROM taqprojectorgentry
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectorgentry table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectorgentry
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectorgentry table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectreaderiteration
  PRINT 'Deleting taqprojectreaderiteration...'

  SELECT @count_var = count(*)
    FROM taqprojectreaderiteration
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectreaderiteration table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectreaderiteration
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectreaderiteration table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectsubjectcategory
  PRINT 'Deleting taqprojectsubjectcategory...'

  SELECT @count_var = count(*)
    FROM taqprojectsubjectcategory
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectsubjectcategory table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectsubjectcategory
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectsubjectcategory table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectmisc
  PRINT 'Deleting taqprojectmisc...'

  SELECT @count_var = count(*)
    FROM taqprojectmisc
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectmisc table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectmisc
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectmisc table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectprice
  PRINT 'Deleting taqprojectprice...'

  SELECT @count_var = count(*)
    FROM taqprojectprice
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectprice table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectprice
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectprice table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectqtybreakdown
  PRINT 'Deleting taqprojectqtybreakdown...'

  SELECT @count_var = count(*)
    FROM taqprojectqtybreakdown
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectqtybreakdown table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectqtybreakdown
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectqtybreakdown table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojectrelationship
  PRINT 'Deleting taqprojectrelationship...'

  SELECT @count_var = count(*)
    FROM taqprojectrelationship
   WHERE taqprojectkey1 = @i_projectkey OR taqprojectkey2 = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojectrelationship table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqprojectrelationship
    WHERE taqprojectkey1 = @i_projectkey OR taqprojectkey2 = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojectrelationship table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqprojecttask 
  PRINT 'Deleting taqprojecttask...'

  -- delete rows not associated with title
  SELECT @count_var = count(*)
    FROM taqprojecttask
   WHERE taqprojectkey = @i_projectkey
     AND COALESCE(bookkey,0) <= 0

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN

    PRINT 'Deleting taqprojecttaskoverride...'

    DELETE FROM taqprojecttaskoverride
    WHERE taqelementkey in (SELECT taqelementkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey AND COALESCE(bookkey,0) <= 0)
      AND taqtaskkey in (SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey AND COALESCE(bookkey,0) <= 0)

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojecttaskoverride table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
    
    DELETE FROM taqprojecttask
    WHERE taqprojectkey = @i_projectkey
      AND COALESCE(bookkey,0) <= 0
 
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- remove link to project if associated with title
  SELECT @count_var = count(*)
    FROM taqprojecttask
   WHERE taqprojectkey = @i_projectkey
     AND bookkey > 0

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    UPDATE taqprojecttask
       SET taqprojectkey = 0
     WHERE taqprojectkey = @i_projectkey
       AND bookkey > 0
 
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error updating taqprojecttask table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- taqproductnumbers
  PRINT 'Deleting taqproductnumbers...'

  SELECT @count_var = count(*)
    FROM taqproductnumbers
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqproductnumbers table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqproductnumbers
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqproductnumbers table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END  
  
  -- P&L details - only for Acqisition projects
  SELECT @count_var = COUNT(*)
  FROM taqversion
  WHERE taqprojectkey = @i_projectkey
  
  IF @count_var > 0
  BEGIN
    PRINT 'Deleting P&L Details...'
    
    -- Loop through all versions on the project to delete each
    DECLARE versions_cur CURSOR FOR
      SELECT plstagecode, taqversionkey
      FROM taqversion
      WHERE taqprojectkey = @i_projectkey
      
    OPEN versions_cur
    
    FETCH versions_cur INTO @v_plstage, @v_plversion

    WHILE (@@FETCH_STATUS=0)
    BEGIN
    
      EXEC qpl_delete_version @i_projectkey, @v_plstage, @v_plversion, @o_error_code output, @o_error_desc output
    
      SELECT @error_var = @@error
      IF @error_var <> 0 BEGIN
        SET @errormsg_var = 'Unable to Delete Project: Error calling qpl_delete_version procedure (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END
      
      FETCH versions_cur INTO @v_plstage, @v_plversion
    END
    
    CLOSE versions_cur
    DEALLOCATE versions_cur
      
    -- Delete from taqplstage
    SELECT @count_var = count(*)
    FROM taqplstage
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error accessing taqplstage table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
    IF @count_var > 0 BEGIN
      DELETE FROM taqplstage
      WHERE taqprojectkey = @i_projectkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to Delete Project: Error deleting taqplstage table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END 
    END    
  END
  

  -- taqproject
  PRINT 'Deleting taqproject...'

  SELECT @count_var = count(*)
    FROM taqproject
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing taqproject table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    DELETE FROM taqproject
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting taqproject table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END

  -- coreprojectinfo 
  PRINT 'Deleting coreprojectinfo...'

  SELECT @count_var = count(*)
    FROM coreprojectinfo
   WHERE projectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @is_error_var = 1
    SET @o_error_code = -1
    SET @errormsg_var = 'Unable to Delete Project: Error accessing coreprojectinfo table (' + cast(@error_var AS VARCHAR) + ').'
    GOTO ExitHandler
  END 
  IF @count_var > 0 BEGIN
    -- write to audit table
    INSERT INTO taqprojectdeleteaudit (projectkey,projecttitle,projectstatus,projectstatusdesc,projectownerkey,
        projectowner,projecttype,projecttypedesc,projectseries,projectseriesdesc,projectparticipants,refreshind,
        lastmaintdate,projectheaderorg1key,projectheaderorg1desc,projectheaderorg2key,projectheaderorg2desc,
        primaryformatseason,primaryformatseasondesc,privateind,subsidyind,primaryformatdiscount,primaryformatdiscountdesc,
        deleteuserid,deletedate) 
    SELECT projectkey,projecttitle,projectstatus,projectstatusdesc,projectownerkey,projectowner,projecttype,projecttypedesc,
	   projectseries,projectseriesdesc,projectparticipants,refreshind,lastmaintdate,projectheaderorg1key,projectheaderorg1desc,
	   projectheaderorg2key,projectheaderorg2desc,primaryformatseason,primaryformatseasondesc,privateind,subsidyind,
	   primaryformatdiscount,primaryformatdiscountdesc,@lastuserid_var,getdate()
      FROM coreprojectinfo
     WHERE projectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error inserting to taqprojectdeleteaudit table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 

    DELETE FROM coreprojectinfo
    WHERE projectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to Delete Project: Error deleting coreprojectinfo table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END


  -- New for case 14193

-- taqversionspeccategory and taqversionspecitems
  PRINT 'Deleting taqversionspeccategory and taqversionspecitems...'

  DECLARE speccategory_cursor CURSOR FOR
	SELECT taqversionspecategorykey
	FROM taqversionspeccategory
	WHERE taqprojectkey = @i_projectkey 

	OPEN speccategory_cursor

	FETCH speccategory_cursor
	INTO @v_categorykey

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		DELETE FROM taqversionspecitems
		WHERE taqversionspecategorykey = @v_categorykey
		
		SELECT @error_var = @@ERROR
		IF @error_var <> 0 BEGIN
			SET @errormsg_var = 'Error deleting from taqversionspecitems table (Error ' + cast(@error_var AS VARCHAR) + ').'
			GOTO ExitHandler
		END  
		
		DELETE FROM taqversionspeccategory
		WHERE taqversionspecategorykey = @v_categorykey
		
		SELECT @error_var = @@ERROR
		IF @error_var <> 0 BEGIN
			SET @errormsg_var = 'Error deleting from taqversionspeccategory table (Error ' + cast(@error_var AS VARCHAR) + ').'
			GOTO ExitHandler
		END  
		
		FETCH speccategory_cursor
		INTO @v_categorykey
	END

	CLOSE speccategory_cursor
	DEALLOCATE speccategory_cursor 


  -- taqprojectscalerowvalues
  PRINT 'Deleting taqprojectscalerowvalues...'

  SELECT @count_var = count(*)
    FROM taqprojectscalerowvalues
    WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0
    BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 
        'Unable to Delete Project: Error accessing taqprojectscalerowvalues table (' + 
        cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END
  IF @count_var > 0
    BEGIN
      DELETE
        FROM taqprojectscalerowvalues
        WHERE taqprojectkey = @i_projectkey

      SELECT @error_var = @@ERROR,
             @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0
        BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 
            'Unable to Delete Project: Error deleting taqprojectscalerowvalues table (' + 
            cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END
    END

  -- taqprojectscalecolumnvalues
  PRINT 'Deleting taqprojectscalecolumnvalues...'

  SELECT @count_var = count(*)
    FROM taqprojectscalecolumnvalues
    WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0
    BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 
        'Unable to Delete Project: Error accessing taqprojectscalecolumnvalues table (' + 
        cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END
  IF @count_var > 0
    BEGIN
      DELETE
        FROM taqprojectscalecolumnvalues
        WHERE taqprojectkey = @i_projectkey

      SELECT @error_var = @@ERROR,
             @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0
        BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 
            'Unable to Delete Project: Error deleting taqprojectscalecolumnvalues table (' 
            + cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END
    END

  -- taqprojectscaledetails
  PRINT 'Deleting taqprojectscaledetails...'

  SELECT @count_var = count(*)
    FROM taqprojectscaledetails
    WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0
    BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 
        'Unable to Delete Project: Error accessing taqprojectscaledetails table (' + cast(
        @error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END
  IF @count_var > 0
    BEGIN
      DELETE
        FROM taqprojectscaledetails
        WHERE taqprojectkey = @i_projectkey

      SELECT @error_var = @@ERROR,
             @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0
        BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 
            'Unable to Delete Project: Error deleting taqprojectscaledetails table (' + 
            cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END
    END

  -- taqprojectscaleorgentry
  PRINT 'Deleting taqprojectscaleorgentry...'

  SELECT @count_var = count(*)
    FROM taqprojectscaleorgentry
    WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0
    BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 
        'Unable to Delete Project: Error accessing taqprojectscaleorgentry table (' + cast
        (@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END
  IF @count_var > 0
    BEGIN
      DELETE
        FROM taqprojectscaleorgentry
        WHERE taqprojectkey = @i_projectkey

      SELECT @error_var = @@ERROR,
             @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0
        BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 
            'Unable to Delete Project: Error deleting taqprojectscaleorgentry table (' + 
            cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END
    END

  -- taqprojectscaleparameters
  PRINT 'Deleting taqprojectscaleparameters...'

  SELECT @count_var = count(*)
    FROM taqprojectscaleparameters
    WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0
    BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 
        'Unable to Delete Project: Error accessing taqprojectscaleparameters table (' + 
        cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END
  IF @count_var > 0
    BEGIN
      DELETE
        FROM taqprojectscaleparameters
        WHERE taqprojectkey = @i_projectkey

      SELECT @error_var = @@ERROR,
             @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0
        BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 
            'Unable to Delete Project: Error deleting taqprojectscaleparameters table (' + 
            cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END
    END

  -- corescaleparameters
  PRINT 'Deleting corescaleparameters...'

  SELECT @count_var = count(*)
    FROM corescaleparameters
    WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0
    BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 
        'Unable to Delete Project: Error accessing corescaleparameters table (' + cast(
        @error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END
  IF @count_var > 0
    BEGIN
      DELETE
        FROM corescaleparameters
        WHERE taqprojectkey = @i_projectkey

      SELECT @error_var = @@ERROR,
             @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0
        BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 
            'Unable to Delete Project: Error deleting corescaleparameters table (' + cast(
            @error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END
    END

  -- End - New for case 14193
  COMMIT
    
  -- 9/28/06 - KW - When project was successfully deleted from the database, 
  -- delete this project from any existing lists of projects (for all users)
  -- 3/21/12 - Case 18667 - Deleted project should be removed from all project-like search type lists:
  -- Projects (searchtype=7), P&L Templates (17), Journals (18), Works (22), Scales (24), Contracts (25)
  DELETE FROM qse_searchresults
  WHERE key1 = @i_projectkey AND
    listkey IN (SELECT listkey FROM qse_searchlist 
                WHERE searchtypecode IN (7,17,18,22,24,25) AND saveascriteriaind = 0)
                  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Project was successfully deleted, but it could not be removed from existing lists (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END   


  ExitHandler:
  IF @is_error_var = 1 BEGIN
    ROLLBACK
    SET @o_error_desc = @errormsg_var
    RETURN
  END
GO

GRANT EXEC ON qproject_delete_project_desktop TO PUBLIC
GO
