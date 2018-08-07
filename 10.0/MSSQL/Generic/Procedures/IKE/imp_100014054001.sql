/******************************************************************************
**  Name: imp_100014054001
**  Desc: IKE Type Filter for Language
**  Auth: Marcus Keyser     
**  Date: Jan 17, 2013
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
		WHERE id = object_id(N'[dbo].[imp_100014054001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100014054001]
GO

CREATE PROCEDURE dbo.imp_100014054001 
	@i_batchkey INT
	,@i_row INT
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_level INT
	,@i_userid VARCHAR(50)
AS

BEGIN
	DECLARE 
		@DEBUG AS INT
		,@v_elementkeyValue AS INT
		,@v_elementkeyType AS INT
		,@v_elementSequence AS INT
		,@v_elementval as varchar(max)
		,@v_bookkey AS BIGINT
		,@v_errcode AS INT
		,@v_errmsg AS VARCHAR(4000)
		,@v_errseverity AS INT

	SET @DEBUG = 0
	SET @v_errseverity=1
	SET @v_elementkeyValue = 100014054
	SET @v_elementkeyType = 100014154

	IF @DEBUG <> 0 PRINT 'dbo.imp_100014054001'
	IF @DEBUG <> 0 PRINT  '@i_batchkey  =  ' + coalesce(cast(@i_batchkey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_row  =  ' + coalesce(cast(@i_row as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_elementseq  =  ' + coalesce(cast(@i_elementseq as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_templatekey  =  ' + coalesce(cast(@i_templatekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_rulekey  =  ' + coalesce(cast(@i_rulekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_level  =  ' + coalesce(cast(@i_level as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_userid  =  ' + coalesce(cast(@i_userid as varchar(max)),'*NULL*') 
	
	SELECT	@v_elementval=addlqualifier
	FROM	imp_template_detail
	WHERE	imp_template_detail.templatekey=@i_templatekey
			AND elementkey=@v_elementkeyType

	IF @v_elementval is not null
	BEGIN
		SET @v_errmsg='Language Codes successfully filtered for: ' + cast(@v_elementval as varchar(max))
		BEGIN TRY
			DELETE 
			FROM	imp_batch_detail
			WHERE	(elementkey = @v_elementkeyType
					OR elementkey = @v_elementkeyValue)
					AND row_id = @i_row
					AND batchkey = @i_batchkey
					AND elementseq in (
							SELECT	elementseq
							FROM	imp_batch_detail
							WHERE	elementkey = @v_elementkeyType
									AND Originalvalue <> @v_elementval
									AND row_id = @i_row
									AND batchkey = @i_batchkey)
		END TRY
		BEGIN CATCH
			--something really bad happened ?!?
			SET @v_errcode = @@ERROR
			SET @v_errmsg = ERROR_MESSAGE()
			SET @v_errseverity = 3
			IF @DEBUG <> 0 PRINT @v_errcode
		END CATCH
	END ELSE BEGIN
		SET @v_errmsg='Language Codes NOT filtered: No Language Code found in the Additional Qualifier'
		SET @v_errseverity=1
	END
	IF @DEBUG <> 0 PRINT @v_errmsg
	EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkeyValue, @i_elementseq ,@i_rulekey, @v_errmsg, @v_errseverity, 1
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_100014054001]
	TO PUBLIC
GO