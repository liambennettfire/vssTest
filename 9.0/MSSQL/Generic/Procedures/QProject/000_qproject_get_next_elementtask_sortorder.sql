if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_next_elementtask_sortorder') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure dbo.qproject_get_next_elementtask_sortorder
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_next_elementtask_sortorder
 (@i_taqelementkey	integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_next_elementtask_sortorder
**  Desc: This stored procedure returns the next sort order for existing tasks
						of the specified element (max + 1)
**
**    Auth: Dustin Miller
**    Date: 12/6/12
*******************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_maxsortorder	INT
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_maxsortorder = 0
  
	SELECT @v_maxsortorder = COALESCE(MAX(sortorder), 0)
  FROM taqprojecttask
  WHERE taqelementkey=@i_taqelementkey
			
	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'error accessing taqprojecttask: taqelementkey = ' + cast(@i_taqelementkey AS VARCHAR)
	END
	
	SELECT @v_maxsortorder AS maxsortorder

GO
GRANT EXEC ON qproject_get_next_elementtask_sortorder TO PUBLIC
GO


