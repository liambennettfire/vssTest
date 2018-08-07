/******************************************************************************
**  Name: imp_100022601001
**  Desc: IKE Onix OtherText assignment
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
		WHERE id = object_id(N'[dbo].[imp_100022601001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100022601001]
GO

CREATE PROCEDURE dbo.imp_100022601001 @i_batchkey INT
	,@i_row INT
	--,@i_elementkey int
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_level INT
	,@i_userid VARCHAR(50)
AS
BEGIN
	/*    START SPROC    */
	DECLARE @v_errcode INT
		,@v_errlevel INT
		,@v_msg VARCHAR(500)
		,@v_texttype VARCHAR(4000)
		,@v_textformat VARCHAR(4000)
		,@v_text VARCHAR(max)
		,@v_elementkey INT
		,@v_lobkey INT
		,@v_count INT
		,@Debug INT

	BEGIN
		SET @v_errlevel = 1
		SET @v_msg = 'Onix OtherText assignment'
		SET @Debug = 0

		IF @Debug <> 0 PRINT 'Onix OtherText assignment'
		--       
		SELECT @v_texttype = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100022601
			AND elementseq = @i_elementseq

		SELECT @v_textformat = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100022602
			AND elementseq = @i_elementseq

		SELECT @v_text = textvalue
		FROM imp_batch_detail bd
			,imp_batch_lobs bl
		WHERE bd.batchkey = @i_batchkey
			AND bd.row_id = @i_row
			AND bd.elementkey = 100022603
			AND bd.elementseq = @i_elementseq
			AND bd.lobkey = bl.lobkey

		IF @Debug <> 0 PRINT '@v_texttype = ' + coalesce(cast(@v_texttype AS VARCHAR(max)), '*NULL*')
		IF @Debug <> 0 PRINT '@v_textformat = ' + coalesce(cast(@v_textformat AS VARCHAR(max)), '*NULL*')
		IF @Debug <> 0 PRINT '@v_text = ' + coalesce(cast(@v_text AS VARCHAR(max)), '*NULL*')

		--    
		SET @v_elementkey = NULL
		SET @v_texttype = '@' + @v_texttype

		SELECT @v_elementkey = elementkey
		FROM imp_template_detail
		WHERE templatekey = @i_templatekey
			AND defaultvalue = @v_texttype

		IF @Debug <> 0 PRINT '@v_elementkey = ' + coalesce(cast(@v_elementkey AS VARCHAR(max)), '*NULL*')

		IF @v_textformat IN ('00','02','06','07') 
			AND @v_text IS NOT NULL
			AND @v_elementkey IS NOT NULL
		BEGIN
			UPDATE keys
			SET generickey = generickey + 1

			SELECT @v_lobkey = generickey
			FROM keys

			/*mk05092012> Need to make sure that the element "@v_elementkey" isn't already in imp_batch_detail.
			It can get in there as a rowinsert in an XML Explicit template.  If it's already in the template then 
			do an update, otherwise continue on with the insert*/
			
			SELECT @v_count = COUNT(*)
			FROM imp_batch_detail
			WHERE batchkey = @i_batchkey
				AND row_id = @i_row
				AND elementseq = @i_elementseq
				AND elementkey = @v_elementkey

			IF @v_count = 0
				BEGIN	
					IF @Debug <> 0 PRINT 'Inserting elementkey: ' + coalesce(cast(@v_elementkey AS VARCHAR(max)), '*NULL*') + ' into imp_batch_detail'
					INSERT INTO imp_batch_detail (batchkey,row_id,elementseq,elementkey,originalvalue,lobkey,lastuserid,lastmaintdate)
					VALUES (@i_batchkey,@i_row,@i_elementseq,@v_elementkey,NULL,@v_lobkey,@i_userid,getdate())
				END
			ELSE
				BEGIN
					IF @Debug <> 0 PRINT 'Updating elementkey: ' + coalesce(cast(@v_elementkey AS VARCHAR(max)), '*NULL*') + ' in imp_batch_detail'
					UPDATE imp_batch_detail
					SET originalvalue = NULL
						,lobkey = @v_lobkey
					WHERE batchkey = @i_batchkey
						AND row_id = @i_row
						AND elementseq = @i_elementseq
						AND elementkey = @v_elementkey
				END

			INSERT INTO imp_batch_lobs (batchkey,lobkey,textvalue)
			VALUES (@i_batchkey,@v_lobkey,@v_text)
		END

		IF @v_errlevel >= @i_level
		BEGIN
			EXEC imp_write_feedback @i_batchkey,@i_row,@v_elementkey,@i_elementseq,@i_rulekey,@v_msg,@v_errlevel,1
		END
	END
		/*     END SPROC     */
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_100022601001]
	TO PUBLIC
GO