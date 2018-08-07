if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_add_taqprojecttask_newelem') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_add_taqprojecttask_newelem
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_add_taqprojecttask_newelem
  (@i_taskviewkey integer,
  @i_projectkey  integer,
  @i_taqelementkey  integer,
  @i_elementtypecode integer,
  @i_bookkey  integer,
  @i_userid varchar(30),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_add_taqprojecttask_newelem
**  Desc: This stored procedure adds all tasks associated with the newly added
**        element. If the new element is Manuscript, a row is also added
**        to taqprojectreaderiteration table for each active Reader.
**
**    Auth: Kate
**    Date: 9/28/04
*******************************************************************************
**    Auth: Alan Katzen
**    Date: 6/17/08
**
**    Revised to use new schema and business logic.  Taskviewkey will be 
**    passed in (app will pick taskgroups).  Also, elements can be added
**    for titles.
*******************************************************************************/

DECLARE
  @v_userkey  INT,
  @v_taqprojectcontactrolekey INT,
  @v_rolecode INT,
  @v_roleautoind  TINYINT,
  @v_datetypecode INT,
  @v_taqkeyind  TINYINT,
  @v_manuscriptcode INT,
  @v_readerrolecode INT,
  @v_error  INT,
  @v_rowcount INT,
  @v_cnt INT,
  @v_globalcontactkey INT  
  
BEGIN
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  /** Get userkey for the given userid passed **/
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE UPPER(userid) = UPPER(@i_userid)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Error getting userkey for userid ' + CAST(@i_userid AS VARCHAR) +'.'
    GOTO RETURN_ERROR
  END  
  
  /** Get the elementtypecode for 'Manuscript' for comparison **/
  SELECT @v_manuscriptcode = datacode
  FROM gentables
  WHERE tableid = 287 AND qsicode = 1

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Error getting datacode for Manuscript (gentables 287, qsicode=1).'
    GOTO RETURN_ERROR
  END
  
  /** Get the rolecode for 'Reader' (gentable 285, qsicode=3) **/
  SELECT @v_readerrolecode = datacode
  FROM gentables 
  WHERE tableid = 285 AND qsicode = 3
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Error getting rolecode for Reader (gentables 285, qsicode=3).'
    GOTO RETURN_ERROR
  END
  
  --PRINT 'manuscriptcode=' + CAST(@v_manuscriptcode AS VARCHAR)
  --PRINT 'readercode=' + CAST(@v_readerrolecode AS VARCHAR)  
  
  IF @i_projectkey > 0 BEGIN
  
    /*** TAQPROJECTREADERITERATION ***/
    /*** For each participant of type Reader and element of type Manuscript ***/
    IF @i_elementtypecode = @v_manuscriptcode
    BEGIN
    
      /* Check if records already exists for this element - taqprojectreaderiteration record may have already been added in qproject_add_manuscript_iteration */
      SELECT @v_cnt = COUNT(*)
      FROM taqprojectreaderiteration
      WHERE taqprojectkey = @i_projectkey AND taqelementkey = @i_taqelementkey  
      
      IF @v_cnt = 0
      BEGIN
          
        /** Declare a cursor for all ACTIVE readers on this project **/
        DECLARE participant_iteration_cur CURSOR FOR
          SELECT taqprojectcontactrolekey 
          FROM taqprojectcontactrole 
          WHERE taqprojectkey = @i_projectkey AND
            rolecode = @v_readerrolecode AND
            activeind = 1
        
        OPEN participant_iteration_cur

        FETCH NEXT FROM participant_iteration_cur INTO @v_taqprojectcontactrolekey

        WHILE (@@FETCH_STATUS = 0) BEGIN
        
          /* Insert row into TAQPROJECTREADERITERATION table **/
          EXEC qproject_add_taqprojectreaderiteration @i_projectkey,
            @v_taqprojectcontactrolekey, @i_taqelementkey, @i_userid,
            @o_error_code OUTPUT, @o_error_desc OUTPUT
          
          /* Exit participant cursor if occur occurs */
          IF @o_error_code <> 0
            BREAK
        
          FETCH NEXT FROM participant_iteration_cur INTO @v_taqprojectcontactrolekey
        END
        
        CLOSE participant_iteration_cur 
        DEALLOCATE participant_iteration_cur
        
        /* Exit if error occurred above */
        IF @o_error_code <> 0
          RETURN
        
      END /* IF @v_cnt = 0 */
    END /* IF @i_elementtypecode = @v_manuscriptcode */
  END /* IF @i_projectkey >  0 */

  SELECT @v_rolecode = rolecode, @v_roleautoind = roleautoind
  FROM taskview 
  WHERE taskviewkey = @i_taskviewkey

  --PRINT 'taskviewkey=' + CAST(@i_taskviewkey AS VARCHAR)
  --PRINT 'elementtypecode=' + CAST(@i_elementtypecode AS VARCHAR)
  --PRINT 'rolecode=' + CAST(@v_rolecode AS VARCHAR)

  /** Declare a cursor for all dates for the given task group/view **/
  DECLARE taskviewdate_cur CURSOR FOR
    SELECT vd.datetypecode, vd.keyind
    FROM taskviewdatetype vd, datetype d
    WHERE vd.datetypecode = d.datetypecode AND
        vd.taskviewkey = @i_taskviewkey
    ORDER BY vd.sortorder
    
  OPEN taskviewdate_cur

  FETCH NEXT FROM taskviewdate_cur INTO @v_datetypecode, @v_taqkeyind

  WHILE (@@FETCH_STATUS = 0) BEGIN      
    --PRINT 'datetypecode=' + CAST(@v_datetypecode AS VARCHAR)
    
    /* If rolecode is filled in for the task group/view and auto indicator is on, */
    /* must insert each task for this task group for each participant of that Role */
    IF (@v_rolecode > 0 AND @v_roleautoind = 1) BEGIN
      /* Declare a cursor for all ACTIVE participants of the given role type */
      -- Projects
      IF @i_projectkey > 0 BEGIN
        DECLARE participant_task_cur CURSOR FOR
         SELECT pc.globalcontactkey
           FROM taqprojectcontactrole pcr, taqprojectcontact pc 
          WHERE pcr.taqprojectcontactkey = pc.taqprojectcontactkey AND
                pcr.taqprojectkey = @i_projectkey AND
                pcr.rolecode = @v_rolecode AND
                pcr.activeind = 1

        OPEN participant_task_cur

        FETCH NEXT FROM participant_task_cur INTO @v_globalcontactkey

        WHILE (@@FETCH_STATUS = 0) BEGIN        
          --PRINT 'globalcontactkey=' + CAST(@v_globalcontactkey AS VARCHAR)
          
          /* Insert each task into TAQPROJECTTASK table */
          EXEC qproject_add_taqprojecttask @i_projectkey, @i_taqelementkey,
            @v_globalcontactkey, @v_rolecode, @v_datetypecode, @v_taqkeyind, @i_userid, 
            @i_taskviewkey, @i_bookkey, @o_error_code OUTPUT, @o_error_desc OUTPUT
            
          /* Exit participant cursor when error occurs */
          IF @o_error_code <> 0
            BREAK  

          FETCH NEXT FROM participant_task_cur INTO @v_globalcontactkey
        END
        
        CLOSE participant_task_cur 
        DEALLOCATE participant_task_cur
      END

      -- Titles
      IF @i_bookkey > 0 BEGIN
        DECLARE bookparticipant_task_cur CURSOR FOR
         SELECT bc.globalcontactkey
           FROM bookcontactrole bcr, bookcontact bc 
          WHERE bcr.bookcontactkey = bc.bookcontactkey AND
                bc.bookkey = @i_bookkey AND
                bc.printingkey = 1 AND
                bcr.rolecode = @v_rolecode AND
                bcr.activeind = 1

        OPEN bookparticipant_task_cur

        FETCH NEXT FROM bookparticipant_task_cur INTO @v_globalcontactkey

        WHILE (@@FETCH_STATUS = 0) BEGIN        
          --PRINT 'contactrolekey=' + CAST(@v_taqprojectcontactrolekey AS VARCHAR)

          /* Insert each task into TAQPROJECTTASK table */
          EXEC qproject_add_taqprojecttask @i_projectkey, @i_taqelementkey,
            @v_globalcontactkey,@v_rolecode, @v_datetypecode, @v_taqkeyind, @i_userid, 
            @i_taskviewkey, @i_bookkey, @o_error_code OUTPUT, @o_error_desc OUTPUT
            
          /* Exit participant cursor when error occurs */
          IF @o_error_code <> 0
            BREAK  

          FETCH NEXT FROM bookparticipant_task_cur INTO @v_taqprojectcontactrolekey
        END
        
        CLOSE bookparticipant_task_cur 
        DEALLOCATE bookparticipant_task_cur
      END         
    END --@v_rolecode > 0 AND @v_roleautoind = 1
    
    ELSE BEGIN -- (no rolecode) 
      --PRINT '(no role)'
      
      /* Insert each task into TAQPROJECTTASK table */
      EXEC qproject_add_taqprojecttask @i_projectkey, @i_taqelementkey,
        NULL, NULL, @v_datetypecode, @v_taqkeyind, @i_userid, 
        @i_taskviewkey, @i_bookkey, @o_error_code OUTPUT, @o_error_desc OUTPUT          
    END
    
    /* Exit taskviewdate cursor when error occurs */
    IF @o_error_code <> 0
      BREAK       
    
    /* Fetch next task group date */
    FETCH NEXT FROM taskviewdate_cur INTO @v_datetypecode, @v_taqkeyind

  END	/* @@FETCH_STATUS=0 - taskviewdatetype cursor */
  
  CLOSE taskviewdate_cur 
  DEALLOCATE taskviewdate_cur    
	  
  RETURN  

RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN

END
GO

GRANT EXEC ON qproject_add_taqprojecttask_newelem TO PUBLIC
GO