/******************************************************************************
**  Name: imp_300010226001
**  Desc: IKE associatedtitles  ?????
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
		WHERE id = object_id(N'[dbo].[imp_300010226001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300010226001]
GO

CREATE PROCEDURE dbo.imp_300010226001 
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
	,@o_writehistoryind INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE 
	@DEBUG AS INT
	,@v_elementkey AS INT
	,@v_elementval as varchar(max)
	,@v_bookkey AS BIGINT
	,@v_errcode AS INT
	,@v_errmsg AS VARCHAR(4000)
	,@v_errseverity AS INT

	SET @DEBUG = 1
	IF @DEBUG <> 0 PRINT 'dbo.imp_300010226001'
	
	IF @DEBUG <> 0 PRINT  '@i_batch  =  ' + coalesce(cast(@i_batch as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_row  =  ' + coalesce(cast(@i_row as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_dmlkey  =  ' + coalesce(cast(@i_dmlkey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_titlekeyset  =  ' + coalesce(cast(@i_titlekeyset as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_contactkeyset  =  ' + coalesce(cast(@i_contactkeyset as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_templatekey  =  ' + coalesce(cast(@i_templatekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_elementseq  =  ' + coalesce(cast(@i_elementseq as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_level  =  ' + coalesce(cast(@i_level as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_userid  =  ' + coalesce(cast(@i_userid as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_newtitleind  =  ' + coalesce(cast(@i_newtitleind as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_newcontactind  =  ' + coalesce(cast(@i_newcontactind as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@o_writehistoryind  =  ' + coalesce(cast(@o_writehistoryind as varchar(max)),'*NULL*') 

	SET @v_errseverity=1
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)

	SELECT	@v_elementval = originalvalue,
			@v_elementkey = b.elementkey
	FROM	imp_batch_detail b , imp_DML_elements d
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND b.elementkey = d.elementkey
			AND d.DMLkey = @i_dmlkey

	IF @v_elementval IS NOT NULL
	BEGIN
		BEGIN TRY
			IF @DEBUG <> 0 PRINT  '@v_elementkey =  ' + cast(@v_elementkey as varchar(max))
			IF @DEBUG <> 0 PRINT  '@v_elementval =  ' + cast(@v_elementval as varchar(max))
			
			IF EXISTS (SELECT * FROM associatedtitles WHERE bookkey=21839947)
			BEGIN
				SET @v_errmsg = 'insert into associatedtitles'
			END ELSE BEGIN
				SET @v_errmsg = 'update associatedtitles'
			END
			
		END TRY
		BEGIN CATCH
			--something really bad happened ?!?
			SET @v_errcode = @@ERROR
			SET @v_errmsg = ERROR_MESSAGE()
			SET @v_errseverity = 3
			IF @DEBUG <> 0 PRINT @v_errcode
			IF @DEBUG <> 0 PRINT @v_errmsg
		END CATCH
		
	END ELSE BEGIN
		SET @v_errmsg='Task template dates were not updated: Either the TaskKey or the ScheduleDate was not specified'
	END
	IF @DEBUG <> 0 PRINT @v_errmsg
	EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errseverity, 3
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300010226001]
	TO PUBLIC
GO