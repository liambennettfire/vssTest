if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskviewtrigger') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taskviewtrigger
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_taskviewtrigger
 (@i_taskviewkey		   integer,
  @o_error_code			   integer output,
  @o_error_desc			   varchar(2000) output)
AS


/******************************************************************************
**  Name: qproject_get_taskviewtrigger
**  Desc: This stored procedure returns all records for given taskviewkey
**        and taskviewtriggerkey from the taskviewtrigger table. 
**
**    Auth: Uday A. Khisty
**    Date: 6/18/2015
**
*******************************************************************************/

  DECLARE @error_var      INT
  DECLARE @rowcount_var   INT
  DECLARE @sqlStmt		  varchar(5000)

  SET @o_error_code = 0
  SET @o_error_desc = ''

  /** get all dates/tasks for this task group/view key **/
  
  SELECT * from taskviewtrigger
  WHERE taskviewkey = @i_taskviewkey
  ORDER by fromdate ASC

  -- Save the @@ERROR values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taskviewkey = ' + cast(@i_taskviewkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qproject_get_taskviewtrigger TO PUBLIC
GO
