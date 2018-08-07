if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_add_taqprojecttask_newrole') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_add_taqprojecttask_newrole
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_add_taqprojecttask_newrole
  (@i_projectkey  integer,
  @i_contactrolekey  integer,
  @i_rolecode  integer,
  @i_userid varchar(30),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_add_taqprojecttask_newrole
**  Desc: This stored procedure adds all tasks associated with the newly added
**        participant role. If the new participant is Reader, a row is also added
**        to taqprojectreaderiteration table for the current Manuscript Iteration.
**
**    Auth: Kate
**    Date: 9/28/04
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**	  03/07/2016  Uday A. Khisty  Case 36706
*******************************************************************************/

DECLARE
  @v_userkey  INT,
  @v_taskviewkey  INT,
  @v_elementtypecode  INT,
  @v_elementautoind TINYINT,
  @v_taqelementnumber INT,
  @v_taqelementkey  INT,
  @v_manuscriptcode INT,
  @v_iterationcode  INT,
  @v_readerrolecode INT,
  @v_datetypecode INT,
  @v_taqkeyind TINYINT,
  @v_error  INT,
  @v_rowcount INT,
  @v_globalcontactkey INT   
  
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
  
  /** Get the elementtypecode for 'Manuscript' **/
  SELECT @v_manuscriptcode = datacode
  FROM gentables
  WHERE tableid = 287 AND qsicode = 1

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Error getting elementtypecode for Manuscript (gentables 287, qsicode=1).'
    GOTO RETURN_ERROR
  END
    
  /** Get the elementtypesubcode for 'Iteration' (subgentable 287, qsicode=1) **/
  SELECT @v_iterationcode = datasubcode
  FROM subgentables
  WHERE tableid = 287 AND datacode = @v_manuscriptcode AND qsicode = 1
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Could not get elementtypesubcode for Iteration (subgentable 287, qsicode=1).'
    GOTO RETURN_ERROR
  END
  
  /** Get the rolecode for 'Reader' (gentable 285, qsicode=1) **/
  SELECT @v_readerrolecode = datacode
  FROM gentables 
  WHERE tableid = 285 AND qsicode = 3
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Error getting rolecode for Reader (gentables 285, qsicode=3).'
    GOTO RETURN_ERROR
  END
    
  SELECT @v_globalcontactkey = pc.globalcontactkey
    FROM taqprojectcontactrole pcr, taqprojectcontact pc 
   WHERE pcr.taqprojectcontactkey = pc.taqprojectcontactkey AND
         pcr.taqprojectcontactrolekey = @i_contactrolekey AND
         pcr.taqprojectkey = @i_projectkey AND
         pcr.rolecode = @i_rolecode

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error getting globalcontactkey.'
    GOTO RETURN_ERROR
  END
    
  --DEBUG
  --PRINT 'contactrolekey=' + CAST(@i_contactrolekey AS VARCHAR)
  --PRINT 'globalcontactkey=' + CAST(@v_globalcontactkey AS VARCHAR)
  --PRINT 'manuscriptcode=' + CAST(@v_manuscriptcode AS VARCHAR)
  --PRINT 'iterationcode=' + CAST(@v_iterationcode AS VARCHAR)
  --PRINT 'readercode=' + CAST(@v_readerrolecode AS VARCHAR)
  
  /* Get the maximum element number currently on taqprojectelement table */
  EXEC qproject_get_max_element_number @i_projectkey, 0, @v_manuscriptcode,
    @v_iterationcode, @v_taqelementnumber OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
    
  --DEBUG
  PRINT 'elementnumber=' + CAST(@v_taqelementnumber AS VARCHAR)
      
  /* Get the elementkey associated with the current manuscript iteration */
  IF @v_taqelementnumber > 0 AND @o_error_code = 0
    BEGIN
      SELECT @v_taqelementkey = taqelementkey
      FROM taqprojectelement
      WHERE taqprojectkey = @i_projectkey AND
          taqelementtypecode = @v_manuscriptcode AND
          taqelementtypesubcode = @v_iterationcode AND
          taqelementnumber = @v_taqelementnumber
        
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_desc = 'Could not get taqelementkey for current iteration.'
        GOTO RETURN_ERROR
      END
    END
  ELSE 
    BEGIN
      IF @i_rolecode = @v_readerrolecode AND @o_error_code = 0
      BEGIN
        /* Add Manuscript Iteration element sice we are adding a Reader */
        /* and since no manuscript iteration element exists on this project */
        EXEC qproject_add_taqprojectelement @i_projectkey, @v_manuscriptcode,
          @v_iterationcode, NULL, @i_userid, @v_taqelementkey OUTPUT,
          @o_error_code OUTPUT, @o_error_desc OUTPUT    
      END        
    END
    
  --DEBUG
  PRINT 'elementkey=' + CAST(@v_taqelementkey AS VARCHAR)
  
  /* Insert new row into TAQPROJECTREADERITERATION table */
  /* for the current iteration if the role added is a Reader */
  IF @i_rolecode = @v_readerrolecode AND @o_error_code = 0
  BEGIN
    EXEC qproject_add_taqprojectreaderiteration @i_projectkey, @i_contactrolekey,
      @v_taqelementkey, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
        
    --DEBUG
    PRINT 'taqprojectreaderiteration added (errorcode=' + CAST(@o_error_code AS VARCHAR) + ')'
  END
  

  /** Declare a cursor for all task groups associated with this role type **/
  /** (for the default user -1 or the current user) **/
  DECLARE taskview_cur CURSOR FOR
    SELECT T.taskviewkey, T.elementtypecode, T.elementautoind
      FROM TaqProject P, TaskView T
     WHERE ( T.usageclasscode = P.Usageclasscode or isNull(T.usageclasscode,0) <= 0 )
       AND ( T.itemtypecode = P.searchitemcode or isNull(T.itemtypecode,0) <= 0 )
       AND ( P.taqprojectkey = @i_projectkey )
       AND ( rolecode = @i_rolecode )
       AND ( roleautoind = 1 )
       AND ( taskgroupind = 1 ) 
       AND ( userkey = -1 OR userkey = @v_userkey )

  OPEN taskview_cur
  
  FETCH NEXT FROM taskview_cur INTO @v_taskviewkey, @v_elementtypecode, @v_elementautoind
  
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
    --DEBUG
    PRINT 'taskviewkey=' + CAST(@v_taskviewkey AS VARCHAR)
    PRINT 'elementtypecode=' + CAST(@v_elementtypecode AS VARCHAR)
	
    /** Declare a cursor for all dates for the given task group/view **/
    DECLARE taskviewdate_cur CURSOR FOR
      SELECT vd.datetypecode, vd.keyind
      FROM taskviewdatetype vd, datetype d
      WHERE vd.datetypecode = d.datetypecode AND
          vd.taskviewkey = @v_taskviewkey
      ORDER BY vd.sortorder    
      
    OPEN taskviewdate_cur

    FETCH NEXT FROM taskviewdate_cur INTO @v_datetypecode, @v_taqkeyind

    WHILE (@@FETCH_STATUS = 0) 
    BEGIN
      --DEBUG
      PRINT 'datetypecode=' + CAST(@v_datetypecode AS VARCHAR)    
      
      /* If elementtype for the task group/view is 'Manuscript' and auto indicator is on, */
      /* insert each task for this task group for each participant of that Role */
      /* but only for CURRENT ITERATION of the manuscript */
      IF @v_elementtypecode = @v_manuscriptcode AND @v_elementautoind = 1
        BEGIN
              
          /* Insert each task into TAQPROJECTTASK table */
          IF @o_error_code = 0
          BEGIN
          
            EXEC qproject_add_taqprojecttask @i_projectkey, @v_taqelementkey,@v_globalcontactkey,
              @i_rolecode, @v_datetypecode, @v_taqkeyind, @i_userid, @v_taskviewkey, 0, 
              @o_error_code OUTPUT, @o_error_desc OUTPUT
              
            --DEBUG
            PRINT 'taqprojecttask added for manuscript (errorcode=' + CAST(@o_error_code AS VARCHAR) + ')'              
          END
          
        END --IF @v_elementtypecode = @v_manuscriptcode AND @v_elementautoind = 1
        
      ELSE IF @v_elementtypecode > 0 AND @v_elementautoind = 1
        BEGIN
          DECLARE element_cur CURSOR FOR
            SELECT taqelementkey
            FROM taqprojectelement
            WHERE taqprojectkey = @i_projectkey AND
                taqelementtypecode = @v_elementtypecode

          OPEN element_cur

          FETCH NEXT FROM element_cur INTO @v_taqelementkey

          WHILE (@@FETCH_STATUS = 0) 
          BEGIN

            /* Insert each task into TAQPROJECTTASK table */
            EXEC qproject_add_taqprojecttask @i_projectkey, @v_taqelementkey,@v_globalcontactkey,
              @i_rolecode, @v_datetypecode, @v_taqkeyind, @i_userid, @v_taskviewkey, 0, 
              @o_error_code OUTPUT, @o_error_desc OUTPUT
              
            --DEBUG
            PRINT 'taqprojecttask added (errorcode=' + CAST(@o_error_code AS VARCHAR) + ')'              
            
            /* Exit element cursor when error occurs */
            IF @o_error_code <> 0 
              BREAK
    
            FETCH NEXT FROM element_cur INTO @v_taqelementkey
          END
          
          CLOSE element_cur 
          DEALLOCATE element_cur
                  
        END --IF @v_elementtypecode > 0 AND @v_elementautoind = 1
      
      ELSE  --@v_elementtypecode IS NULL
        BEGIN
          /* Insert each task into TAQPROJECTTASK table */
          IF @o_error_code = 0
          BEGIN
            EXEC qproject_add_taqprojecttask @i_projectkey, NULL,@v_globalcontactkey,
              @i_rolecode, @v_datetypecode, @v_taqkeyind, @i_userid, @v_taskviewkey, 0, 
              @o_error_code OUTPUT, @o_error_desc OUTPUT              
          END
        END --@v_elementtypecode IS NULL
      
      /* Exit taskviewdate cursor when error occurs */
      IF @o_error_code <> 0 
        BREAK
      
      /* Fetch next task group date */
      FETCH NEXT FROM taskviewdate_cur INTO @v_datetypecode, @v_taqkeyind

    END	/* @@FETCH_STATUS=0 - taskviewdatetype cursor */
    
    CLOSE taskviewdate_cur 
    DEALLOCATE taskviewdate_cur
    
    /* Exit taskview cursor when error occurs */
    IF @o_error_code <> 0 
      BREAK
	
    /* Fetch next task group/view */
    FETCH NEXT FROM taskview_cur INTO @v_taskviewkey, @v_elementtypecode, @v_elementautoind

  END	/* @@FETCH_STATUS=0 - taskview cursor */
	
  CLOSE taskview_cur 
  DEALLOCATE taskview_cur

  RETURN  

RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN

END
GO

GRANT EXEC ON qproject_add_taqprojecttask_newrole TO PUBLIC
GO
