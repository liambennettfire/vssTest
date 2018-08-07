IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_update_task_owners]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_update_task_owners]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_update_task_owners]
 (@i_taskUpdates		varchar(max),
  @o_error_code			integer output,
  @o_error_desc			varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_update_task_owners
**  Desc: A String in the form of TaqTaskKey,GlobalContactKey,Index
**		  with mulitiple entries separated by '|' characters is sent in from 
**		  a dialog.  It is broken up and updates on the taqprojecttask table
**		  are made.
**
**  Parameters:
**		@i_taskUpdates - string containing list of updates to be made
**
**  Auth: Lisa Cormier
**  Date: 16 Sep 2008
**
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  10/14/08 Lisa Wanted this to work for books/titles so I removed the 
**                projectkey.  The taqtaskkey should be unique enough.
*******************************************************************************/

	SET @o_error_code = 0
	SET @o_error_desc = ''

	DECLARE @error_var		INT
	DECLARE @rowcount_var	INT
   
    DECLARE @pipePos		INT
	DECLARE @commaPos		INT

	DECLARE @keyString		varchar(60)
    DECLARE @tempString		varchar(max)
	DECLARE @contactKey		varchar(15)
	--DECLARE @projectKey		varchar(15)
	DECLARE @taskKey		varchar(15)
	DECLARE @contactIndex	varchar(10)

    SELECT @pipePos = 0
    SELECT @tempString = @i_taskUpdates
	SELECT @pipePos = CharIndex('|', @tempString)

    WHILE ( @pipePos > 1 or len(@tempString) > 0 )
    BEGIN
		if ( @pipePos > 0 )
		BEGIN
			SELECT @keyString = substring(@tempString, 0, @pipePos)
			SELECT @tempString = substring(@tempString, @pipePos + 1, len(@tempString))
		END
		ELSE
		BEGIN
			SELECT @keyString = @tempString
		END

		IF ( @tempString = @keyString ) SELECT @tempString = ''

		-- Get the ProjectKey
		-- 10/14/08 Lisa wanted this to work for books/titles now too so 
		-- removed projectkey -- taskkey should be unique enough.
--		SELECT @commaPos = CharIndex(',', @keyString)
--		SELECT @projectKey = substring(@keyString, 0, @commaPos)
--		SELECT @keystring = substring(@keyString, @commaPos + 1, len(@keystring))

		-- Get the Task Key
		SELECT @commaPos = CharIndex(',', @keyString)
		SELECT @taskKey = substring(@keyString, 0, @commaPos)
		SELECT @keystring = substring(@keyString, @commaPos + 1, len(@keystring))

		--print '	Task: ' + @taskKey

		-- Get the GlobalContactKey
		SELECT @commaPos = CharIndex(',', @keyString)
		SELECT @contactKey = substring(@keyString, 0, @commaPos)
		SELECT @keystring = substring(@keyString, @commaPos + 1, len(@keystring))

		--print '	Contact: ' + @contactKey

		-- Get the Index
		SELECT @contactIndex = substring(@keyString, 1, len(@keystring))

		--print '	Index: ' + @contactIndex

		-- find the next group of data
		SELECT @pipePos = CharIndex('|', @tempString)

		IF ( @contactIndex = 1 ) -- update 'globalcontactkey' field of taqprojecttask
		BEGIN
			update taqprojecttask
			SET globalcontactkey = @contactKey
			WHERE taqtaskkey = @taskKey
		END
		ELSE					 -- update 'globalcontactkey2' field of taqprojecttask
		BEGIN
			update taqprojecttask
			SET globalcontactkey2 = @contactKey
			WHERE taqtaskkey = @taskKey
		END

    END 

GO

GRANT EXEC on qproject_update_task_owners TO PUBLIC
GO


