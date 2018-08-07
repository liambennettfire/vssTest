/******************************************************************************
**  Name: imp_load_xml_explicit
**  Desc: IKE This is a consolidated sproc to update Format or Media
**			 it can be linked to either field elementkey
**  Auth: Marcus Keyser     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     
*******************************************************************************/

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_310012050001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_310012050001]
GO

CREATE PROCEDURE dbo.imp_310012050001 
	@i_batch INT,
	@i_row INT,
	@i_dmlkey BIGINT,
	@i_titlekeyset VARCHAR(500),
	@i_contactkeyset VARCHAR(500),
	@i_templatekey INT,
	@i_elementseq INT,
	@i_level INT,
	@i_userid VARCHAR(50),
	@i_newtitleind INT,
	@i_newcontactind INT,
	@o_writehistoryind INT OUTPUT
AS

BEGIN
	DECLARE 
		@DEBUG AS INT,
		@v_elementkey AS INT,
		@v_elementval_FORMAT AS VARCHAR(max),
		@v_elementval_MEDIA AS VARCHAR(max),
		@v_bookkey AS BIGINT,
		@v_DataCodeMedia_NEW INT,
		@v_DataSubCodeFormat_NEW INT,
		@v_DataCodeMedia_OLD INT,
		@v_DataSubCodeFormat_OLD INT,
		@v_errcode AS INT=1,
		@v_errmsg AS VARCHAR(4000)='No Change in Media & Format',
		@c_FORMATKEY INT=110012050,
		@c_MEDIAKEY INT=110012051,
		@c_GENTABLEID INT=312
				
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT 'imp_310012050001'
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
	IF @DEBUG <> 0 PRINT  '@v_bookkey  =  ' + coalesce(cast(@v_bookkey as varchar(max)),'*NULL*') 
	
	SELECT @v_elementval_FORMAT = LTRIM(RTRIM(originalvalue))
	FROM imp_batch_detail b
	WHERE b.batchkey = @i_batch
		AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND b.elementkey = @c_FORMATKEY

	SELECT @v_elementval_MEDIA = LTRIM(RTRIM(originalvalue))
	FROM imp_batch_detail b
	WHERE b.batchkey = @i_batch
		AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND b.elementkey = @c_MEDIAKEY

	IF @DEBUG <> 0 PRINT  '@c_FORMATKEY  =  ' + coalesce(cast(@c_FORMATKEY as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_elementval_FORMAT  =  ' + coalesce(cast(@v_elementval_FORMAT as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@c_MEDIAKEY  =  ' + coalesce(cast(@c_MEDIAKEY as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_elementval_MEDIA  =  ' + coalesce(cast(@v_elementval_MEDIA as varchar(max)),'*NULL*') 

	IF NOT (@v_elementval_FORMAT IS NULL OR @v_elementval_MEDIA IS NULL)
	BEGIN
		BEGIN TRY			
			--MAIN CODE BLOCK
			-- ... make sure the Format is valid for this Media
			EXECUTE find_gentables_mixed @v_elementval_MEDIA, @c_GENTABLEID,@v_DataCodeMedia_NEW OUTPUT,null,null
			IF @v_DataCodeMedia_NEW IS NULL 
			BEGIN
				SET @v_errmsg = CAST(@v_elementval_MEDIA  as varchar(max))  
					+ ' is not a valied Media Type (tableID=' 
					+ CAST (@c_GENTABLEID as varchar(max)) + ')'
				SET @v_errcode = 3
				GOTO ErrTrap
			END

			EXECUTE find_subgentables_mixed  @v_elementval_FORMAT, @c_GENTABLEID,@v_DataCodeMedia_NEW,@v_DataSubCodeFormat_NEW OUTPUT,null,null
			IF @v_DataSubCodeFormat_NEW IS NULL 
			BEGIN
				SET @v_errmsg = CAST(@v_elementval_FORMAT  as varchar(max)) 
					+ ' is not a valied Format Type for Media Type: ' 
					+ CAST (@c_GENTABLEID as varchar(max)) 
					+ '  (tableID=' + CAST (@c_GENTABLEID as varchar(max)) + ')'
				SET @v_errcode = 3
				GOTO ErrTrap
			END
			
			-- ... get the old codes for this record
			SELECT @v_DataCodeMedia_OLD = mediatypecode, 
				@v_DataSubCodeFormat_OLD = mediatypesubcode
			FROM bookdetail
			WHERE bookkey=@v_bookkey
			
			IF @DEBUG <> 0 PRINT  '@v_DataCodeMedia_OLD  =  ' + coalesce(cast(@v_DataCodeMedia_OLD as varchar(max)),'*NULL*') 
			IF @DEBUG <> 0 PRINT  '@v_DataSubCodeFormat_OLD  =  ' + coalesce(cast(@v_DataSubCodeFormat_OLD as varchar(max)),'*NULL*') 
			IF @DEBUG <> 0 PRINT  '@v_DataCodeMedia_NEW  =  ' + coalesce(cast(@v_DataCodeMedia_NEW as varchar(max)),'*NULL*') 
			IF @DEBUG <> 0 PRINT  '@v_DataSubCodeFormat_NEW  =  ' + coalesce(cast(@v_DataSubCodeFormat_NEW as varchar(max)),'*NULL*') 
			
			IF COALESCE(@v_DataCodeMedia_OLD,-1)<>@v_DataCodeMedia_NEW
			BEGIN
				UPDATE bookdetail
				SET mediatypecode = @v_DataCodeMedia_NEW,
					mediatypesubcode=@v_DataSubCodeFormat_NEW,
					lastuserid = @i_userid,
					lastmaintdate = GETDATE()
				WHERE bookkey = @v_bookkey
				SET @o_writehistoryind = 1
				SET @v_errmsg = 'Media & Format updated'
			END
			IF COALESCE(@v_DataCodeMedia_OLD,-1)=@v_DataCodeMedia_NEW AND COALESCE(@v_DataSubCodeFormat_OLD,-1)<>@v_DataSubCodeFormat_NEW
			BEGIN
				UPDATE bookdetail
				SET mediatypesubcode=@v_DataSubCodeFormat_NEW,
					lastuserid = @i_userid,
					lastmaintdate = GETDATE()
				WHERE bookkey = @v_bookkey
				SET @v_errmsg = 'Format updated'
				SET @o_writehistoryind = 1
			END
			
		END TRY
		BEGIN CATCH
			SET @v_errcode = @@ERROR
			SET @v_errmsg = ERROR_MESSAGE()
			SET @i_level = 3
			GOTO ErrTrap
		END CATCH
	END ELSE BEGIN
		SET @v_errmsg='Error: The one or both of the values for Format/Media Elements (' 
			+ coalesce(cast(@v_elementval_FORMAT as varchar(max)),'*NULL*')  
			+ '/' + coalesce(cast(@v_elementval_MEDIA as varchar(max)),'*NULL*')  
			+ ') are null.  The rule was skipped'
		SET @v_errcode = 3
		GOTO ErrTrap
	END

ErrTrap:	
	EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq, @i_dmlkey , @v_errmsg, @i_level, 3
	IF @DEBUG <> 0 PRINT  @v_errmsg 	
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_310012050001]
	TO PUBLIC
GO


