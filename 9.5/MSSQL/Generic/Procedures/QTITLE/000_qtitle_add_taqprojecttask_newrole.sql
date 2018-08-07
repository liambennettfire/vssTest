if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_add_taqprojecttask_newrole') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_add_taqprojecttask_newrole
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_add_taqprojecttask_newrole
  (@i_bookkey  integer,
  @i_printingkey integer,
  @i_bookcontactkey  integer,
  @i_rolecode  integer,
  @i_userid varchar(30),
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_add_taqprojecttask_newrole
**  Desc: This stored procedure adds all tasks associated with the newly added
**        participant role. 
**
**    Auth: Lisa
**    Date: 10/01/08
*******************************************************************************/

DECLARE
  @v_rowadded BIT,
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
  @v_itemtypecode INT,
  @v_usageclasscode INT         
  
BEGIN

  SET @v_rowadded = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  /** Get userkey for the given userid passed **/
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE Upper(userid) = Upper(@i_userid)
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Error getting userkey for userid ' + CAST(@i_userid AS VARCHAR) + '.'
    GOTO RETURN_ERROR
  END  
  
  SELECT @v_itemtypecode = COALESCE(itemtypecode, 0), @v_usageclasscode = COALESCE(usageclasscode, 0) 
  FROM coretitleinfo 
  WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey  
  /** Declare a cursor for all task groups associated with this role type **/
  /** (for the default user -1 or the current user) **/
  DECLARE taskview_cur CURSOR FOR
    SELECT taskviewkey, elementtypecode, elementautoind
    FROM taskview T
    WHERE rolecode = @i_rolecode AND roleautoind = 1 AND
        (taskgroupind = 1) AND
        (userkey = -1 OR userkey = @v_userkey) AND
        ( T.usageclasscode = @v_usageclasscode or isNull(T.usageclasscode,0) <= 0 ) AND
        ( T.itemtypecode = @v_itemtypecode or isNull(T.itemtypecode,0) <= 0 )        
        
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
      
      IF @v_elementtypecode > 0 AND @v_elementautoind = 1
        BEGIN
          DECLARE element_cur CURSOR FOR
            SELECT taqelementkey
            FROM taqprojectelement
            WHERE bookkey = @i_bookkey AND
                printingkey = @i_printingkey AND
                taqelementtypecode = @v_elementtypecode
                
          OPEN element_cur

          FETCH NEXT FROM element_cur INTO @v_taqelementkey

          WHILE (@@FETCH_STATUS = 0) 
          BEGIN

            /* Insert each task into TAQPROJECTTASK table */
            EXEC qtitle_add_taqprojecttask @v_taqelementkey, @i_bookcontactkey, @v_datetypecode, 
              @v_taqkeyind, @i_userid, @v_taskviewkey, @i_bookkey, @i_printingkey, @i_rolecode, 
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
            EXEC qtitle_add_taqprojecttask NULL, @i_bookcontactkey, @v_datetypecode, 
              @v_taqkeyind, @i_userid, @v_taskviewkey, @i_bookkey, @i_printingkey, @i_rolecode, 
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

GRANT EXEC ON qtitle_add_taqprojecttask_newrole TO PUBLIC
GO
