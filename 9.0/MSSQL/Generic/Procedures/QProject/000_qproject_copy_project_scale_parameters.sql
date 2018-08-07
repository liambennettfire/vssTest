IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_scale_parameters]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_scale_parameters]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_scale_parameters]    Script Date: 07/16/2008 10:28:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_scale_parameters]
		(@i_copy_projectkey     integer,
		@i_new_projectkey		integer,
		@i_userid				varchar(30),
		@i_cleardatagroups_list	varchar(max),
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [project_copy_project_scale_parameters]
**  Desc: This stored procedure copies the scale parameters from one scale to another.
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Alan Katzen
**    Date: 6 March 2012
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT,
	@rowcount_var INT,
	@newkeycount	int,
	@tobecopiedkey	int,
	@newkey	int,
	@counter		int,
	@newkeycount2	int,
	@tobecopiedkey2	int,
	@newkey2		int,
	@counter2		int,
	@cleardata		char(1)

if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'copy project key not passed to copy scale parameters (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
	SET @o_error_code = -1
	SET @o_error_desc = 'new project key not passed to copy scale parameters (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
	RETURN
end

select @newkeycount = count(*), @tobecopiedkey = min(q.taqscaleparameterkey)
from taqprojectscaleparameters q
where taqprojectkey = @i_copy_projectkey

set @counter = 1
while @counter <= @newkeycount
begin
	exec get_next_key @i_userid, @newkey output

	insert into taqprojectscaleparameters
		(taqscaleparameterkey, taqprojectkey, itemcategorycode, itemcode, value1, value2, lastuserid, lastmaintdate)
	select @newkey, @i_new_projectkey, itemcategorycode, itemcode, value1, value2, @i_userid, getdate()
	from taqprojectscaleparameters
	where taqprojectkey = @i_copy_projectkey
		and taqscaleparameterkey = @tobecopiedkey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'copy/insert into taqprojectscaleparameters failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
		RETURN
	END 

	set @counter = @counter + 1

	select @tobecopiedkey = min(q.taqscaleparameterkey)
	from taqprojectscaleparameters q
	where taqprojectkey = @i_copy_projectkey
		and q.taqscaleparameterkey > @tobecopiedkey
end

RETURN


