if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_delete_project_participant_by_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_delete_project_participant_by_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcontact_delete_project_participant_by_role
  (@i_projectkey integer,
  @i_projectcontactkey integer,
  @i_globalcontactkey integer, 
  @i_rolecode integer, 
  @i_userid varchar(30),
  @i_deleterecords smallint,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_delete_project_participant_by_role
**  Desc: This stored procedure deletes all taqprojectelement records OR 
**        clears the globalcontactkey based on user preference.
**
**    Auth: Uday A. Khisty
**    Date: 09/04/14
**
*******************************************************************************/

DECLARE
  @v_userkey INT,
  @v_error  INT,
  @v_rowcount INT,    
  @v_taqprojectcontactkey INT
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  /** Get userkey for the given userid passed **/
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE Upper(userid) = Upper(@i_userid)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error getting userkey for userid ' + CAST(@i_userid AS VARCHAR) + '.'
    GOTO RETURN_ERROR
  END  
  
  SELECT @v_taqprojectcontactkey = taqprojectcontactkey 
  FROM taqprojectcontactrole 
  WHERE taqprojectcontactrolekey = @i_projectcontactkey
   
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error getting taqprojectcontactkey from taqprojectcontactrole.taqprojectcontactrolekey ' + CAST(@i_projectcontactkey AS VARCHAR) + '.'
    GOTO RETURN_ERROR
  END     
   
  DELETE FROM taqprojectcontactrole WHERE taqprojectcontactrolekey = @i_projectcontactkey
   
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error deleting taqprojectcontactkey from taqprojectcontactrole.taqprojectcontactrolekey ' + CAST(@i_projectcontactkey AS VARCHAR) + '.'
    GOTO RETURN_ERROR
  END     

  IF @i_deleterecords < 3 -- 3 means we are updating existing tasks with a new contact
  BEGIN
    EXEC qcontact_delete_tasks 0, 0, @i_globalcontactkey,
                               @i_projectkey, @i_projectcontactkey, @i_rolecode, 
                               @i_userid, @i_deleterecords, @o_error_code output, @o_error_desc output
                               
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Unable to delete tasks: : Error calling qcontact_delete_tasks procedure ( ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
    END                               
    
    DELETE FROM taqprojectreaderiteration 
    WHERE taqprojectkey = @i_projectKey AND taqprojectcontactrolekey = @i_projectcontactkey
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Error deleting taqprojectreaderiteration for project ' + CAST(@i_projectKey AS VARCHAR) +  'from taqprojectreaderiteration.taqprojectcontactrolekey ' + CAST(@i_projectcontactkey AS VARCHAR) + '.'
      GOTO RETURN_ERROR
    END       
     
    IF NOT EXISTS(SELECT * FROM taqprojectcontactrole WHERE taqprojectcontactkey = @v_taqprojectcontactkey) BEGIN
      /** Call procedure that will delete Element and Task records **/
      EXEC qcontact_delete_elements 0, 0, 0, @i_projectkey, 
                    @i_projectcontactkey, @i_globalcontactkey, @i_userid, @i_deleterecords,
                    @o_error_code output, @o_error_desc output	
                    
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Unable to delete elements: : Error calling qpl_delete_version procedure ( ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
      END    									
                    
      DELETE FROM taqprojectcontact WHERE taqprojectcontactkey = @v_taqprojectcontactkey	
      
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Error deleting taqprojectcontact from taqprojectcontact.taqprojectcontactkey ' + CAST(@v_taqprojectcontactkey AS VARCHAR) + '.'
      GOTO RETURN_ERROR
      END 	  									
    END
  END
  
  RETURN
    
RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN

END
GO

GRANT EXEC ON qcontact_delete_project_participant_by_role TO PUBLIC
GO


