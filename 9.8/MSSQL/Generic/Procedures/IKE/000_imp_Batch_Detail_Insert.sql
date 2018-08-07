/******************************************************************************
**  Name: imp_load_xml_explicit
**  Desc: IKE Inserts Import data into Batch Detail (gets called from imp_load_xml_explicit, imp_load_xml, imp_table_to_batch
**  Auth: Marcus Keyser     
**  Date: Jan 17, 2013
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
		WHERE id = object_id(N'[dbo].[imp_Batch_Detail_Insert]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_Batch_Detail_Insert]
GO

CREATE PROCEDURE dbo.imp_Batch_Detail_Insert (
 	@i_batchkey INT
	,@v_row_id INT
	,@v_elementkey INT
	,@v_elementseq INT
	,@v_element_value varchar(max)
	,@i_userid VARCHAR(50)
	,@v_iLoopCount INT
	,@v_mapkey INT
	,@v_lobind INT
	,@v_errcode  AS INT OUTPUT
	,@v_errmsg AS VARCHAR(MAX) OUTPUT)	
AS

BEGIN
	DECLARE 
	@DEBUG AS INT

	,@v_lobkey AS INT
	,@v_element_mapped_value AS VARCHAR(MAX)
	,@v_element_mapped_count AS INT

	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT 'dbo.imp_Batch_Detail_Insert'
	IF @DEBUG <> 0 PRINT  '@i_batchkey  =  ' + coalesce(cast(@i_batchkey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_row_id  =  ' + coalesce(cast(@v_row_id as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_elementkey  =  ' + coalesce(cast(@v_elementkey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_elementseq  =  ' + coalesce(cast(@v_elementseq as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_element_value  =  ' + coalesce(cast(@v_element_value as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_userid  =  ' + coalesce(cast(@i_userid as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_iLoopCount  =  ' + coalesce(cast(@v_iLoopCount as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_mapkey  =  ' + coalesce(cast(@v_mapkey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_lobind  =  ' + coalesce(cast(@v_lobind as varchar(max)),'*NULL*') 

	SET @v_errmsg='Element Value inserted into batch_detail'
	SET @v_errcode = 0
	
	--mk02192014> Changed this to exlude empty strings
	--IF @v_element_value IS NOT NULL
	IF LEN(COALESCE(@v_element_value,''))>0
	BEGIN
		BEGIN TRY
			IF @v_lobind = 1
			BEGIN
				UPDATE keys
				SET generickey = generickey + 1

				SELECT @v_lobkey = generickey
				FROM keys

				INSERT INTO imp_batch_lobs (batchkey, lobkey, textvalue)
				VALUES (@i_batchkey, @v_lobkey, @v_element_value)

				INSERT INTO imp_batch_detail (batchkey, row_id, elementkey, elementseq, lobkey, lastuserid, lastmaintdate)
				VALUES (@i_batchkey, @v_row_id, @v_elementkey, @v_elementseq, @v_lobkey, @i_userid, getdate())
			END ELSE BEGIN
				IF @v_mapkey IS NOT NULL
				BEGIN
					SET @v_element_mapped_value = NULL
					
					SELECT @v_element_mapped_count = COUNT(*)
					FROM imp_mapping
					WHERE mapkey = @v_mapkey AND from_value = @v_element_value					
					
					IF coalesce(@v_element_mapped_count,0)>0
					BEGIN
						SELECT @v_element_mapped_value = to_value
						FROM imp_mapping
						WHERE mapkey = @v_mapkey AND from_value = @v_element_value

						SET @v_element_value = @v_element_mapped_value
					END 
				END
				
				IF @DEBUG <> 0 PRINT  'JUST BEFORE INSERT ... @v_element_value  =  ' + coalesce(cast(@v_element_value as varchar(max)),'*NULL*') 
				
				IF @v_element_value IS NOT NULL
				BEGIN
					INSERT INTO imp_batch_detail (batchkey, row_id, elementkey, elementseq, originalvalue, lastuserid, lastmaintdate, elementseqOrdinal)
					VALUES (@i_batchkey, @v_row_id, @v_elementkey, @v_elementseq, substring(@v_element_value, 1, 4000), @i_userid, getdate(), @v_iLoopCount)
				END
			END		
		END TRY
		BEGIN CATCH
			--something really bad happened ?!?
			SET @v_errcode = @@ERROR
			SET @v_errmsg = ERROR_MESSAGE()
			IF @DEBUG <> 0 PRINT @v_errcode
			IF @DEBUG <> 0 PRINT @v_errmsg
		END CATCH
		
	END ELSE BEGIN
		SET @v_errmsg='Element Value is null, insert into batch_detail skipped'
		SET @v_errcode = -1
	END

END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_Batch_Detail_Insert]
	TO PUBLIC
GO


