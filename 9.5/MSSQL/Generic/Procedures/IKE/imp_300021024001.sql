/******************************************************************************
**  Name: imp_300021024001
**  Desc: IKE bookcustom
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
		WHERE id = object_id(N'[dbo].[imp_300021024001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300021024001]
GO

CREATE PROCEDURE dbo.imp_300021024001 @i_batch INT
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
	,@o_writehistoryind INT OUTPUT
AS
/* Add/Replace Custom Float 04(Curr Cost) */
BEGIN
	SET NOCOUNT ON

	/* DEFINE BATCH VARIABLES		*/
	DECLARE @v_elementval VARCHAR(4000)
		,@v_errcode INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_elementkey BIGINT
		,@v_lobcheck VARCHAR(20)
		,@v_lobkey INT
		,@v_bookkey INT
	/*  DEFINE LOCAL VARIABLES		*/
	DECLARE @v_new_customfloat FLOAT
		,@v_curr_customfloat FLOAT
		,@v_rowcount INT

	BEGIN
		SET @v_rowcount = 0
		SET @v_new_customfloat = 0
		SET @v_curr_customfloat = 0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'Custom Float 04 Updated'
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)

		/*  GET IMPORTED productline 			*/
		SELECT @v_elementval = LTRIM(RTRIM(originalvalue))
			,@v_elementkey = b.elementkey
		FROM imp_batch_detail b
			,imp_DML_elements d
		WHERE b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND d.dmlkey = @i_dmlkey
			AND d.elementkey = b.elementkey

		/* FIND IMPORT productline ON GENTABLES 		*/
		SELECT @v_new_customfloat = CONVERT(FLOAT, @v_elementval)

		SELECT @v_rowcount = COUNT(*)
		FROM bookcustom
		WHERE bookkey = @v_bookkey

		IF @v_rowcount = 0
		BEGIN
			INSERT INTO bookcustom (
				bookkey
				,customfloat04
				,lastuserid
				,lastmaintdate
				)
			VALUES (
				@v_bookkey
				,@v_new_customfloat
				,@i_userid
				,GETDATE()
				)
		END
		ELSE
		BEGIN
			/* GET CURRENT CURRENT productline VALUE		*/
			SELECT @v_curr_customfloat = COALESCE(customfloat04, -1)--mk20130606>Case 23834 IKE import fails to import non-empty 
			FROM bookcustom
			WHERE bookkey = @v_bookkey

			IF @v_new_customfloat <> @v_curr_customfloat
			BEGIN
				UPDATE bookcustom
				SET customfloat04 = @v_new_customfloat
					,lastuserid = @i_userid
					,lastmaintdate = GETDATE()
				WHERE bookkey = @v_bookkey

				SET @o_writehistoryind = 1
			END
		END

		IF @v_rowcount > 1
		BEGIN
			SET @v_errmsg = 'Did not update Custom Float 04'
		END

		IF @v_errcode < 2
		BEGIN
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
	ON dbo.[imp_300021024001]
	TO PUBLIC
GO


