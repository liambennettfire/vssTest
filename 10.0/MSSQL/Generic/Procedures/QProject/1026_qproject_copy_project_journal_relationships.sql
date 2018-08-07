IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_journal_relationships]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_journal_relationships]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_journal_relationships]    Script Date: 07/16/2008 10:29:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qproject_copy_project_journal_relationships]
		(@i_new_projectkey		integer,
        @i_copy2_projectkey		integer,
		@i_userid				varchar(30),
		@i_related_journalkey	integer,
		@i_related_volumekey	integer,
		@i_related_issuekey		integer,
		@i_itemtype_qsicode		integer,
		@i_usageclass_qsicode	integer,
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_journal_relationships]
**  Desc: This stored procedure adds the taqprojectrelationship rows for new volumes, issues, and content units.
**        The new project key and related keys are passed as arguments.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var	INT,
	@rowcount_var	INT,
	@count			int,
	@newkey			int,
	@journal_relationshipcode		int,
	@volume_relationshipcode		int,
	@issue_relationshipcode			int,
	@contentunit_relationshipcode	int,
	@sortorder		int

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to add journal relationships (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)   
	RETURN
end

select @journal_relationshipcode = datacode
from gentables
where tableid = 582
and qsicode = 1

select @volume_relationshipcode = datacode
from gentables
where tableid = 582
and qsicode = 2

select @issue_relationshipcode = datacode
from gentables
where tableid = 582
and qsicode = 3

select @contentunit_relationshipcode = datacode
from gentables
where tableid = 582
and qsicode = 4

if @i_itemtype_qsicode = 6 and @i_usageclass_qsicode = 8	--journal/volume
begin
	exec qproject_copy_project_insert_relationship @i_new_projectkey, @i_related_journalkey, @journal_relationshipcode, 
		@volume_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output
	
	IF @o_error_code <> 0 BEGIN
		RETURN
	END 	
end
else if @i_itemtype_qsicode = 6 and @i_usageclass_qsicode = 5	--journal/issue
begin
	exec qproject_copy_project_insert_relationship @i_new_projectkey, @i_related_journalkey, @journal_relationshipcode, 
		@issue_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output
	
	IF @o_error_code <> 0 BEGIN
		RETURN
	END 	

	exec qproject_copy_project_insert_relationship @i_new_projectkey, @i_related_volumekey, @volume_relationshipcode, 
		@issue_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output
	
	IF @o_error_code <> 0 BEGIN
		RETURN
	END 	
end
else if @i_itemtype_qsicode = 6 and @i_usageclass_qsicode = 6	--journal/content unit
begin
	exec qproject_copy_project_insert_relationship @i_new_projectkey, @i_related_journalkey, @journal_relationshipcode, 
		@contentunit_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output
	
	IF @o_error_code <> 0 BEGIN
		RETURN
	END 	

	exec qproject_copy_project_insert_relationship @i_new_projectkey, @i_related_volumekey, @volume_relationshipcode, 
		@contentunit_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output
	
	IF @o_error_code <> 0 BEGIN
		RETURN
	END 	
	
	exec qproject_copy_project_insert_relationship @i_new_projectkey, @i_related_issuekey, @issue_relationshipcode, 
		@contentunit_relationshipcode, @i_userid, @o_error_code output, @o_error_desc output
	
	IF @o_error_code <> 0 BEGIN
		RETURN
	END 	
end




RETURN
