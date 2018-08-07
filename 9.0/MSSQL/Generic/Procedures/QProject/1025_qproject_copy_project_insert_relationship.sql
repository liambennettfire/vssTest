IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_insert_relationship]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_insert_relationship]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_insert_relationship]    Script Date: 07/16/2008 10:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[qproject_copy_project_insert_relationship]
		(@i_new_projectkey     integer,
		@i_related_projectkey		integer,
		@i_relationshipcode1	integer,
		@i_relationshipcode2	integer,
		@i_userid				varchar(30),
		@o_error_code			integer output,
		@o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_insert_relationship]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
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
	@sortorder		int

if @i_related_projectkey > 0
begin

	select @count = count(*)
	from taqprojectrelationship
	where (taqprojectkey1 = @i_new_projectkey and taqprojectkey2 = @i_related_projectkey)
		or (taqprojectkey2 = @i_new_projectkey and taqprojectkey1 = @i_related_projectkey)

	if @count = 0
	begin
		EXEC get_next_key @i_userid, @newkey OUTPUT

		select @sortorder = max(isnull(sortorder,0)) + 1
		from taqprojectrelationship
		where (taqprojectkey1 = @i_related_projectkey and relationshipcode1 = @i_relationshipcode1 and 
				relationshipcode2 = @i_relationshipcode2)
			or (taqprojectkey2 = @i_related_projectkey and relationshipcode2 = @i_relationshipcode1 and 
				relationshipcode1 = @i_relationshipcode2)

		insert into taqprojectrelationship
			(taqprojectrelationshipkey,taqprojectkey1,taqprojectkey2,projectname2 ,relationshipcode1 ,relationshipcode2 ,
			project2status ,project2participants ,relationshipaddtldesc ,keyind ,sortorder ,
			indicator1 ,indicator2 ,quantity1 ,quantity2, decimal1, decimal2, lastuserid ,lastmaintdate)
		values 
			(@newkey, @i_related_projectkey, @i_new_projectkey,null,@i_relationshipcode1, @i_relationshipcode2,
			null,null,null,0,@sortorder, null,null,null,null,null,null,@i_userid, getdate())

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'insert into taqprojectrelationship failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_new_projectkey AS VARCHAR)+ '; related taqprojectkey = ' + cast(@i_related_projectkey AS VARCHAR)   
			RETURN
		END 
	end
end

RETURN