/******************************************************************************
**  Name: imp_100022310001
**  Desc: IKE Onix Bookcomment assignment
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_100022310001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100022310001]
GO

CREATE PROCEDURE dbo.imp_100022310001 @i_batchkey INT
	,@i_row INT
	,
	--  @i_elementkey int,
	@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_level INT
	,@i_userid VARCHAR(50)
AS
/* Comment mapping */
BEGIN
	DECLARE @v_errcode INT
		,@v_errlevel INT
		,@v_msg VARCHAR(500)
		,@v_texttype VARCHAR(4000)
		,@v_textformat VARCHAR(4000)
		,@v_text VARCHAR(max)
		,@v_elementkey INT
		,@v_elementmnemonic VARCHAR(50)
		,@v_commenttypecode INT
		,@v_commenttypesubcode INT
		,@v_lobkey INT
		,@v_count INT

	BEGIN
		SET @v_errlevel = 1
		SET @v_msg = 'Onix Bookcomment assignment'

		--       
		SELECT @v_count = count(*)
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100022911
			AND elementseq = @i_elementseq

		IF @v_count = 1
		BEGIN
			SELECT @v_texttype = originalvalue
			FROM imp_batch_detail
			WHERE batchkey = @i_batchkey
				AND row_id = @i_row
				AND elementkey = 100022911
				AND elementseq = @i_elementseq
		END

		SELECT @v_count = count(*)
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100022912
			AND elementseq = @i_elementseq

		IF @v_count = 1
		BEGIN
			SELECT @v_textformat = originalvalue
			FROM imp_batch_detail
			WHERE batchkey = @i_batchkey
				AND row_id = @i_row
				AND elementkey = 100022912
				AND elementseq = @i_elementseq
		END

		SET @v_count = 0

		SELECT @v_count = count(*)
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100022913
			AND elementseq = @i_elementseq

		IF @v_count = 1
		BEGIN
			SELECT @v_text = textvalue
			FROM imp_batch_detail bd
				,imp_batch_lobs bl
			WHERE bd.batchkey = @i_batchkey
				AND bd.row_id = @i_row
				AND bd.elementkey = 100022913
				AND bd.elementseq = @i_elementseq
				AND bd.lobkey = bl.lobkey
		END

		--    
		SET @v_elementkey = NULL
		SET @v_commenttypecode = dbo.resolve_keyset(@v_texttype, 1)
		SET @v_commenttypesubcode = dbo.resolve_keyset(@v_texttype, 2)
		SET @v_elementmnemonic = 'BookComment_' + cast(@v_commenttypecode AS VARCHAR) + '_' + cast(@v_commenttypesubcode AS VARCHAR)

		SELECT @v_count = count(*)
		FROM imp_element_defs
		WHERE elementmnemonic = @v_elementmnemonic

		IF @v_count = 1
		BEGIN
			SELECT @v_elementkey = elementkey
			FROM imp_element_defs
			WHERE elementmnemonic = @v_elementmnemonic
		END
		ELSE
		BEGIN
			SET @v_msg = 'Can not find comment element for ' + coalesce(@v_texttype, ' ')

			EXEC imp_write_feedback @i_batchkey
				,@i_row
				,@v_elementkey
				,@i_elementseq
				,@i_rulekey
				,@v_msg
				,@v_errlevel
				,1
		END

		--
		IF @v_elementkey IS NOT NULL
			AND @v_textformat IS NOT NULL
			AND @v_text IS NOT NULL
		BEGIN
			UPDATE keys
			SET generickey = generickey + 1

			SELECT @v_lobkey = generickey
			FROM keys

			INSERT INTO imp_batch_detail (
				batchkey
				,row_id
				,elementseq
				,elementkey
				,originalvalue
				,lobkey
				,lastuserid
				,lastmaintdate
				)
			VALUES (
				@i_batchkey
				,@i_row
				,@i_elementseq
				,@v_elementkey
				,NULL
				,@v_lobkey
				,@i_userid
				,getdate()
				)

			INSERT INTO imp_batch_lobs (
				batchkey
				,lobkey
				,textvalue
				)
			VALUES (
				@i_batchkey
				,@v_lobkey
				,@v_text
				)
		END
		ELSE
		BEGIN
			SET @v_errlevel = 1
			SET @v_msg = 'unassigned bookcomment'
		END

		IF @v_errlevel >= @i_level
		BEGIN
			EXEC imp_write_feedback @i_batchkey
				,@i_row
				,@v_elementkey
				,@i_elementseq
				,@i_rulekey
				,@v_msg
				,@v_errlevel
				,1
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_100022310001]
	TO PUBLIC
GO


