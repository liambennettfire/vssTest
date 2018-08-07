IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_additional]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_additional]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_additional]    Script Date: 07/16/2008 10:34:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qproject_copy_project_additional]
		(@i_copy_projectkey integer,
		@i_copy2_projectkey  integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_copydatagroups_list	varchar(max),
		@i_cleardatagroups_list	varchar(max),
		@i_related_journalkey	integer,
		@i_related_volumekey	integer,
		@i_related_issuekey		integer,
		@i_itemtype_qsicode		integer,
		@i_usageclass_qsicode	integer,
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_additional]
**  Desc: This stored procedure is called at the end of copy project.  It is intended to be used
**			for client specific code as needed.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*******************************************************************************/

DECLARE @error_var	int

SET @o_error_code = 0
SET @o_error_desc = ''

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy project additional: taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
	RETURN
end

exec qproject_copy_project_journal_relationships @i_new_projectkey,@i_copy2_projectkey,@i_userid,@i_related_journalkey,
		@i_related_volumekey,@i_related_issuekey,@i_itemtype_qsicode,@i_usageclass_qsicode,
		@o_error_code output,@o_error_desc output

IF @o_error_code <> 0 BEGIN
	RETURN
END 	





RETURN
