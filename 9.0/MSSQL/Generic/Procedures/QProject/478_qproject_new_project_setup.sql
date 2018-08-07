if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_new_project_setup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_new_project_setup
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_new_project_setup
  (@i_projectkey  integer,
  @i_projecttype	integer,
  @i_userid varchar(30),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_new_project_setup
**  Desc: This stored procedure initializes any necessary values
**        for a new project - project dates, initial iteration, etc.
**        based on passed Project Type.
**
**    Auth: Kate
**    Date: 3/23/05
*******************************************************************************/

  DECLARE
    @v_datetypecode INT,
    @v_taqkeyind  TINYINT,
    @v_error  INT,
    @v_rowcount INT,
    @v_taskviewkey INT,
	@v_userkey  INT        
  
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  /** Get userkey for the given userid passed **/
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE Upper(userid) = Upper(@i_userid)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_desc = 'Error getting userkey for userid ' + CAST(@i_userid AS VARCHAR) + '.'
    RETURN
  END    
  
  /* Get all dates for the Initial Project Dates task group OR for the Initial Project Type task group */
  DECLARE taskviewdate_cur CURSOR FOR
    SELECT DISTINCT vd.datetypecode, COALESCE(vd.keyind,d.taqkeyind), v.taskviewkey
    FROM taskview v, taskviewdatetype vd, datetype d, taqproject p
    WHERE v.taskviewkey = vd.taskviewkey AND
      vd.datetypecode = d.datetypecode AND
      (COALESCE(v.taqprojecttypecode, 0) = COALESCE(@i_projecttype, 0)) AND
      ( v.usageclasscode = p.usageclasscode or isNull(v.usageclasscode,0) <= 0 ) AND
      ( v.itemtypecode = p.searchitemcode or isNull(v.itemtypecode,0) <= 0 ) AND
      ( p.taqprojectkey = @i_projectkey ) AND
      ( taskgroupind = 1 ) AND
      ( userkey = -1 OR userkey = @v_userkey )
    
  OPEN taskviewdate_cur

  FETCH NEXT FROM taskviewdate_cur INTO @v_datetypecode, @v_taqkeyind, @v_taskviewkey

  WHILE (@@FETCH_STATUS = 0) 
  BEGIN

    /* Insert each task into TAQPROJECTTASK table */
    EXEC qproject_add_taqprojecttask @i_projectkey, NULL,
      NULL, NULL, @v_datetypecode, @v_taqkeyind, @i_userid, @v_taskviewkey, 0, 
      @o_error_code OUTPUT, @o_error_desc OUTPUT          

    /* Exit taskviewdate cursor when error occurs */
    IF @o_error_code <> 0
      BREAK       
      
    /* Fetch next task group date */
    FETCH NEXT FROM taskviewdate_cur INTO @v_datetypecode, @v_taqkeyind, @v_taskviewkey

  END	/* @@FETCH_STATUS=0 - taskviewdatetype cursor */
    
  CLOSE taskviewdate_cur 
  DEALLOCATE taskviewdate_cur
  
GO

GRANT EXEC ON qproject_new_project_setup TO PUBLIC
GO
