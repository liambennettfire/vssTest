if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_delete_tasks') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_delete_tasks
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*
declare @err int,
        @dsc varchar(2000)
exec qcontact_delete_tasks 566886, 1, 591816, 0, 0, 18, 'qsiadmin', 1, @err, @dsc
*/

CREATE PROCEDURE qcontact_delete_tasks
  (@i_bookkey  integer,
  @i_printingkey integer,
  @i_globalcontactkey  integer,
  @i_projectkey integer,
  @i_projectcontactkey integer,
  @i_rolecode  integer,
  @i_userid varchar(30),
  @i_deleterecords smallint,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_delete_tasks
**  Desc: This stored procedure deletes all task records OR 
**        clears the globalcontactkey based on the following  
**        criteria from Susan:
**         
**      If the role being deleted is the only role for this participant for 
**      this title or project, then get all tasks that are for this title 
**      (or project) for the contact in either globalcontact or globalcontact2.  
**      If the role being deleted is not the only role for this participant 
**      for this title or project, then get all tasks that are for this title 
**      (or project) for the contact in either globalcontact or globalcontact2 
**      and the role matches the one being deleted.   For each task found that 
**      there is a second contact (whether it be globalcontact or globalcontact2), 
**      remove the contact key for the contact being  deleted but leave the task; 
**      if there are tasks where they are the only contact, ask the user if they 
**      want  to delete the tasks or remove the contact from the tasks.  Whatever 
**      they choose will be true for all tasks on which they are the only contact.
**
**    Auth: Lisa
**    Date: 10/01/08
**
*******************************************************************************/

DECLARE
  @v_taskviewkey  INT,
  @v_userkey INT,
  @v_globalcontactkey INT,
  @v_error  INT,
  @v_rowcount INT    
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  /** Get userkey for the given userid passed **/
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE Upper(userid) = Upper(@i_userid)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Error getting userkey for userid ' + CAST(@i_userid AS VARCHAR) + '.'
    GOTO RETURN_ERROR
  END  
  
  /***********************************************************************************
  ************************************************************************************
  **
  **    Processing Book/Title contact
  **
  ************************************************************************************
  ************************************************************************************/
  IF ( isNull(@i_bookkey,0) > 0 and isNull(@i_printingkey,0) > 0 )
  BEGIN
    -- Get GlobalContactKey
    SELECT @v_globalcontactkey = @i_globalcontactkey
                          
    IF ( isNull(@v_globalcontactkey,0) <= 0 )
    BEGIN
        SET @o_error_desc = 'Error getting globalcontactkey for bookcontactkey ' + CAST(@v_globalcontactkey AS VARCHAR) + '.'
        PRINT @o_error_desc
        GOTO RETURN_ERROR
    END
 
    -- If the user asked to delete the records, do that first ONLY if there is 1 contact on the record                                   
    IF ( isNull(@i_deleterecords,0) > 0 )
    BEGIN
       /** Delete TASKS for Bookkey  **/
       IF ( isNull(@i_rolecode,0) > 0 ) -- use rolecode in check
       BEGIN  
       
         DELETE FROM taqprojecttaskoverride where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey = @v_globalcontactkey
                                                    AND rolecode = @i_rolecode
                                                    AND isNull(globalcontactkey2,0) <= 0 )         
                                        
         DELETE FROM taqprojecttask where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey = @v_globalcontactkey
                                                    AND rolecode = @i_rolecode
                                                    AND isNull(globalcontactkey2,0) <= 0 )

         DELETE FROM taqprojecttaskoverride where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey2 = @v_globalcontactkey
                                                    AND rolecode2 = @i_rolecode
                                                    AND isNull(globalcontactkey,0) <= 0 )                                                     
                                                                                                      
         DELETE FROM taqprojecttask where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey2 = @v_globalcontactkey
                                                    AND rolecode2 = @i_rolecode
                                                    AND isNull(globalcontactkey,0) <= 0 )                                                                                                       
       END
       ELSE -- no rolecode, delete all for this bookkey, printingkey, globalcontactkey
       BEGIN       
         DELETE FROM taqprojecttaskoverride where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey = @v_globalcontactkey
                                                    AND isNull(globalcontactkey2,0) <= 0 )
                                                           
         DELETE FROM taqprojecttask where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey = @v_globalcontactkey
                                                    AND isNull(globalcontactkey2,0) <= 0 )                                                                                                       

         DELETE FROM taqprojecttaskoverride where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey2 = @v_globalcontactkey
                                                    AND isNull(globalcontactkey,0) <= 0 ) 
                                                    
         DELETE FROM taqprojecttask where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey2 = @v_globalcontactkey
                                                    AND isNull(globalcontactkey,0) <= 0 )                                                                                                       
       END
       
    END -- IF ( @i_deleterecords = 1 )
                                                                                                                   
    -- If user chose the delete option, records deleted above had only 1 contact associated.
    -- The only records left would have multiple contacts associated or we just fell through 
    -- because the user chose not to delete.  Update all the associated globalcontact and 
    -- globalcontact2 columns.
    
    /** Clearing task globalcontact columns **/
    
    IF ( isNull(@i_rolecode,0) > 0 ) -- use rolecode in check
    BEGIN
        UPDATE taqprojecttask SET GlobalContactKey = NULL
         WHERE taqtaskkey in ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND rolecode = @i_rolecode
                                                    AND globalcontactkey = @v_globalcontactkey )

        UPDATE taqprojecttask SET GlobalContactKey2 = NULL
         WHERE taqtaskkey in ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND rolecode2 = @i_rolecode
                                                    AND globalcontactkey2 = @v_globalcontactkey )
    END
    ELSE -- no rolecode
    BEGIN
        UPDATE taqprojecttask SET GlobalContactKey = NULL
         WHERE taqtaskkey in ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey = @v_globalcontactkey )

        UPDATE taqprojecttask SET GlobalContactKey2 = NULL
         WHERE taqtaskkey in ( SELECT taqtaskkey FROM taqprojecttask WHERE bookkey = @i_bookkey 
                                                    AND printingkey = @i_printingkey
                                                    AND globalcontactkey2 = @v_globalcontactkey )
    END                                          
   END

  /***********************************************************************************
  ************************************************************************************
  **
  **    Processing Project contact
  **
  ************************************************************************************
  ************************************************************************************/

  ELSE IF ( isNull(@i_projectkey,0) > 0 )
  BEGIN
      -- Get GlobalContactKey
    SELECT @v_globalcontactkey = @i_globalcontactkey 
                                      
    IF ( isNull(@v_globalcontactkey,0) <= 0 )
    BEGIN
        SET @o_error_desc = 'Error getting globalcontactkey for projectkey ' + CAST(@i_projectkey AS VARCHAR) + '.'
        PRINT @o_error_desc
        GOTO RETURN_ERROR
    END

    -- If the user asked to delete the records, do that first ONLY if there is 1 contact on the record                                   
    IF ( isNull(@i_deleterecords,0) > 0 )
    BEGIN

       /** Delete TASKS for projectkey  **/
       IF ( isNull(@i_rolecode,0) > 0 ) -- use rolecode in check
       BEGIN
         DELETE FROM taqprojecttaskoverride where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey 
                                                    AND globalcontactkey = @v_globalcontactkey
                                                    AND rolecode = @i_rolecode
                                                    AND isNull(globalcontactkey2,0) <= 0 )
                                                                                                     
         DELETE FROM taqprojecttask where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey 
                                                    AND globalcontactkey = @v_globalcontactkey
                                                    AND rolecode = @i_rolecode
                                                    AND isNull(globalcontactkey2,0) <= 0 )   

         DELETE FROM taqprojecttaskoverride where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey
                                                    AND globalcontactkey2 = @v_globalcontactkey
                                                    AND rolecode2 = @i_rolecode
                                                    AND isNull(globalcontactkey,0) <= 0 )                                                                                                       
                                                                                                        
         DELETE FROM taqprojecttask where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey
                                                    AND globalcontactkey2 = @v_globalcontactkey
                                                    AND rolecode2 = @i_rolecode
                                                    AND isNull(globalcontactkey,0) <= 0 )                                                                                                      
       END
       ELSE -- no rolecode, delete all for this bookkey, printingkey, globalcontactkey
       BEGIN
         DELETE FROM taqprojecttaskoverride where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey 
                                                    AND globalcontactkey = @v_globalcontactkey
                                                    AND isNull(globalcontactkey2,0) <= 0 )
                                                           
         DELETE FROM taqprojecttask where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey 
                                                    AND globalcontactkey = @v_globalcontactkey
                                                    AND isNull(globalcontactkey2,0) <= 0 )       
                                                    
         DELETE FROM taqprojecttaskoverride where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey 
                                                    AND globalcontactkey2 = @v_globalcontactkey
                                                    AND isNull(globalcontactkey,0) <= 0 )                                                                                                   
                                                                                                        
         DELETE FROM taqprojecttask where taqtaskkey in
          ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey 
                                                    AND globalcontactkey2 = @v_globalcontactkey
                                                    AND isNull(globalcontactkey,0) <= 0 )                                                                                                     
       END
       
    END
                                                                                                                   
    -- If user chose the delete option, records deleted above had only 1 contact associated.
    -- The only records left would have multiple contacts associated or we just fell through 
    -- because the user chose not to delete.  Update all the associated globalcontact and 
    -- globalcontact2 columns.
    
    /** Clearing task globalcontact columns **/
    
    IF ( isNull(@i_rolecode,0) > 0 ) -- use rolecode in check
    BEGIN
        UPDATE taqprojecttask SET GlobalContactKey = NULL
         WHERE taqtaskkey in ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey 
                                                    AND rolecode = @i_rolecode
                                                    AND globalcontactkey = @v_globalcontactkey )

         UPDATE taqprojecttask SET GlobalContactKey2 = NULL
         WHERE taqtaskkey in ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey 
                                                    AND rolecode2 = @i_rolecode
                                                    AND globalcontactkey2 = @v_globalcontactkey )
    END
    ELSE -- no rolecode
    BEGIN
        UPDATE taqprojecttask SET GlobalContactKey = NULL
         WHERE taqtaskkey in ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey
                                                    AND globalcontactkey = @v_globalcontactkey )

        UPDATE taqprojecttask SET GlobalContactKey2 = NULL
         WHERE taqtaskkey in ( SELECT taqtaskkey FROM taqprojecttask WHERE taqprojectkey = @i_projectkey
                                                    AND globalcontactkey2 = @v_globalcontactkey )
    END                                          
  END
  
  /***********************************************************************************
  ************************************************************************************
  **
  **    fall through to error?...
  **
  ************************************************************************************
  ************************************************************************************/

--  ELSE -- error???, no bookkey or projectkey
--  BEGIN
--    SET @o_error_desc = 'Error no valid key was passed to qcontact_delete_tasks() '
--    GOTO RETURN_ERROR
--  END
    
  RETURN
  
RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN

END
GO

GRANT EXEC ON qcontact_delete_tasks TO PUBLIC
GO


