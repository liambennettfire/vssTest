/******************************************************************************
**  Name: imp_100022914001
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_100022914001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100022914001]
GO

CREATE PROCEDURE [dbo].[imp_100022914001] 
	@i_batchkey INT
	,@i_row INT
	--,@i_elementkey int
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_level INT
	,@i_userid VARCHAR(50)
AS
DECLARE @v_errcode INT
	,@v_errlevel INT
	,@v_msg VARCHAR(500)
	,@v_texttype VARCHAR(4000)
	,@v_textformat VARCHAR(4000)
	,@v_text VARCHAR(max)
	,@v_elementkey INT
	,@v_lobkey INT
	,@v_count INT
	,@DEBUG INT

BEGIN
	--START SPROC
	SET @DEBUG = 0
	SET @v_errlevel = 1
	SET @v_msg = 'Onix Bookcomment assignment'
	IF @DEBUG<>0 PRINT 'START: imp_100022914001'
	--       
	--Comment_OR_Citation_Type_D102
	SELECT @v_count = count(*)
	FROM imp_batch_detail
	WHERE batchkey = @i_batchkey
		AND row_id = @i_row
		AND elementkey = 100022914
		AND elementseq = @i_elementseq

	IF @v_count = 1
	BEGIN
		SELECT @v_elementkey = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100022914
			AND elementseq = @i_elementseq
	END

	--TextFormat_onix D103
	SET @v_count = 0

	SELECT @v_count = count(*)
	FROM imp_batch_detail
	WHERE batchkey = @i_batchkey
		AND row_id = @i_row
		AND elementkey = 100022916
		AND elementseq = @i_elementseq

	IF @v_count = 1
	BEGIN
		SELECT @v_textformat = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey
			AND row_id = @i_row
			AND elementkey = 100022916
			AND elementseq = @i_elementseq
	END

	--Text_onix D104
	SET @v_count = 0

	SELECT @v_count = count(*)
	FROM imp_batch_detail
	WHERE batchkey = @i_batchkey
		AND row_id = @i_row
		AND elementkey = 100022917
		AND elementseq = @i_elementseq

	IF @v_count = 1
	BEGIN
		SELECT @v_text = textvalue
		FROM imp_batch_detail bd
			,imp_batch_lobs bl
		WHERE bd.batchkey = @i_batchkey
			AND bd.row_id = @i_row
			AND bd.elementkey = 100022917
			AND bd.elementseq = @i_elementseq
			AND bd.lobkey = bl.lobkey
	END

	--    
	IF @v_elementkey IS NOT NULL
	BEGIN
		if datalength (cast(@v_elementkey as varchar))<8
		  begin
		    select @v_msg='Missing comment mapping for '+cast (@v_elementkey as varchar)+'. See element key 100022914 in the template'		EXEC imp_write_feedback @i_batchkey,@i_row,@v_elementkey,@i_elementseq,@i_rulekey,@v_msg,@v_errlevel,1
			EXEC imp_write_feedback @i_batchkey,@i_row,@v_elementkey,@i_elementseq,@i_rulekey,@v_msg,@v_errlevel,1
		  end
		else
		BEGIN
			UPDATE keys
			SET generickey = generickey + 1

			SELECT @v_lobkey = generickey
			FROM keys
			
			IF @DEBUG<>0 PRINT '@i_batchkey = ' + cast(@i_batchkey as varchar(max))
			IF @DEBUG<>0 PRINT '@i_row = ' + cast(@i_row as varchar(max))
			IF @DEBUG<>0 PRINT '@i_elementseq = ' + cast(@i_elementseq as varchar(max))
			IF @DEBUG<>0 PRINT '@v_elementkey = ' + cast(@v_elementkey as varchar(max))
			IF @DEBUG<>0 PRINT '@v_text = ' + cast(@v_text as varchar(max))
			
			INSERT INTO imp_batch_detail (batchkey,row_id,elementseq,elementkey,originalvalue,lobkey,lastuserid,lastmaintdate)
			VALUES (@i_batchkey,@i_row,@i_elementseq,@v_elementkey,NULL,@v_lobkey,'imp_100022914001',getdate())

			INSERT INTO imp_batch_lobs (batchkey,lobkey,textvalue)
			VALUES (@i_batchkey,@v_lobkey,@v_text)
		END
	END
	ELSE
	BEGIN
		SET @v_errlevel = 2
		SET @v_msg = 'unassigned bookcomment'
	END

	IF @v_errlevel >= @i_level
	BEGIN
		EXEC imp_write_feedback @i_batchkey,@i_row,@v_elementkey,@i_elementseq,@i_rulekey,@v_msg,@v_errlevel,1
	END
--END SPROC    
IF @DEBUG<>0 PRINT 'END: imp_100022914001'
END
