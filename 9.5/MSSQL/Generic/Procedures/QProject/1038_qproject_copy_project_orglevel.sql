IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_orglevel]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_orglevel]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_orglevel]    Script Date: 07/16/2008 10:28:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_orglevel]
		(@i_copy_projectkey     integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_cleardatagroups_list	varchar(max),
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_orgentry]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*****************************************************************************************************
**  Change History
*****************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------
*   03/20/2016   Kate        Case 37102 - If rows exist for new project, delete before inserting.
*                            This is necessary to prevent dup key errors in transmit to tmm.
*****************************************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT,
	@rowcount_var INT

if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy orglevel (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy orglevel (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

IF (SELECT COUNT(*) FROM taqprojectorgentry WHERE taqprojectkey = @i_new_projectkey) > 0
BEGIN
  DELETE FROM taqprojectorgentry
  WHERE taqprojectkey = @i_new_projectkey
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Failed to remove existing taqprojectorgentry rows before copy (' + cast(@error_var AS VARCHAR) + '): new taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
	RETURN
  END  
END

insert into taqprojectorgentry
	(taqprojectkey, orgentrykey, orglevelkey, lastuserid, lastmaintdate)
select @i_new_projectkey, orgentrykey, orglevelkey, @i_userid, getdate()
from taqprojectorgentry
where taqprojectkey = @i_copy_projectkey

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'copy/insert into taqprojectorgentry failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
END 

RETURN


