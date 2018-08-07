IF EXISTS (SELECT *
			   FROM sys.objects
			   WHERE object_id = object_id(N'[dbo].[qcs_get_catalog_comment]')
				   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[qcs_get_catalog_comment]
GO

CREATE PROCEDURE [dbo].[qcs_get_catalog_comment]
(
    @i_projectkey INTEGER,
    @v_elofieldtag VARCHAR(256),
    @o_error_code INTEGER OUTPUT,
    @o_error_desc VARCHAR(2000) OUTPUT
)
AS

	DECLARE
            @error_var     INT,
            @rowcount_var  INT,
            @i_datacode    INTEGER,
            @i_datasubcode INTEGER,
            @i_commentkey  INTEGER

	BEGIN
		SET @o_error_code = 0
		SET @o_error_desc = ''

		-- Search subgentables for 263

		SELECT @i_datacode = datacode
			FROM subgentables g
			WHERE g.tableid = 284
				AND g.eloquencefieldtag = 'cld_catcom_homepg'

PRINT @i_datacode

		SELECT @error_var = @@ERROR,
			   @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0
			BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error retrieving gentable info (projectkey = ' + cast
				(@i_projectkey AS VARCHAR) + ')'
				RETURN
			END

		SELECT @i_datasubcode = datasubcode
			FROM subgentables g
			WHERE g.tableid = 284
				AND g.eloquencefieldtag = 'cld_catcom_homepg'

PRINT @i_datasubcode

		SELECT @error_var = @@ERROR,
			   @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0
			BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error retrieving gentable info (projectkey = ' + cast
				(@i_projectkey AS VARCHAR) + ')'
				RETURN
			END

		SELECT @i_commentkey = commentkey
			FROM taqprojectcomments t
			WHERE t.taqprojectkey = @i_projectkey
				AND t.commenttypecode = @i_datacode
				AND t.commenttypesubcode = @i_datasubcode

PRINT @i_commentkey

		SELECT @error_var = @@ERROR,
			   @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0
			BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error retrieving taqprojectcomments info (projectkey = ' + cast
				(@i_projectkey AS VARCHAR) + ')'
				RETURN
			END

		SELECT commenthtmllite
			FROM qsicomments q
			WHERE q.commentkey = @i_commentkey
			

		SELECT @error_var = @@ERROR,
			   @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0
			BEGIN
				SET @o_error_code = -1
				SET @o_error_desc =	'Error retrieving qsicomments info (projectkey = ' + cast
				(@i_projectkey AS VARCHAR) + ')'
				RETURN
			END
	END
GO

GRANT EXEC ON [qcs_get_catalog_comment] TO PUBLIC
GO