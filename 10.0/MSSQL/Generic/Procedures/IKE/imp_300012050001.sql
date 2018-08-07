/******************************************************************************
**  Name: imp_300012050001
**  Desc: IKE Add/Replace Media & Format
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
		WHERE id = object_id(N'[dbo].[imp_300012050001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300012050001]
GO

CREATE PROCEDURE dbo.imp_300012050001 @i_batch INT
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
/* Add/Replace Media & Format */
BEGIN
	DECLARE 
	@DEBUG AS INT
	,@v_elementval AS VARCHAR(max)
	,@v_bookkey AS BIGINT
	,@v_errcode AS INT
	,@v_errmsg AS VARCHAR(4000)
	,@v_errseverity AS INT
	,@v_format VARCHAR(100)
	,@v_media VARCHAR(100)
	,@v_new_format VARCHAR(100)
	,@v_new_FormatCode INT
	,@v_new_MediaCode INT
	,@v_cur_FormatCode INT
	,@v_cur_MediaCode INT
	,@v_elementkey INT

	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT ''
	IF @DEBUG <> 0 PRINT 'dbo.imp_300012050001'
	
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
	
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
	IF @DEBUG <> 0 PRINT  '@v_bookkey = ' + coalesce(cast(@v_bookkey as varchar(max)),'*NULL*') 
		
	SELECT @v_elementkey = elementkey
	FROM imp_dml_elements
	WHERE dmlkey = @i_dmlkey	
	IF @DEBUG <> 0 PRINT  '@v_elementkey = ' + coalesce(cast(@v_elementkey as varchar(max)),'*NULL*') 
	
	IF @DEBUG <> 0 PRINT 'Get the format from the incoming XML'
	SELECT @v_format =  originalvalue
	FROM imp_batch_detail 
	WHERE batchkey = @i_batch
      		AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey = 100012050
	IF @DEBUG <> 0 PRINT  '@v_format = ' + coalesce(cast(@v_format as varchar(max)),'*NULL*')
		
	IF @DEBUG <> 0 PRINT 'Get the media from the incoming XML'
	SELECT @v_media =  originalvalue
	FROM imp_batch_detail 
	WHERE batchkey = @i_batch
			AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey = 100012051
	IF @DEBUG <> 0 PRINT  '@v_media = ' + coalesce(cast(@v_media as varchar(max)),'*NULL*')
	
	IF @v_format is null 
	BEGIN
		SET @v_errmsg = 'Format is missing'
		SET @v_errcode = 2
		IF @DEBUG <> 0 PRINT @v_errmsg
		EXECUTE imp_write_feedback @i_batch, @i_row,100012050 , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
		RETURN
	END
	
	IF @v_media IS NULL
	BEGIN
		SET @v_errmsg = 'Media is missing ... trying to derive media from format (' + coalesce(cast(@v_format as varchar(max)),'*NULL*') + ')'
		SET @v_errcode = 1
		EXECUTE imp_write_feedback @i_batch, @i_row,100012050 , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
		
		IF @DEBUG <> 0 PRINT @v_errmsg
		EXEC find_subgentables_mixed @v_format,312,@v_new_MediaCode output,@v_new_FormatCode output,@v_new_format output
			
	END ELSE BEGIN
		
		IF @DEBUG <> 0 PRINT 'Media/Format were found ... looking up media/format codes'
		EXEC find_gentables_mixed @v_media,312,@v_new_MediaCode output,@v_new_format output
		EXEC find_subgentables_mixed @v_format,312,@v_new_MediaCode output,@v_new_FormatCode output,@v_new_format output
	END
	
	IF @DEBUG <> 0 PRINT  '@v_new_MediaCode = ' + coalesce(cast(@v_new_MediaCode as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_new_FormatCode = ' + coalesce(cast(@v_new_FormatCode as varchar(max)),'*NULL*') 

	IF @v_new_MediaCode IS NULL
	BEGIN
		SET @v_errmsg = 'Media could not be derived media from format (' + coalesce(cast(@v_format as varchar(max)),'*NULL*') + ')'
		SET @v_errcode = 2
		EXECUTE imp_write_feedback @i_batch, @i_row,100012050 , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3		
		IF @DEBUG <> 0 PRINT @v_errmsg
		RETURN
	END
	
	IF @DEBUG <> 0 PRINT  'Media/Format Codes have been found ... now find exsiting codes and compare to see if update is required'
	SELECT	@v_cur_MediaCode = COALESCE(mediatypecode, 0)
			,@v_cur_FormatCode = COALESCE(mediatypesubcode, 0)
	FROM	bookdetail
	WHERE	bookkey = @v_bookkey

	IF @DEBUG <> 0 PRINT '@v_cur_mediaCode = ' + coalesce(cast(@v_cur_mediaCode AS VARCHAR(max)),'*NULL*')
	IF @DEBUG <> 0 PRINT '@v_cur_formatCode = ' + coalesce(cast(@v_cur_formatCode AS VARCHAR(max)),'*NULL*')
	
	IF coalesce(@v_new_MediaCode,0) <> coalesce(@v_cur_MediaCode,0) OR coalesce(@v_new_FormatCode,0) <> coalesce(@v_cur_FormatCode,0)
	BEGIN
		BEGIN TRY
			IF @DEBUG <> 0 PRINT 'START UPDATE bookdetail'
			UPDATE bookdetail
			SET mediatypecode = @v_new_MediaCode,
				mediatypesubcode = @v_new_FormatCode,
				lastuserid = @i_userid,
				lastmaintdate = GETDATE()
			WHERE bookkey = @v_bookkey

			SET @o_writehistoryind = 1			
			IF @DEBUG <> 0 PRINT 'END UPDATE bookdetail'
		END TRY
		BEGIN CATCH
			IF @DEBUG <> 0 PRINT 'something really bad happened ?!?'
			SET @v_errcode = @@ERROR
			SET @v_errmsg = ERROR_MESSAGE()
			SET @v_errseverity = 3
			IF @DEBUG <> 0 PRINT @v_errcode
			IF @DEBUG <> 0 PRINT @v_errmsg		
		END CATCH
	END
		
	SET @v_errmsg='Add/Replace Media & Format Completed successfully'
	SET @v_errcode=1
	
	IF @DEBUG <> 0 PRINT @v_errmsg
	EXECUTE imp_write_feedback @i_batch, @i_row,100012050 , @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errcode, 3
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300012050001]
	TO PUBLIC
GO


