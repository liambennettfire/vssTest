if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_add_manuscript_iteration') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_add_manuscript_iteration
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_add_manuscript_iteration
  (@i_projectkey    integer,
  @i_userid         varchar(30),
  @i_elementdesc    varchar(255),
  @o_new_elementkey integer output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_add_manuscript_iteration
**  Desc: This stored procedure adds a new element of type Manuscript Iteration
**
**    Auth: Kate
**    Date: 9/28/04
*******************************************************************************/

  DECLARE
    @v_taqelementkey  INT,
    @v_taqelementtypecode INT,
    @v_taqelementtypesubcode  INT,
    @v_taqprojectcontactrolekey INT,
    @v_readerrolecode INT,
    @v_error  INT,
    @v_rowcount INT,
    @v_userkey INT,
    @v_taskviewkey INT
  
  SET @o_new_elementkey = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  /** Get taqelementtypecode for 'Manuscript' (gentable 287, qsicode=1) **/
  SELECT @v_taqelementtypecode = datacode
  FROM gentables
  WHERE tableid = 287 AND qsicode = 1
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN    
    SET @o_error_desc = 'Could not get Manuscript element (gentable tableid=287, qsicode=1)'
    GOTO RETURN_ERROR
  END    
  
  /** Get taqelementtypesubcode for 'Iteration' (subgentable 287, qsicode=1) **/
  SELECT @v_taqelementtypesubcode = datasubcode
  FROM subgentables
  WHERE tableid = 287 AND datacode = @v_taqelementtypecode AND qsicode = 1
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Could not get Iteration subelement (subgentable tableid=287, qsicode=1)'
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
  
  /*** Add new row to TAQPROJECTELEMENT table ***/
  EXEC qproject_add_taqprojectelement @i_projectkey, @v_taqelementtypecode,
    @v_taqelementtypesubcode, @i_elementdesc, @i_userid, @v_taqelementkey OUTPUT,
    @o_error_code OUTPUT, @o_error_desc OUTPUT
  
  IF @o_error_code = 0 AND @v_taqelementkey > 0
  BEGIN
  
    /*** TAQPROJECTREADERITERATION ***/
    /*** For each participant of type Reader and element of type Manuscript ***/
    IF @i_projectkey > 0 BEGIN
          
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
          @v_taqprojectcontactrolekey, @v_taqelementkey, @i_userid,
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
        GOTO RETURN_ERROR
        
    END /* IF @i_projectkey >  0 */
      
    /** Get userkey for the given userid passed **/
    SELECT @v_userkey = COALESCE(userkey, -1)
    FROM qsiusers
    WHERE UPPER(userid) = UPPER(@i_userid)

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @v_userkey = -1
    END
      
    /** Declare a cursor for all task groups associated with this element type **/
    /** (for the default user -1 or the current user) **/
    DECLARE taskview_cur CURSOR FOR
     SELECT taskviewkey
       FROM taskview 
      WHERE elementtypecode = @v_taqelementtypecode 
        AND elementautoind = 1 
        AND taskgroupind = 1 
        AND (userkey = -1 OR userkey = @v_userkey)
      
    OPEN taskview_cur
    
    FETCH NEXT FROM taskview_cur INTO @v_taskviewkey
    
    WHILE (@@FETCH_STATUS = 0) 
    BEGIN
      /** Call procedure that will populate TAQPROJECTTASK and TAQPROJECTREADERITERATION tables **/
      EXEC qproject_add_taqprojecttask_newelem @v_taskviewkey, @i_projectkey, @v_taqelementkey,
        @v_taqelementtypecode, 0, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
      
      /* Exit taskview cursor when error occurs */
      IF @o_error_code <> 0
        BREAK  
  	
      /* Fetch next task group/view */
      FETCH NEXT FROM taskview_cur INTO @v_taskviewkey
      
    END	/* @@FETCH_STATUS=0 - taskview cursor */
  	
    CLOSE taskview_cur 
    DEALLOCATE taskview_cur
      
  END /* IF @taqelementkey > 0 */ 

  SET @o_new_elementkey = @v_taqelementkey
  RETURN  

RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN
  
GO

GRANT EXEC ON qproject_add_manuscript_iteration TO PUBLIC
GO
