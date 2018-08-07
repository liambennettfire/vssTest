if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_taskoverride_element_exists') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure dbo.qproject_taskoverride_element_exists
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_taskoverride_element_exists
 (@i_taqtaskkey			integer,
	@i_taqelementkey	integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_taskoverride_element_exists
**  Desc: This stored procedure returns a code depending on whether an element exists
						on taqprojecttask (1), taqprojectoverride (2), or neither (0)
**
**    Auth: Dustin Miller
**    Date: 12/5/12
*******************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_count			INT
  DECLARE @v_returncode	INT
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_count = 0
  SET @v_returncode = 0
  
	SELECT @v_count = COUNT(*)
	FROM taqprojecttask
	WHERE taqtaskkey = @i_taqtaskkey
		AND taqelementkey = @i_taqelementkey
		
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing taqprojecttask: taqtaskkey = ' + cast(@i_taqtaskkey AS VARCHAR)
  END 
		
	IF @v_count > 0
	BEGIN
		SET @v_returncode = 1
	END
	ELSE BEGIN
		SET @v_count = 0
		
		SELECT @v_count = COUNT(*)
		FROM taqprojecttaskoverride
		WHERE taqtaskkey = @i_taqtaskkey
			AND taqelementkey = @i_taqelementkey
			
		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'error accessing taqprojecttaskoverride: taqtaskkey = ' + cast(@i_taqtaskkey AS VARCHAR)
		END
			
		IF @v_count > 0
		BEGIN
			SET @v_returncode = 2
		END
	END
	
	SELECT @v_returncode AS tasklocationcode

GO
GRANT EXEC ON qproject_taskoverride_element_exists TO PUBLIC
GO


