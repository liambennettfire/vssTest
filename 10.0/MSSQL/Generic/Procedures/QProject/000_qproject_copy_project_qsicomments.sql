IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.qproject_copy_project_qsicomments')
               AND
               OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_copy_project_qsicomments
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_qsicomments]    Script Date: 04/13/2012******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_qsicomments]
	   (@i_copy_projectcommentkey   integer,
		@i_userid					varchar(30),
		@o_newcommentkey			integer output,
		@o_error_code				integer output,
		@o_error_desc				varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_qsicomments]
**  Desc: This stored procedure copies the comment corresponding to the input comment key.
** 
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Uday Khisty
**    Date: 13 April 2012
*******************************************************************************/

DECLARE @error_var		INT,
		@rowcount_var	INT,
		@newkeycount	INT,
		@tobecopiedkey	INT,
		@newkey			INT,
		@v_cnt			INT

BEGIN
	SET @o_error_code = 0
	SET @o_error_desc = ''

	SELECT @v_cnt = count(*)
	FROM qsicomments
	WHERE commentkey = @i_copy_projectcommentkey

	IF @v_cnt > 0
	  BEGIN
		EXEC get_next_key @i_userid, @newkey OUTPUT

		INSERT
		  INTO qsicomments (commentkey,
							commenttypecode,
							commenttypesubcode,
							parenttable,
							commenttext,
							commenthtml,
							commenthtmllite,
							lastuserid,
							lastmaintdate,
							invalidhtmlind,
							releasetoeloquenceind)
		  SELECT @newkey AS commentkey,
				 q.commenttypecode,
				 q.commenttypesubcode,
				 q.parenttable,
				 q.commenttext,
				 q.commenthtml,
				 q.commenthtmllite,
				 @i_userid AS lastuserid,
				 GETDATE() AS lastmaintdate,
				 q.invalidhtmlind,
				 q.releasetoeloquenceind
			FROM qsicomments q
			WHERE q.commentkey = @i_copy_projectcommentkey

		  SET @o_newcommentkey = @newkey

		  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		  IF @error_var <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'copy/insert into qsicomments failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectcommentkey AS VARCHAR)   
			  RETURN
		  END 
	  END

  END
GO
GRANT EXEC ON qproject_copy_project_qsicomments TO PUBLIC
GO