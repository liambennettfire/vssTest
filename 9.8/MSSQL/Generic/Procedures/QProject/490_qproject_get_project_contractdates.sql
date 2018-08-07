if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_contractdates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_contractdates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
  
CREATE PROCEDURE qproject_get_project_contractdates
 (@i_projectkey		integer,
  @i_qsicode        integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_contractdates
**  Desc: This stored procedure returns contract dates (taskviewkey=5) for the
**        Contract Information section of Project Summary.
**        For new projects (projectkey=0), dates are initialized from Project 
**        Dates task group (taskviewkey=11).
**
**    Auth: Kate
**    Date: 5/30/04
*******************************************************************************/

  DECLARE @v_error  INT,
    @v_rowcount INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  /** NOTE: When projectkey=0, this is a new Project. **/
  /** Contract dates on new projects must be initialized from Project Dates **/
  /** taskgroup (taskviewkey=5) **/  
  IF @i_projectkey = 0  --NEW project
   BEGIN
    SELECT
      CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
        ELSE d.datelabel
      END AS datelabel,
      v1.datetypecode, 0 taqtaskkey, NULL activedate, NULL originaldate, 
      NULL actualind, d.taqkeyind AS keyind,
      dbo.qproject_is_sent_to_tmm(N'date',0,d.datetypecode,0) sendtotmm
    FROM datetype d, taskviewdatetype v1
    WHERE v1.datetypecode = d.datetypecode 
      AND v1.taskviewkey = ( select taskviewkey from taskview where qsicode = @i_qsicode ) 
    ORDER BY v1.sortorder, d.datelabel, d.description   
   END
  ELSE  --existing project
   BEGIN  
    SELECT 
      CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
        ELSE d.datelabel
      END AS datelabel,
      d.datetypecode, t.taqtaskkey, t.activedate, t.originaldate, 
      t.actualind, t.keyind,
      dbo.qproject_is_sent_to_tmm(N'date',0,d.datetypecode,0) sendtotmm
    FROM taskviewdatetype v
    join datetype d on v.datetypecode = d.datetypecode
    left join taqprojecttask t on v.datetypecode = t.datetypecode and t.taqprojectkey = @i_projectkey
    WHERE v.taskviewkey = ( select taskviewkey from taskview where qsicode = @i_qsicode ) 
    ORDER BY v.sortorder, d.datelabel, d.description
   END
   
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey=' + cast(@i_projectkey AS VARCHAR)
  END 

GO
GRANT EXEC ON qproject_get_project_contractdates TO PUBLIC
GO
