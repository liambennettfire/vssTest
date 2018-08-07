SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

/******************************************************************************
**  Name: [imp_300014072001]
**  Desc: IKE Series Update by External Code
**  Auth: Bennett     
**  Date: 1/10/2017
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  1/10/2017     JHESS      original - References were causing errors, 
**							 couldn't find a copy of this SP anywhere, 
**							 remade it using 300014051002 as the template.
*******************************************************************************/

IF EXISTS (SELECT
		*
	FROM dbo.sysobjects
	WHERE id = OBJECT_ID(N'[dbo].[imp_300014072001]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[imp_300014072001]
GO

CREATE PROCEDURE [dbo].[imp_300014072001] @i_batch INT
, @i_row INT
, @i_dmlkey BIGINT
, @i_titlekeyset VARCHAR(500)
, @i_contactkeyset VARCHAR(500)
, @i_templatekey INT
, @i_elementseq INT
, @i_level INT
, @i_userid VARCHAR(50)
, @i_newtitleind INT
, @i_newcontactind INT
, @o_writehistoryind INT
OUTPUT
AS

/* Add/Replace Series */
BEGIN
	SET NOCOUNT ON

	/* DEFINE BATCH VARIABLES		*/
	DECLARE	@v_elementval VARCHAR(4000),
			@v_errcode INT,
			@v_errmsg VARCHAR(4000),
			@v_elementdesc VARCHAR(4000),
			@v_elementkey BIGINT,
			@v_lobcheck VARCHAR(20),
			@v_lobkey INT,
			@v_bookkey INT
	/*  DEFINE LOCAL VARIABLES		*/
	DECLARE	@v_Series INT,
			@v_Seriescode INT,
			@v_hit INT,
			@Debug INT

	BEGIN
		SET @v_hit = 0
		SET @v_Series = 0
		SET @v_Seriescode = 0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'Series updated'
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @Debug = 0

		--if @Debug <>0 print '[imp_300014072001] :: Add/Replace Series'
		--if @Debug <>0 print '--------Incoming Values:'
		--if @Debug <>0 print '@i_batch = ' + cast(coalesce(@i_batch,'*NULL*') as varchar(max))
		--if @Debug <>0 print '@i_row = ' + cast(coalesce(@i_row,'*NULL*') as varchar(max))
		--if @Debug <>0 print '@i_dmlkey = ' + cast(coalesce(@i_dmlkey,'*NULL*') as varchar(max))
		--if @Debug <>0 print '@i_titlekeyset = ' + cast(coalesce(@i_titlekeyset,'*NULL*') as varchar(max))
		----if @Debug <>0 print '@i_contactkeyset = ' + cast(coalesce(@i_contactkeyset,'*NULL*') as varchar(max))
		--if @Debug <>0 print '@i_templatekey = ' + cast(coalesce(@i_templatekey,'*NULL*') as varchar(max))
		--if @Debug <>0 print '@i_elementseq = ' + cast(coalesce(@i_elementseq,'*NULL*') as varchar(max))
		--if @Debug <>0 print '@i_level = ' + cast(coalesce(@i_level,'*NULL*') as varchar(max))
		--if @Debug <>0 print '@i_userid = ' + cast(coalesce(@i_userid,'*NULL*') as varchar(max))
		--if @Debug <>0 print '@i_newtitleind = ' + cast(coalesce(@i_newtitleind,'*NULL*') as varchar(max))
		--if @Debug <>0 print '@i_newcontactind = ' + cast(coalesce(@i_newcontactind,'*NULL*') as varchar(max))
		--if @Debug <>0 print '--------End Incoming Values:'

		/*  GET IMPORTED Series 			*/
		SELECT
			@v_elementval = LTRIM(RTRIM(originalvalue)),
			@v_elementkey = b.elementkey
		FROM	imp_batch_detail b,
				imp_DML_elements d
		WHERE b.batchkey = @i_batch
		AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND d.DMLkey = @i_dmlkey
		AND d.elementkey = b.elementkey

		--if @Debug <>0 print 'GET CURRENT CURRENT Series VALUE: @v_elementval = ' + cast(coalesce(@v_elementval,'*NULL*') as varchar(max))

		/* GET CURRENT CURRENT Series VALUE		*/
		SELECT
			@v_Series = COALESCE(seriescode, 0)
		FROM bookdetail
		WHERE bookkey = @v_bookkey

		--if @Debug <>0 print 'GET CURRENT CURRENT Series VALUE: @v_Series = ' + cast(coalesce(@v_Series,'*NULL*') as varchar(max))

		DECLARE @v_datacode INT
		DECLARE @v_datadesc VARCHAR(MAX)

		EXEC find_gentables_mixed	@v_elementval,
									327,
									@v_datacode OUTPUT,
									@v_datadesc OUTPUT

		--IF @Debug <> 0
		--	PRINT '@v_datacode = ' + CAST(COALESCE(@v_datacode, 0) AS VARCHAR(MAX))
		--IF @Debug <> 0
		--	PRINT '@v_datadesc = ' + CAST(COALESCE(@v_datadesc, '*NULL*') AS VARCHAR(MAX))

		IF @v_datacode IS NOT NULL
		BEGIN

			/* FIND IMPORT Series ON GENTABLES 		*/
			SELECT
				@v_hit = COUNT(*)
			FROM gentables
			WHERE tableid = 327
			AND externalcode = @v_elementval

			IF @v_hit = 1
			BEGIN
				--IF @Debug <> 0
				--	PRINT 'externalcode = ' + CAST(COALESCE(@v_elementval, '*NULL*') AS VARCHAR(MAX))
				SELECT
					@v_Seriescode = datacode
				FROM gentables
				WHERE tableid = 327
				AND externalcode = @v_elementval
			END

			SET @v_Seriescode = @v_datacode
		END
		ELSE
		BEGIN
			SELECT
				@v_hit = COUNT(*)
			FROM gentables
			WHERE tableid = 327
			AND datadesc = @v_elementval

			IF @v_hit = 1
			BEGIN
				--IF @Debug <> 0
				--	PRINT 'datadesc = @v_elementval'
				SELECT
					@v_Seriescode = datacode
				FROM gentables
				WHERE tableid = 327
				AND datadesc = @v_elementval
			END
			ELSE
				SET @v_errcode = 2
			SET @v_errmsg = 'Can not find Series on gentables'
			IF @Debug <> 0
				PRINT @v_errmsg
		END

		/* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR	*/
		--IF @Debug <> 0
		--	PRINT '@v_elementval = ' + CAST(COALESCE(@v_elementval, '*NULL*') AS VARCHAR(MAX))
		--IF @Debug <> 0
		--	PRINT '@v_Seriescode = ' + CAST(COALESCE(@v_Seriescode, '*NULL*') AS VARCHAR(MAX))
		--IF @Debug <> 0
		--	PRINT '@v_Series = ' + CAST(COALESCE(@v_Series, '*NULL*') AS VARCHAR(MAX))

		IF (@v_Seriescode <> @v_Series)
			AND @v_errcode = 1
		BEGIN
			--IF @Debug <> 0
			--	PRINT 'VALUE HAS CHANGED - UPDATE BOOKDETAIL'
			UPDATE bookdetail
			SET	seriescode = @v_Seriescode,
				lastuserid = @i_userid,
				lastmaintdate = GETDATE()
			WHERE bookkey = @v_bookkey

			SET @o_writehistoryind = 1
		END

		IF @v_errcode < 2
		BEGIN
			EXECUTE imp_write_feedback	@i_batch,
										@i_row,
										@v_elementkey,
										@i_elementseq,
										@i_dmlkey,
										@v_errmsg,
										@i_level,
										3
		END
	END
END