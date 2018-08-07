/******************************************************************************
**  Name: imp_300014054001
**  Desc: IKE Add/Replace Language
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/20/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
*******************************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_300014054001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300014054001]
GO

CREATE PROCEDURE dbo.imp_300014054001 @i_batch INT
	,@i_row INT
	,@i_dmlkey BIGINT
	,@i_titlekeyset VARCHAR(500)
	,@i_contactkeyset VARCHAR(500)
	,@i_templatekey INT
	,@i_elementseq INT
	,@i_level INT
	,@i_userid VARCHAR(50)
	,@i_newtitleind INT
	,@i_newcontactind INT
	,@o_writehistoryind INT
OUTPUT AS

/* Add/Replace Language */
BEGIN
	SET NOCOUNT ON

	/* DEFINE BATCH VARIABLES		*/
	DECLARE @v_elementval VARCHAR(4000)
		,@v_errcode INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_elementkey BIGINT
		,@v_datacode INT
		,@v_datadesc VARCHAR(MAX)
		,@v_lobcheck VARCHAR(20)
		,@v_lobkey INT
		,@v_bookkey INT
		
	/*  DEFINE LOCAL VARIABLES		*/
	DECLARE @v_language INT
		,@v_languagecode INT
		,@v_hit INT

	BEGIN
		SET @v_hit = 0
		SET @v_language = 0
		SET @v_languagecode = 0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'Language updated'
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)

		/*  GET IMPORTED language 			*/
		SELECT @v_elementval = originalvalue
			,@v_elementkey = b.elementkey
		FROM imp_batch_detail b
			,imp_DML_elements d
		WHERE b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND d.dmlkey = @i_dmlkey
			AND d.elementkey = b.elementkey

		/* GET CURRENT CURRENT language VALUE		*/
		SELECT @v_language = COALESCE(languagecode, 0)
		FROM bookdetail
		WHERE bookkey = @v_bookkey

		/* FIND IMPORT language ON GENTABLES 		*/
		EXEC find_gentables_mixed @v_elementval
			,318
			,@v_languagecode OUTPUT
			,@v_datadesc OUTPUT

		IF @v_languagecode IS NOT NULL
		BEGIN
			/* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR  */
			IF @v_languagecode <> @v_language
			BEGIN
				UPDATE bookdetail
				SET languagecode = @v_languagecode
					,lastuserid = @i_userid
					,lastmaintdate = GETDATE()
				WHERE bookkey = @v_bookkey

				SET @v_errmsg = 'Language updated'

				EXECUTE imp_write_feedback @i_batch
					,@i_row
					,@v_elementkey
					,@i_elementseq
					,@i_dmlkey
					,@v_errmsg
					,@i_level
					,3

				SET @o_writehistoryind = 1
			END
		END
		ELSE
		BEGIN
			SET @v_errcode = 2
			SET @v_errmsg = 'Can not find (' + coalesce(@v_elementval, 'n/a') + ') value on User Table (318) for Language'

			EXECUTE imp_write_feedback @i_batch
				,@i_row
				,@v_elementkey
				,@i_elementseq
				,@i_dmlkey
				,@v_errmsg
				,@i_level
				,3
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300014054001]
	TO PUBLIC
GO

