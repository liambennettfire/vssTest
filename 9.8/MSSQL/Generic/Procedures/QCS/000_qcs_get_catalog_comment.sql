IF EXISTS (SELECT *
			   FROM sys.objects
			   WHERE object_id = object_id(N'[dbo].[qcs_get_catalog_comment]')
				   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qcs_get_catalog_comment]
GO

CREATE PROCEDURE [dbo].[qcs_get_catalog_comment]
(
    @i_projectkey INTEGER,
    @v_elofieldtag VARCHAR(256)
)
AS

	DECLARE
            @error_var     INT,
            @rowcount_var  INT,
            @output		   VARCHAR(max),
            @i_datacode    INTEGER,
            @i_datasubcode INTEGER,
            @i_commentkey  INTEGER,
			@errorDesc	   NVARCHAR(2000)

	BEGIN

		SELECT @i_datacode = datacode
			FROM subgentables g
			WHERE g.tableid = 284
				AND g.eloquencefieldtag = @v_elofieldtag


		SELECT @error_var = @@ERROR,
			   @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0
			BEGIN
				SET @errorDesc = 'Error retrieving gentable info (projectkey = ' + cast
				(@i_projectkey AS VARCHAR) + ')'
				RAISERROR(@errorDesc, 16, 1)
				RETURN
			END

		SELECT @i_datasubcode = datasubcode
			FROM subgentables g
			WHERE g.tableid = 284
				AND g.eloquencefieldtag = @v_elofieldtag

		SELECT @error_var = @@ERROR,
			   @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0
			BEGIN
				SET @errorDesc = 'Error retrieving gentable info (projectkey = ' + cast
				(@i_projectkey AS VARCHAR) + ')'
				RAISERROR(@errorDesc, 16, 1)
				RETURN
			END

		SELECT @i_commentkey = commentkey
			FROM taqprojectcomments t
			WHERE t.taqprojectkey = @i_projectkey
				AND t.commenttypecode = @i_datacode
				AND t.commenttypesubcode = @i_datasubcode

		SELECT @error_var = @@ERROR,
			   @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0
			BEGIN
				SET @errorDesc = 
					'Error retrieving taqprojectcomments info (projectkey = ' + cast
				(@i_projectkey AS VARCHAR) + ')'
				RAISERROR(@errorDesc, 16, 1)
				RETURN
			END

		SELECT @output = commenthtmllite
			FROM qsicomments q
			WHERE q.commentkey = @i_commentkey

		select @output = replace(@output, '<div>', '')
		select @output = replace(@output, '</div>', '')
		
		select @output as commenthtmllite

		SET @errorDesc = '@i_datacode: ' + cast(@i_datacode AS VARCHAR)
		+ '@i_datasubcode: ' + cast(@i_datasubcode AS VARCHAR) +
		+'@i_commentkey: ' + cast(@i_commentkey AS VARCHAR)

		SELECT @error_var = @@ERROR,
			   @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0
			BEGIN
				SET @errorDesc = 'Error retrieving qsicomments info (projectkey = ' + 
					cast
				(@i_projectkey AS VARCHAR) + ')'
				RAISERROR(@errorDesc, 16, 1)
				RETURN
			END
	END
GO

GRANT EXEC ON [qcs_get_catalog_comment] TO PUBLIC
GO