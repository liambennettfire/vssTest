/******************************************************************************
**  Name: imp_300014051002
**  Desc: IKE Add/Replace Series
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
		WHERE id = object_id(N'[dbo].[imp_300014051002]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300014051002]
GO

CREATE PROCEDURE dbo.imp_300014051002 
	@i_batch INT
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

/* Add/Replace Series */
BEGIN
	SET NOCOUNT ON

	/* DEFINE BATCH VARIABLES		*/
	DECLARE 
		@v_elementval VARCHAR(4000)
		,@v_errcode INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_elementkey BIGINT
		,@v_lobcheck VARCHAR(20)
		,@v_lobkey INT
		,@v_bookkey INT
	/*  DEFINE LOCAL VARIABLES		*/
	DECLARE @v_Series INT
		,@v_Seriescode INT
		,@v_hit INT
		,@Debug INT

	BEGIN
		SET @v_hit = 0
		SET @v_Series = 0
		SET @v_Seriescode = 0
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'Series updated'
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @Debug=0
		
		if @Debug <>0 print 'imp_300014051002 :: Add/Replace Series'

		/*  GET IMPORTED Series 			*/
		SELECT @v_elementval = LTRIM(RTRIM(originalvalue))
			,@v_elementkey = b.elementkey
		FROM imp_batch_detail b
			,imp_DML_elements d
		WHERE b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND d.dmlkey = @i_dmlkey
			AND d.elementkey = b.elementkey
			
		/* GET CURRENT CURRENT Series VALUE		*/
		SELECT @v_Series = COALESCE(Seriescode, 0)
		FROM bookdetail
		WHERE bookkey = @v_bookkey
		
		declare @v_datacode int 
		declare @v_datadesc varchar(max)
		print '@v_elementval';print @v_elementval
		exec find_gentables_mixed @v_elementval,327,@v_datacode output,@v_datadesc output
		
		if @v_datacode is not null
		begin
		
			--/* FIND IMPORT Series ON GENTABLES 		*/
			--SELECT @v_hit = COUNT(*)
			--FROM gentables
			--WHERE tableid = 327	AND alternatedesc1 = @v_elementval
			
			--IF @v_hit = 1
			--BEGIN
			--	if @Debug <>0 print 'alternatedesc1 = @v_elementval'
			--	SELECT @v_Seriescode = datacode
			--	FROM gentables
			--	WHERE tableid = 327 AND alternatedesc1 = @v_elementval
			--END
			
			set @v_Seriescode=@v_datacode
		END
		ELSE
		BEGIN
			--SELECT @v_hit = COUNT(*)
			--FROM gentables
			--WHERE tableid = 327	AND datadesc = @v_elementval

			--IF @v_hit = 1
			--BEGIN
			--	if @Debug <>0 print 'datadesc = @v_elementval'
			--	SELECT @v_Seriescode = datacode
			--	FROM gentables
			--	WHERE tableid = 327	AND datadesc = @v_elementval
			--END
			--ELSE
			SET @v_errcode = 2
			SET @v_errmsg = 'Can not find Series on gentables'
			if @Debug <>0 print @v_errmsg
		END

		/* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR	*/
		if @Debug <>0 print '@v_elementval = ' + cast(coalesce(@v_elementval,'*NULL*') as varchar(max))
		if @Debug <>0 print '@v_Seriescode = ' + cast(coalesce(@v_Seriescode,'*NULL*') as varchar(max))
		if @Debug <>0 print '@v_Series = ' + cast(coalesce(@v_Series,'*NULL*') as varchar(max))
		
		IF (@v_Seriescode <> @v_Series) AND @v_errcode = 1
		BEGIN
			if @Debug <>0 print 'VALUE HAS CHANGED - UPDATE BOOKDETAIL'
			UPDATE bookdetail
			SET Seriescode = @v_Seriescode
				,lastuserid = @i_userid
				,lastmaintdate = GETDATE()
			WHERE bookkey = @v_bookkey

			SET @o_writehistoryind = 1
		END

		IF @v_errcode < 2
		BEGIN
			EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_errmsg,@i_level,3
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300014051002]
	TO PUBLIC
GO
