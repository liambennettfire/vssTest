if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskviewfields') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taskviewfields
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_taskviewfields
 (@i_taskviewkey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_taskviewfields
**  Desc: This stored procedure returns taskviewfield info for a 
**        taskviewkey (task group) from the taskviewfields table.
**
**    Auth: Alan Katzen
**    Date: 9/29/04
**
**  Modified:
**		Lisa - added a 'selected' indicator to make coding in the grid easier.
**
** 12/1/08 Lisa - needed to have this find default taskview for all tasks 
**                it was changed to use qsicode = 1
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT,
          @v_default_taskviewkey INT,
          @v_cnt INT

  SELECT @v_default_taskviewkey = taskviewkey 
    FROM taskview 
   WHERE qsicode = 1 
  
  IF @i_taskviewkey > 0 BEGIN 
    SELECT @v_cnt = count(*) 
      FROM taskviewfields f, taskfieldnames n
     WHERE f.taskfieldkey = n.taskfieldkey AND
           f.taskviewkey = @i_taskviewkey 
           
    IF @v_cnt = 0 BEGIN
      SET @i_taskviewkey = @v_default_taskviewkey
    END
  END
  ELSE BEGIN
    SET @i_taskviewkey = @v_default_taskviewkey
  END
  
  SELECT f.taskfieldkey, f.sortorder, f.columnorder, n.fieldname, n.initialsortorder,
		 case when f.columnorder > 0 then 'true' else 'false' end as selectind
  FROM taskviewfields f, taskfieldnames n
  WHERE f.taskfieldkey = n.taskfieldkey AND
      f.taskviewkey = @i_taskviewkey 
  ORDER BY f.sortorder, n.fieldname

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taskviewkey=' + CAST(@i_taskviewkey AS VARCHAR)
  END 

GO
GRANT EXEC ON qproject_get_taskviewfields TO PUBLIC
GO

