/******************************************************************************
**  Name: imp_200100050002
**  Desc: IKE Validated TaskTemplate Name
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
		WHERE id = object_id(N'[dbo].[imp_200100050002]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_200100050002]
GO

CREATE PROCEDURE dbo.imp_200100050002 
	 @i_batch INT
	,@i_row INT
	,@i_elementkey INT
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_rpt INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE 
		 @DEBUG AS INT
		,@v_elementval VARCHAR(4000)
		,@v_errlevel INT
		,@v_errmsg VARCHAR(4000)
		,@v_errcode INT
		,@v_datacode INT
		,@v_datadesc VARCHAR(200)
		,@v_elementdesc VARCHAR(4000)
		,@v_row_count INT
		
	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT 'dbo.imp_200100050002'
	
	IF @DEBUG <> 0 PRINT  '@i_batch  =  ' + coalesce(cast(@i_batch as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_row  =  ' + coalesce(cast(@i_row as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_templatekey  =  ' + coalesce(cast(@i_templatekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_elementseq  =  ' + coalesce(cast(@i_elementseq as varchar(max)),'*NULL*') 
	
	BEGIN TRY	
		SELECT	@v_row_count=COUNT(*)
		FROM	taskview tv
				INNER JOIN imp_batch_detail bd ON tv.taskviewdesc=bd.originalvalue
		WHERE	batchkey = @i_batch
				AND row_id = @i_row
				AND elementkey =  @i_elementkey
				AND elementseq =  @i_elementseq	
				AND taskgroupind = 1
	END TRY
	BEGIN CATCH
		SET @v_errcode = @@ERROR
		SET @v_errmsg = ERROR_MESSAGE()
		SET @v_errlevel = 3
		IF @DEBUG <> 0 PRINT @v_errcode
		IF @DEBUG <> 0 PRINT @v_errmsg

		EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2
		RETURN		
	END CATCH
	
	SET	@v_row_count=coalesce(@v_row_count,0)
	
	IF  @v_row_count = 1 BEGIN
		SET @v_errmsg='Validated TaskTemplate Name'
		SET @v_errlevel=1
	END ELSE IF @v_row_count = 0 BEGIN
		SET @v_errmsg='Invalid TaskTemplate Name ... Name could not be found'
		SET @v_errlevel=3
	END ELSE BEGIN
		SET @v_errmsg='Invalid TaskTemplate Name ... Name was found more than once'
		SET @v_errlevel=3
	END
	
	EXECUTE imp_write_feedback @i_batch, @i_row, @i_elementkey, @i_elementseq, @i_rulekey , @v_errmsg, @v_errlevel, 2	
			
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_200100050002]
	TO PUBLIC
GO

