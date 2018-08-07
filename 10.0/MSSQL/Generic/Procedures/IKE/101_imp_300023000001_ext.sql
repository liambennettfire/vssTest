/******************************************************************************
**  Name: imp_300023000001_ext
**  Desc: IKE bookcomments upidate
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
--100023000, 'ProcessComment' ... 'ProcessTOC, HTML2XML, 3_52, 3_53'
--100023001, 'ProcessComment' ... 'BuildDABCopyright, 3_54'

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_300023000001_ext]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300023000001_ext]
GO

CREATE PROCEDURE dbo.imp_300023000001_ext
	@v_elementkey INT
	,@i_batch INT
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
	,@v_elementval as varchar(max)
	,@v_bookkey AS BIGINT
	,@v_errseverity AS INT
	,@v_errmsg AS VARCHAR(4000)
	
	--AdditionalQualifier Parameters
	,@v_AdditionalQualifier VARCHAR(500)
	,@v_ActionType VARCHAR(500)
	,@v_Direction VARCHAR(500)
	,@v_HTMLCodes VARCHAR(500)
	,@v_XMLCodes VARCHAR(500)
	,@v_HTMLDataCode INT
	,@v_XMLDataCode INT	
	,@v_HTMLDataSubCode INT
	,@v_XMLDataSubCode INT
	
	,@v_OtherDataCodes VARCHAR(500)	
	,@v_DataCode INT
	,@v_DataSubCode INT
	
	,@BuildDABCopyright as varchar(max)
	,@DelimPos INT	
	
	SET @v_errmsg='ProcessComment() Completed successfully'
	SET @v_errseverity=1

	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT ''
	IF @DEBUG <> 0 PRINT 'dbo.imp_300023000001_ext'
	
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
	IF @DEBUG <> 0 PRINT  '@v_elementkey = ' + coalesce(cast(@v_elementkey as varchar(max)),'*NULL*') 
	
	SELECT	@v_AdditionalQualifier= replace(td.addlqualifier,' ','')
	FROM	imp_template_detail td
	WHERE	elementkey = @v_elementkey
			AND templatekey = @i_templatekey
					
	SET @v_errseverity=1
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)

	IF @DEBUG <> 0 PRINT  '@v_bookkey = ' + cast(@v_bookkey as varchar(max))
	IF @DEBUG <> 0 PRINT  '@v_AdditionalQualifier = ' + cast(@v_AdditionalQualifier as varchar(max))
	
	IF @v_AdditionalQualifier IS NOT NULL
	BEGIN
		SELECT @v_ActionType = part FROM dbo.udf_SplitString(@v_AdditionalQualifier, ',') WHERE id = 1
		IF @DEBUG <> 0 PRINT  '@v_ActionType = ' + cast(@v_ActionType as varchar(max))
		IF @v_ActionType IS NOT NULL
		BEGIN
			IF @v_ActionType='ProcessTOC'
			BEGIN
				DECLARE @DoUpdate BIT
				DECLARE @HTML VARCHAR(MAX)
				DECLARE @HTML_LITE VARCHAR(MAX)
				DECLARE @HTML_TEXT VARCHAR(MAX)
				DECLARE @XML VARCHAR(MAX)
				DECLARE @XML_LITE VARCHAR(MAX)
				DECLARE @XML_TEXT VARCHAR(MAX)
				
				SET @DoUpdate=0
								
				SELECT @v_Direction = part FROM dbo.udf_SplitString(@v_AdditionalQualifier, ',') WHERE id = 2
				SELECT @v_HTMLCodes = part FROM dbo.udf_SplitString(@v_AdditionalQualifier, ',') WHERE id = 3
				SELECT @v_XMLCodes = part FROM dbo.udf_SplitString(@v_AdditionalQualifier, ',') WHERE id = 4

				SET @DelimPos=CHARINDEX('_',@v_HTMLCodes)-1
				IF @DelimPos>0 
				BEGIN
					SET @v_HTMLDataCode = CAST(LEFT(@v_HTMLCodes,@DelimPos) as INT)
					SET @v_HTMLDataSubCode = CAST(REPLACE(@v_HTMLCodes, CAST(@v_HTMLDataCode as varchar(10))+'_','')  as INT)
				END
				
				SET @DelimPos=CHARINDEX('_',@v_XMLCodes)-1
				IF @DelimPos>0 
				BEGIN
					SET @v_XMLDataCode = CAST(LEFT(@v_XMLCodes,@DelimPos) as INT)
					SET @v_XMLDataSubCode = CAST(REPLACE(@v_XMLCodes, CAST(@v_XMLDataCode as varchar(10))+'_','')  as INT)
				END
				
				IF @DEBUG <> 0 PRINT  '@v_Direction = ' + cast(@v_Direction as varchar(max))
				IF @DEBUG <> 0 PRINT  '@v_HTMLCodes = ' + cast(@v_HTMLCodes as varchar(max))
				IF @DEBUG <> 0 PRINT  '@v_XMLCodes = ' + cast(@v_XMLCodes as varchar(max))
				IF @DEBUG <> 0 PRINT  '@v_HTMLDataCode = ' + cast(@v_HTMLDataCode as varchar(max))
				IF @DEBUG <> 0 PRINT  '@v_HTMLDataSubCode = ' + cast(@v_HTMLDataSubCode as varchar(max))
				IF @DEBUG <> 0 PRINT  '@v_XMLDataCode = ' + cast(@v_XMLDataCode as varchar(max))
				IF @DEBUG <> 0 PRINT  '@v_XMLDataSubCode = ' + cast(@v_XMLDataSubCode as varchar(max))
				
				--if exists(select elementkey from imp_batch_detail where batchkey=@i_batch and row_id=@i_row and elementkey=100022911 and originalvalue='3,52' and lobkey is not null)
				IF EXISTS (
						SELECT elementkey
						FROM imp_batch_detail
						WHERE batchkey = @i_batch
							AND elementseq = @i_elementseq
							AND row_id = @i_row
							AND elementkey = 100022911
							AND originalvalue = '3,52'
						)
				BEGIN
					IF @v_Direction = 'XML2HTML'
					BEGIN
						--The basic assumption is that a bookcomment in XML form was just inserted into bookcomments for the bookkey = @v_bookkey and codes @v_HTMLCodes
						-- ... This comment will need to be moved to @v_XMLCodes
						-- ... then is needs to be converted to HTML which is then updated back into @v_HTMLCodes
						-- ... then need to convert the HTML into Lite and text which will get updated into @v_HTMLCodes
						-- ... lastly the commenttext for @v_XMLCodes = commenttext for @v_HTMLCodes ... and ...
						-- ... ... commentlite for @v_XMLCodes = commenthtml for @v_XMLCodes

						IF @DEBUG <> 0 PRINT  '... Processing XML2HTML'
						SELECT	@XML = commenthtml 
						FROM	bookcomments 
						WHERE	bookkey=@v_bookkey 
								AND commenttypecode=@v_HTMLDataCode 
								AND commenttypesubcode=@v_HTMLDataSubCode

						SET @HTML=dbo.udf_ConvertXMLtoc2HTMLtoc(@XML)
						SET @HTML_LITE=@HTML
						SET @HTML_TEXT=dbo.udf_StripSelectedHTMLTags(@HTML,0)
						SET @XML_LITE=@XML
						SET @XML_TEXT=@HTML_TEXT
						SET @DoUpdate=1
					
					
					END ELSE IF @v_Direction = 'HTML2XML'
					BEGIN
						--The basic assumption is that a bookcomment in HTML form was just inserted into bookcomments for the bookkey = @v_bookkey and codes @v_HTMLCodes
						-- ... then it needs to be converted to XML which is then updated back into @v_XMLCodes
						-- ... then need to convert the HTML into Lite and text which will get updated into @v_HTMLCodes
						-- ... lastly the commenttext for @v_XMLCodes = commenttext for @v_HTMLCodes ... and ...
						-- ... ... commentlite for @v_XMLCodes = commenthtml for @v_XMLCodes
						
						IF @DEBUG <> 0 PRINT  '... Processing HTML2XML'
						
						SELECT	@HTML = commenthtml 
						FROM	bookcomments 
						WHERE	bookkey=@v_bookkey 
								AND commenttypecode=@v_HTMLDataCode 
								AND commenttypesubcode=@v_HTMLDataSubCode
						
						
						begin TRY
							SET @XML=dbo.udf_ConvertHTMLtoc2XMLtoc(@HTML)
						end TRY
						begin CATCH
						    --error in XML
						    select @XML=NULL
						end CATCH
						IF @XML IS NOT NULL
						BEGIN
							--Add the dots to the original HTML
							SET @HTML=dbo.udf_ConvertXMLtoc2HTMLtoc(@XML)
							
							SET @HTML_LITE=@HTML
							SET @HTML_TEXT=dbo.udf_StripSelectedHTMLTags(@HTML,0)
							SET @XML_LITE=@XML
							SET @XML_TEXT=@HTML_TEXT
							SET @DoUpdate=1
						
						END ELSE BEGIN
						
							SET @v_errmsg='The HTML TOC for this record could not be converted to XML'
							SET @v_errseverity=2
							SET @DoUpdate=0
							GOTO ErrTrap							
						END 
											
					END ELSE BEGIN
						SET @v_errmsg='Unkown Direction: ' + cast(@v_ActionType as varchar(max))
						SET @v_errseverity=2
						GOTO ErrTrap
					END
					BEGIN TRY
						IF @DoUpdate=1 
						BEGIN
							IF @DEBUG <> 0 PRINT  'INSERT XML into new comment type'
							DELETE FROM bookcomments WHERE bookkey=@v_bookkey and commenttypecode=@v_XMLDataCode and commenttypesubcode=@v_XMLDataSubCode
							INSERT INTO bookcomments (
								bookkey
								,printingkey
								,commenttypecode
								,commenttypesubcode
								,commentstring
								,commenttext
								,lastuserid
								,lastmaintdate
								,releasetoeloquenceind
								,commenthtml
								,commenthtmllite
								,invalidhtmlind)
							VALUES(
								@v_bookkey 
								,1
								,@v_XMLDataCode
								,@v_XMLDataSubCode
								,NULL
								,@XML_TEXT
								,@i_userid
								,getdate()
								,1
								,@XML
								,@XML_LITE
								,NULL)

							IF @DEBUG <> 0 PRINT  'UPDATE HTML into existing comment type (I''m going to delete/insert)'
							DELETE FROM bookcomments WHERE bookkey=@v_bookkey and commenttypecode=@v_HTMLDataCode and commenttypesubcode=@v_HTMLDataSubCode
							INSERT INTO bookcomments (
								bookkey
								,printingkey
								,commenttypecode
								,commenttypesubcode
								,commentstring
								,commenttext
								,lastuserid
								,lastmaintdate
								,releasetoeloquenceind
								,commenthtml
								,commenthtmllite
								,invalidhtmlind)
							VALUES(
								@v_bookkey 
								,1
								,@v_HTMLDataCode
								,@v_HTMLDataSubCode
								,NULL
								,@HTML_TEXT
								,@i_userid
								,getdate()
								,1
								,@HTML
								,@HTML_LITE
								,NULL)
						END
					END TRY
					BEGIN CATCH
						IF @DEBUG <> 0 PRINT 'something really bad happened ?!?'
						SET @v_errmsg = ERROR_MESSAGE()
						SET @v_errseverity = 3
						IF @DEBUG <> 0 PRINT @v_errseverity
						IF @DEBUG <> 0 PRINT @v_errmsg
					END CATCH				
				END ELSE BEGIN
					SET @v_errseverity=1
					SET @v_errmsg='... There is no TOC to process in row/sequence: ' 
									+ coalesce(cast(@i_row as varchar(max)),'*NULL*') + '/' 
									+ coalesce(cast(@i_elementseq as varchar(max)),'*NULL*') 
					
					IF @DEBUG <> 0 PRINT  @v_errmsg
				END
			END 
			ELSE IF @v_ActionType='BuildDABCopyright'
			BEGIN
				IF @DEBUG <> 0 PRINT 'This function creates a unique and proprietary Copyright Comment for DAB'

				SELECT @v_OtherDataCodes = part FROM dbo.udf_SplitString(@v_AdditionalQualifier, ',') WHERE id = 2

				SET @DelimPos=CHARINDEX('_',@v_OtherDataCodes)-1
				IF @DelimPos>0 
				BEGIN
					SET @v_DataCode = CAST(LEFT(@v_OtherDataCodes,@DelimPos) as INT)
					SET @v_DataSubCode = CAST(REPLACE(@v_OtherDataCodes, CAST(@v_DataCode as varchar(10))+'_','')  as INT)
				
					IF @DEBUG <> 0 PRINT  '@v_OtherDataCodes = ' + cast(@v_OtherDataCodes as varchar(max))
					IF @DEBUG <> 0 PRINT  '@v_DataCode = ' + cast(@v_DataCode as varchar(max))
					IF @DEBUG <> 0 PRINT  '@v_DataSubCode = ' + cast(@v_DataSubCode as varchar(max))
					
					SET @BuildDABCopyright = dbo.udf_BuildDABCopyright(@v_bookkey)
					
					IF @DEBUG <> 0 PRINT  '@BuildDABCopyright = ' + coalesce(cast(@BuildDABCopyright as varchar(max)),'*NULL*')
					IF @BuildDABCopyright is not null 
					BEGIN
						IF @DEBUG <> 0 PRINT  'UPDATE DABCopyright (I''m going to delete/insert)'
						DELETE FROM bookcomments WHERE bookkey=@v_bookkey and commenttypecode=@v_DataCode and commenttypesubcode=@v_DataSubCode
						INSERT INTO bookcomments (
							bookkey
							,printingkey
							,commenttypecode
							,commenttypesubcode
							,commentstring
							,commenttext
							,lastuserid
							,lastmaintdate
							,releasetoeloquenceind
							,commenthtml
							,commenthtmllite
							,invalidhtmlind)
						VALUES(
							@v_bookkey 
							,1
							,@v_DataCode
							,@v_DataSubCode
							,NULL
							,dbo.udf_StripSelectedHTMLTags(@BuildDABCopyright,0)
							,@i_userid
							,getdate()
							,1
							,@BuildDABCopyright
							,@BuildDABCopyright
							,NULL)
					END ELSE BEGIN
						SET @v_errmsg='The function udf_BuildDABCopyright() failed to build a copyright string'
						SET @v_errseverity=2
					END
				END ELSE BEGIN
					SET @v_errmsg='DataCodes are not defined in AdditionalQualifier (##_##)'
					SET @v_errseverity=2
				END
			END
			ELSE IF @v_ActionType='[NEW ACTION TYPE HERE]'
			BEGIN
				--code for new action
				SET @v_ActionType=@v_ActionType
			END ELSE BEGIN
				SET @v_errmsg='Unkown ActionType: ' + cast(@v_ActionType as varchar(max))
				SET @v_errseverity=2
			END
		END ELSE BEGIN
			SET @v_errmsg='ActionType is not defined in AdditionalQualifier'
			SET @v_errseverity=2
		END
	END ELSE BEGIN
		SET @v_errmsg='AdditionalQualifier is not defined'
		SET @v_errseverity=2
	END

ErrTrap:	
	IF @DEBUG <> 0 PRINT @v_errmsg
	IF @DEBUG <> 0 PRINT @v_errseverity
	EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errseverity, 3
END

GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300023000001_ext]
	TO PUBLIC
GO