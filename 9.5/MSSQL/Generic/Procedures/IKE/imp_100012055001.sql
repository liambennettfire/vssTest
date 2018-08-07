/******************************************************************************
**  Name: imp_100012055001
**  Desc: IKE created\appended format name
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
		WHERE id = object_id(N'[dbo].[imp_100012055001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100012055001]
GO

CREATE PROCEDURE dbo.imp_100012055001 @i_batchkey INT
	,@i_row INT
	,
	--  @i_elementkey int,
	@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_level INT
	,@i_userid VARCHAR(50)
AS
/* created\appended format name  */
BEGIN
	DECLARE @v_formatadd VARCHAR(4000)
		,@v_format VARCHAR(4000)
		,@v_errlevel INT
		,@v_msg VARCHAR(4000)
		,@v_fmsg VARCHAR(4000)

	BEGIN
		SET @v_errlevel = 0
		SET @v_formatadd = NULL
		SET @v_format = NULL
		SET @v_msg = 'Format name created\appended'

		SELECT @v_format = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			--AND elementseq=@i_elementseq
			AND elementkey = 100012050

		SELECT @v_formatadd = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey = 100012055

		IF len(coalesce(@v_formatadd, '')) > 0
		BEGIN
			IF len(coalesce(@v_format, '')) > 0
			BEGIN
				IF substring(@v_format, 1, 1) = '['
				BEGIN
					SET @v_format = coalesce(@v_formatadd, '')
				END
				ELSE
				BEGIN
					IF substring(@v_formatadd, 1, 1) <> '['
					BEGIN
						SET @v_format = @v_format + ',' + coalesce(@v_formatadd, '')
					END
				END

				UPDATE imp_batch_detail
				SET originalvalue = @v_format
				WHERE batchkey = @i_batchkey
					AND row_id = @i_row
					--AND elementseq=@i_elementseq
					AND elementkey = 100012050

				SET @v_msg = 'Format name appended'
			END
			ELSE
			BEGIN
				INSERT INTO imp_batch_detail (
					batchkey
					,row_id
					,elementkey
					,elementseq
					,originalvalue
					,lastuserid
					,lastmaintdate
					)
				VALUES (
					@i_batchkey
					,@i_row
					,100012050
					,@i_elementseq
					,@v_formatadd
					,'imp_load_master'
					,getdate()
					)

				SET @v_msg = 'Format name created'
			END
		END

		IF @v_errlevel >= @i_level
		BEGIN
			EXECUTE imp_write_feedback @i_batchkey
				,@i_row
				,100012050
				,@i_elementseq
				,100012055001
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
	ON dbo.[imp_100012055001]
	TO PUBLIC
GO


