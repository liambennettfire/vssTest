/******************************************************************************
**  Name: imp_300022000001
**  Desc: IKE generic update for bookcomments or qsicomments
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
		WHERE id = object_id(N'[dbo].[imp_300022000001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300022000001]
GO

CREATE PROCEDURE [dbo].[imp_300022000001] 
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
/* update book comment */
BEGIN
	DECLARE 
		@v_source_prefix VARCHAR(20)
		,@v_elementkey INT
		,@v_addlqualifier VARCHAR(500)
		,@v_lobkey INT
		,@v_commenttypecode INT
		,@v_commenttypesubcode INT
		,@v_bookkey INT
		,@v_contactkey INT
		,@v_printingkey INT
		,@v_datacode INT
		,@v_datasubcode INT
		,@v_row_count INT
		,@v_errmsg VARCHAR(500)
		,@v_errcode INT
		,@v_errmsg2 VARCHAR(500)
		,@v_errcode2 INT
		,@v_invalidhtmlind INT
		,@v_html_part VARCHAR(8000)
		,@v_text_releasetoelo_ind INT
		,@v_textvalue VARCHAR(MAX)
		,@b_ProcessAsAuthorComment BIT
		,@Debug INT

	BEGIN
		SET @Debug = 0
		SET @v_errcode = 1
		SET @o_writehistoryind = 0 -- no history, causes a tittlehistory error
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @v_contactkey=dbo.resolve_keyset(@i_contactkeyset, 1)
		SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset, 2)

		--get some default values
		SELECT @v_text_releasetoelo_ind = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batch
			AND row_id = @i_row
			AND elementkey = 100022607
			AND elementseq = @i_elementseq

		SELECT @v_elementkey = elementkey
		FROM imp_dml_elements
		WHERE dmlkey = @i_dmlkey

		SELECT @v_addlqualifier = addlqualifier
		FROM imp_template_detail where elementkey=@v_elementkey
		
		IF @v_addlqualifier IS NOT NULL 
			BEGIN
				SET @v_commenttypecode = dbo.resolve_keyset(@v_addlqualifier, 1)
				SET @v_commenttypesubcode = dbo.resolve_keyset(@v_addlqualifier, 2)
			END ELSE BEGIN
				SELECT @v_commenttypecode = datacode
					,@v_commenttypesubcode = datasubcode
				FROM imp_element_defs
				WHERE elementkey = @v_elementkey
			END

		SELECT @v_lobkey = lobkey
		FROM imp_batch_detail
		WHERE batchkey = @i_batch
			AND row_id = @i_row
			AND elementseq = @i_elementseq
			AND elementkey = @v_elementkey

		--Check the XMLQualifier column
		-- ... insert into template as:
		-- ... set @v_where='WHERE ElementKey=100022212 and templatekey = ' + CAST(@v_templatekey as varchar(max))
		-- ... exec sp_XMLNodeValue_SET 'imp_template_detail','XMLQualifier',@v_where, 'AuthorComment', 'TRUE' 
		
		DECLARE @VAL VARCHAR(MAX)
		DECLARE @v_where varchar(max)

		SET @v_where='WHERE ElementKey= ' + CAST(@v_elementkey as varchar(max)) + ' and templatekey = ' + CAST(@i_templatekey as varchar(max))
		EXEC sp_XMLNodeValue_GET 'imp_template_detail','XMLQualifier',@v_where, 'AuthorComment', @VAL OUTPUT
		
		SET @b_ProcessAsAuthorComment=0
		IF @VAL='TRUE' SET @b_ProcessAsAuthorComment=1
		
		IF @b_ProcessAsAuthorComment=0 SET @v_errmsg = 'bookcomments: updated' ELSE SET @v_errmsg = 'qsicomments (AuthorComments): updated'

		IF @Debug <> 0 PRINT ''
		IF @Debug <> 0 PRINT 'PROCEDURE [dbo].[imp_300022000001] '
		IF @DEBUG <> 0 PRINT '@i_batch  =  ' + coalesce(cast(@i_batch as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT '@i_row  =  ' + coalesce(cast(@i_row as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT '@i_elementseq  =  ' + coalesce(cast(@i_elementseq as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT '@i_templatekey  =  ' + coalesce(cast(@i_templatekey as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT '@i_dmlkey  =  ' + coalesce(cast(@i_dmlkey as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT '@i_level  =  ' + coalesce(cast(@i_level as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT '@i_userid  =  ' + coalesce(cast(@i_userid as varchar(max)),'*NULL*') 		
		IF @DEBUG <> 0 PRINT '@v_bookkey  =  ' + coalesce(cast(@v_bookkey as varchar(max)),'*NULL*') 		
		IF @DEBUG <> 0 PRINT '@v_printingkey  =  ' + coalesce(cast(@v_printingkey as varchar(max)),'*NULL*') 		
		IF @DEBUG <> 0 PRINT '@i_contactkeyset  =  ' + coalesce(cast(@i_contactkeyset as varchar(max)),'*NULL*') 		
		IF @DEBUG <> 0 PRINT '@i_newcontactind  =  ' + coalesce(cast(@i_newcontactind as varchar(max)),'*NULL*') 				
		IF @DEBUG <> 0 PRINT '@v_contactkey  =  ' + coalesce(cast(@v_contactkey as varchar(max)),'*NULL*') 				
		IF @DEBUG <> 0 PRINT '@b_ProcessAsAuthorComment  =  ' + coalesce(cast(@b_ProcessAsAuthorComment as varchar(max)),'*NULL*')
		IF @Debug <> 0 PRINT '@v_elementkey = ' + coalesce(cast(@v_elementkey AS VARCHAR(max)), '*NULL*')
		IF @Debug <> 0 PRINT '@v_commenttypecode = ' + coalesce(cast(@v_commenttypecode AS VARCHAR(max)), '*NULL*')
		IF @Debug <> 0 PRINT '@v_commenttypesubcode = ' + coalesce(cast(@v_commenttypesubcode AS VARCHAR(max)), '*NULL*')
		IF @Debug <> 0 PRINT '@v_lobkey = ' + coalesce(cast(@v_lobkey AS VARCHAR(max)), '*NULL*')
		IF @Debug <> 0 PRINT '@v_text_releasetoelo_ind = ' + coalesce(cast(@v_text_releasetoelo_ind AS VARCHAR(max)), '*NULL*')
		
		IF @v_lobkey is not null
		BEGIN
			SELECT @v_textvalue = textvalue
				,@v_source_prefix = substring(textvalue, 1, 4)
			FROM imp_batch_lobs
			WHERE lobkey = @v_lobkey		
						
			IF dbo.udf_IsHTML(@v_textvalue)=0 SET @v_invalidhtmlind=1 ELSE SET @v_invalidhtmlind=0
			IF @Debug <> 0 PRINT '@v_invalidhtmlind (1) = ' + coalesce(cast(@v_invalidhtmlind AS VARCHAR(max)), '*NULL*')
			
			IF @v_invalidhtmlind=1 
			BEGIN
				SET @v_textvalue=REPLACE(@v_textvalue, CHAR(13)+CHAR(10), '<BR />')	
			END ELSE BEGIN
				IF dbo.udf_IsValidHTML (@v_textvalue)=0 SET @v_invalidhtmlind=1 ELSE SET @v_invalidhtmlind=0
				IF @Debug <> 0 PRINT '@v_invalidhtmlind (2) = ' + coalesce(cast(@v_invalidhtmlind AS VARCHAR(max)), '*NULL*')
			END
			
			IF @v_source_prefix <> '<div' SET @v_textvalue='<div>'+@v_textvalue+'</div>'
			
		END ELSE BEGIN
			SELECT @v_textvalue = originalvalue
				,@v_source_prefix = substring(originalvalue, 1, 4)
			FROM imp_batch_detail
			WHERE batchkey = @i_batch
				AND row_id = @i_row
				AND elementseq = @i_elementseq
				AND elementkey = @v_elementkey
		END
		
		IF @b_ProcessAsAuthorComment=1
		BEGIN	
			SELECT @v_row_count = count(*)
			FROM qsicomments
			WHERE commentkey = @v_contactkey
				AND commenttypecode = @v_commenttypecode
				AND commenttypesubcode = @v_commenttypesubcode

			IF @Debug <> 0 PRINT 'SELECT @v_row_count = count(*)'
				+ ' FROM qsicomments WHERE commentkey = ' + coalesce(cast(@v_contactkey AS VARCHAR(max)), '*NULL*')
				+ ' AND commenttypecode = ' + coalesce(cast(@v_commenttypecode AS VARCHAR(max)), '*NULL*')
				+ ' AND commenttypesubcode = ' + coalesce(cast(@v_commenttypesubcode AS VARCHAR(max)), '*NULL*')
			
			IF @Debug <> 0 PRINT '@v_row_count = ' + coalesce(cast(@v_row_count AS VARCHAR(max)), '*NULL*')
			
			IF @v_row_count = 0
			BEGIN
				IF @Debug <> 0 PRINT 'START insert into qsicomments for @v_contactkey = ' + cast(@v_contactkey AS VARCHAR(max))

				INSERT INTO qsicomments (
					commentkey
					,commenttypecode
					,commenttypesubcode
					,commenthtml
					,commenttext
					,commenthtmllite
					,lastuserid
					,lastmaintdate
					,releasetoeloquenceind
					,invalidhtmlind
					)
				VALUES (
					@v_contactkey
					,@v_commenttypecode
					,@v_commenttypesubcode
					,@v_textvalue
					,dbo.udf_StripSelectedHTMLTags(@v_textvalue,0)
					,dbo.udf_StripSelectedHTMLTags(@v_textvalue,1)
					,@i_userid
					,getdate()
					,@v_text_releasetoelo_ind
					,@v_invalidhtmlind
					)
				IF @Debug <> 0 PRINT 'END insert into qsicomments for @v_contactkey = ' + cast(@v_contactkey AS VARCHAR(max))
			
			END ELSE BEGIN
				
				IF @Debug <> 0 PRINT 'START update qsicomments for @v_contactkey = ' + cast(@v_contactkey AS VARCHAR(max))
				
				UPDATE qsicomments
				SET lastuserid = @i_userid
					,lastmaintdate = getdate()
					,releasetoeloquenceind = @v_text_releasetoelo_ind
					,commenthtml=@v_textvalue
					,commenttext=dbo.udf_StripSelectedHTMLTags(@v_textvalue,0)
					,commenthtmllite=dbo.udf_StripSelectedHTMLTags(@v_textvalue,1)
					,invalidhtmlind=@v_invalidhtmlind
				WHERE commentkey = @v_contactkey
					AND commenttypecode = @v_commenttypecode
					AND commenttypesubcode = @v_commenttypesubcode

				IF @Debug <> 0 PRINT 'END update qsicomments for @v_contactkey = ' + cast(@v_contactkey AS VARCHAR(max))
			END

		END ELSE BEGIN
			SELECT @v_row_count = count(*)
			FROM bookcomments
			WHERE bookkey = @v_bookkey
				AND printingkey = @v_printingkey
				AND commenttypecode = @v_commenttypecode
				AND commenttypesubcode = @v_commenttypesubcode

			IF @Debug <> 0 PRINT 'SELECT @v_row_count = count(*)'
				+ ' FROM bookcomments WHERE bookkey = ' + coalesce(cast(@v_bookkey AS VARCHAR(max)), '*NULL*')
				+ ' AND printingkey = ' + coalesce(cast(@v_printingkey AS VARCHAR(max)), '*NULL*')
				+ ' AND commenttypecode = ' + coalesce(cast(@v_commenttypecode AS VARCHAR(max)), '*NULL*')
				+ ' AND commenttypesubcode = ' + coalesce(cast(@v_commenttypesubcode AS VARCHAR(max)), '*NULL*')
			
			IF @Debug <> 0 PRINT '@v_row_count = ' + coalesce(cast(@v_row_count AS VARCHAR(max)), '*NULL*')

			IF @v_row_count = 0
			BEGIN
			
				IF @Debug <> 0 PRINT 'START insert into bookcomments for @v_bookkey = ' + cast(@v_bookkey AS VARCHAR(max))

				begin try
				INSERT INTO bookcomments (
					bookkey
					,printingkey
					,commenttypecode
					,commenttypesubcode
					,commenthtml
					,commenttext
					,commenthtmllite
					,lastuserid
					,lastmaintdate
					,releasetoeloquenceind
					,invalidhtmlind
					)
				VALUES (
					@v_bookkey
					,@v_printingkey
					,@v_commenttypecode
					,@v_commenttypesubcode
					,@v_textvalue
					,dbo.udf_StripSelectedHTMLTags(@v_textvalue,0)
					,dbo.udf_StripSelectedHTMLTags(@v_textvalue,1)
					,@i_userid
					,getdate()
					,@v_text_releasetoelo_ind
					,@v_invalidhtmlind
					)
				end try
				begin catch
					EXECUTE imp_write_feedback @i_batch,@i_row,NULL,@i_elementseq,300022000001,'Error in HTML content',3,3
				end catch
				IF @Debug <> 0 PRINT 'END insert into bookcomments for @v_bookkey = ' + cast(@v_bookkey AS VARCHAR(max))
			
			END ELSE BEGIN
				
				IF @Debug <> 0 PRINT 'START update bookcomments for @v_bookkey = ' + cast(@v_bookkey AS VARCHAR(max))
				
				begin try
				UPDATE bookcomments
				SET lastuserid = @i_userid
					,lastmaintdate = getdate()
					,releasetoeloquenceind = @v_text_releasetoelo_ind
					,commenthtml=@v_textvalue
					,commenttext=dbo.udf_StripSelectedHTMLTags(@v_textvalue,0)
					,commenthtmllite=dbo.udf_StripSelectedHTMLTags(@v_textvalue,1)
					,invalidhtmlind=@v_invalidhtmlind
				WHERE bookkey = @v_bookkey
					AND printingkey = @v_printingkey
					AND commenttypecode = @v_commenttypecode
					AND commenttypesubcode = @v_commenttypesubcode
				end try
				begin catch
					EXECUTE imp_write_feedback @i_batch,@i_row,NULL,@i_elementseq,300022000001,'Error in HTML content',3,3
				end catch

				IF @Debug <> 0 PRINT 'END update bookcomments for @v_bookkey = ' + cast(@v_bookkey AS VARCHAR(max))
			END
		END
			
		IF @v_errcode >= @i_level
		BEGIN
			IF @Debug <> 0 PRINT '@v_errcode = ' + coalesce(cast(@v_errcode as varchar(max)),'*NULL*') 
			IF @Debug <> 0 PRINT '@v_errmsg = ' + coalesce(cast(@v_errmsg as varchar(max)),'*NULL*') 
			EXECUTE imp_write_feedback @i_batch,@i_row,NULL,@i_elementseq,300022000001,@v_errmsg,@v_errcode,3
		END
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300022000001]
	TO PUBLIC
GO


