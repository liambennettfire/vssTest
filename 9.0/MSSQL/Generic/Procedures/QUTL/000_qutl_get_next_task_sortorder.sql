if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_next_task_sortorder') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_next_task_sortorder
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_next_task_sortorder
 (@i_taskview				integer,
	@i_datetype				integer,
	@i_bookkey				integer,
	@i_projectkey			integer,
	@i_elementkey			integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_next_task_sortorder
**  Desc: This stored procedure returns sortorder for the next new task based on either max existing or chosen task view
**
**    Auth: Dustin Miller
**    Date: 10/16/12
*******************************************************************************/
	
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  
  DECLARE @v_sortorder	INT
  SET @v_sortorder = 0
  
  IF @i_taskview > 0
  BEGIN
		SELECT @v_sortorder = COALESCE(sortorder, 0)
		FROM taskviewdatetype
		WHERE taskviewkey = @i_taskview
			AND datetypecode = @i_datetype
		
		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'error obtaining new task sort order (qutl_get_next_task_sortorder)'
		END 
  END
  IF @v_sortorder = 0
  BEGIN
	IF @i_elementkey > 0 BEGIN
		SELECT @v_sortorder = COALESCE(MAX(sortorder), 0) + 1
		FROM taqprojecttask
		WHERE taqelementkey = @i_elementkey
	END 
	ELSE IF @i_bookkey > 0 BEGIN
		SELECT @v_sortorder = COALESCE(MAX(sortorder), 0) + 1
		FROM taqprojecttask
		WHERE bookkey = @i_bookkey
	END
	ELSE IF @i_projectkey > 0 BEGIN
		SELECT @v_sortorder = COALESCE(MAX(sortorder), 0) + 1
		FROM taqprojecttask
		WHERE taqprojectkey = @i_projectkey 
	END
				
	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'error obtaining new task sort order (qutl_get_next_task_sortorder)'
	END 
  END
	
	SELECT @v_sortorder AS sortorder
	
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error obtaining new task sort order (qutl_get_next_task_sortorder)'
  END 

GO
GRANT EXEC ON qutl_get_next_task_sortorder TO PUBLIC
GO


