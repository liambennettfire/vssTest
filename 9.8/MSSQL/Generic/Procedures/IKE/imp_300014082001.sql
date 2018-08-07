/******************************************************************************
**  Name: 
**  Desc: IKE This sproc inserts verification steps into bookverification
			... This is only a row insert element ... it is not intended to be bound to a real data node
			... The addlqualifier can be used to identify which verificationtypecode are to be inserted
			... ... example: @v_addlqualifier = '1,2,3,4,5,6,7,8'
			... ... the delimter has to be a COMMA
			... ... the values have to be an INT
			... ... If no addlqualifier then it is assumed that we are inserting steps 1,2,3,4
			... the default value contains the titleverifystatuscode
			... ... the same titleverifystatuscode is used for verificationtypecode in addlqualifier
**  Auth:  Marcus Keyser     
**  Date: Aug 1, 2013
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
		WHERE id = object_id(N'[dbo].[imp_300014082001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300014082001]
GO

CREATE PROCEDURE dbo.imp_300014082001 
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
		@v_elementval AS VARCHAR(max),
		@v_addlqualifier AS INT,
		@v_bookkey AS BIGINT,
		@v_errcode AS INT,
		@v_errmsg AS VARCHAR(4000)
				
	SET @DEBUG = 1
	IF @DEBUG <> 0 PRINT 'imp_300014082001'
		
	SELECT @v_elementval = LTRIM(RTRIM(originalvalue)),
		@v_elementkey = b.elementkey,
		@v_addlqualifier = addlqualifier
	FROM imp_batch_detail b
		INNER JOIN imp_DML_elements d ON d.elementkey = b.elementkey
		INNER JOIN imp_template_detail td ON d.elementkey = td.elementkey
	WHERE b.batchkey = @i_batch
		AND b.row_id = @i_row
		AND b.elementseq = @i_elementseq
		AND d.dmlkey = 300014082001

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
	IF @DEBUG <> 0 PRINT  '@v_elementval  =  ' + coalesce(cast(@v_elementval as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_elementkey  =  ' + coalesce(cast(@v_elementkey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_addlqualifier  =  ' + coalesce(cast(@v_addlqualifier as varchar(max)),'*NULL*') 
	
	IF @v_elementval IS NOT NULL
	BEGIN
		BEGIN TRY	
			--MAIN CODE BLOCK
			DECLARE @verificationtypecodes TABLE (INR INT, verificationtypecode INT)
			IF LEN(COALESCE(@v_addlqualifier,''))>0 
			BEGIN
				INSERT INTO @verificationtypecodes
				SELECT * FROM dbo.udf_SplitString(@v_addlqualifier,',')		
			END ELSE BEGIN
				INSERT INTO @verificationtypecodes SELECT 1,1
				INSERT INTO @verificationtypecodes SELECT 2,2
				INSERT INTO @verificationtypecodes SELECT 3,3
				INSERT INTO @verificationtypecodes SELECT 4,4
			END
			
			INSERT INTO bookverification
			SELECT @v_bookkey, V.verificationtypecode, @v_elementval, @i_userid,getdate()
			FROM @verificationtypecodes V
				LEFT JOIN bookverification BV on V.verificationtypecode=BV.verificationtypecode AND BV.bookkey=@v_bookkey
			WHERE BV.verificationtypecode IS NULL

		END TRY
		BEGIN CATCH
			SET @v_errcode = @@ERROR
			SET @v_errmsg = ERROR_MESSAGE()
			SET @i_level = 3
			IF @DEBUG <> 0 PRINT @v_errcode
			IF @DEBUG <> 0 PRINT @v_errmsg

			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq, @i_dmlkey , @v_errmsg, @i_level, 2
			RETURN		
		END CATCH
	END ELSE BEGIN
		SET @v_errmsg='Error: The value of Element ' + CAST(@v_elementkey as varchar(max)) + ' is null.  The rule was skipped'
	END
	
	EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq, @i_dmlkey , @v_errmsg, @i_level, 3
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300014082001]
	TO PUBLIC
GO


