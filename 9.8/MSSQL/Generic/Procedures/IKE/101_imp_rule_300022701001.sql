
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
**  Name: imp_rule_ext_300022701001
**  Desc: IKE comment processing
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_rule_ext_300022701001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_rule_ext_300022701001]
GO

create PROCEDURE [dbo].[imp_rule_ext_300022701001] (
	@i_batchkey INT
	,@i_row INT
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_level INT
	,@i_userid VARCHAR(50)
	,@i_titlekeyset VARCHAR(500)
	,@o_writehistoryind INT OUTPUT
	)
AS
DECLARE @v_addlqualifier VARCHAR(500)
	,@v_bookkey INT
	,@v_citationind INT
	,@v_history_order INT
	,@v_qsiobjectkey INT
	,@v_commentkey INT
	,@v_commenttext VARCHAR(max)
	,@v_commenttypecode INT
	,@v_commenttypesubcode INT
	,@v_count INT
	,@v_datacode INT
	,@v_datasubcode INT
	,@v_destination_pointer BINARY (16)
	,@i_dmlkey INT
	,@v_elementkey INT
	,@v_elementdesc VARCHAR(500)
	,@v_elementval VARCHAR(max)
	,@v_errcode INT
	,@v_errcode2 INT
	,@v_errmsg VARCHAR(500)
	,@v_warnmsg VARCHAR(500)
	,@v_errmsg2 VARCHAR(500)
	,@v_html_part VARCHAR(500)
	,@v_invalidhtmlind INT
	,@v_lobkey INT
	,@v_pointer INT
	,@v_printingkey INT
	,@v_row_count INT
	,@v_sortorder INT
	,@v_source_pointer BINARY (16)
	,@v_source_prefix VARCHAR(20)
	,@v_text_releasetoelo_ind VARCHAR(500)
	,@v_textauthor_d107 VARCHAR(500)
	,@v_textpubdate_d019 VARCHAR(500)
	,@v_textsource_d108 VARCHAR(500)

BEGIN
	SET @v_errcode = 1
	SET @v_errmsg = 'bookcomments: updated'
	-- no history, causes a tittlehistory error
	SET @o_writehistoryind = 0
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
	SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset, 2)

	SELECT @v_text_releasetoelo_ind = originalvalue
	FROM imp_batch_detail
	WHERE batchkey = @i_batchkey AND row_id = @i_row AND elementkey = 100022607 AND elementseq = @i_elementseq

	declare comment_cur cursor for
	SELECT  LTRIM(RTRIM(b.originalvalue))
		, b.elementkey
		, elementdesc
		, lobkey
		, td.addlqualifier
	FROM imp_batch_detail b
		,imp_DML_elements d
		,imp_element_defs e
		,imp_template_detail td
	WHERE b.batchkey = @i_batchkey AND b.row_id = @i_row AND b.elementseq = @i_elementseq AND d.dmlkey = @i_rulekey 
	AND d.elementkey = b.elementkey AND b.elementkey = e.elementkey AND b.elementkey = td.elementkey
	AND td.templatekey = @i_templatekey 

	--SELECT @v_elementval = LTRIM(RTRIM(b.originalvalue))
	--	,@v_elementkey = b.elementkey
	--	,@v_elementdesc = elementdesc
	--	,@v_lobkey = lobkey
	--	,@v_addlqualifier = td.addlqualifier
	--FROM imp_batch_detail b
	--	,imp_DML_elements d
	--	,imp_element_defs e
	--	,imp_template_detail td
	--WHERE b.batchkey = @i_batchkey AND b.row_id = @i_row AND b.elementseq = @i_elementseq AND d.dmlkey = @i_rulekey AND d.elementkey = b.elementkey AND td.templatekey = @i_templatekey AND b.elementkey = td.elementkey

	open comment_cur
	fetch comment_cur into
	  	@v_elementval
		,@v_elementkey
		,@v_elementdesc
		,@v_lobkey
		,@v_addlqualifier
    while @@FETCH_STATUS=0
	begin

	SET @v_commenttypecode = dbo.resolve_keyset(@v_addlqualifier, 1)
	SET @v_commenttypesubcode = dbo.resolve_keyset(@v_addlqualifier, 2)
	SET @v_citationind = coalesce(dbo.resolve_keyset(@v_addlqualifier, 3), 0)

	SELECT @v_commenttext = textvalue
	FROM imp_batch_lobs
	WHERE lobkey = @v_lobkey

	-- NS: 41839 - Use the current commenttypecode and commenttypesubcode to get back to the gentable entry for this commenttype, 
	--  use subgentable exporteloquenceind to set the @v_text_releasetoelo_ind accordingly. 
	IF @v_text_releasetoelo_ind IS NULL
		AND @v_citationind = 0
	BEGIN
		SELECT
			@v_text_releasetoelo_ind = s.exporteloquenceind
		FROM subgentables s
		WHERE s.tableid = 284
		AND s.datacode = @v_commenttypecode
		AND s.datasubcode = @v_commenttypesubcode
	END

	--mk20131212> This is new code to process the comment to make sure it is valid HTML
	--It replaces: 
	-- ... check_valid_html
	-- ... commenthtml_fix
	-- ... html_to_lite_from_row
	-- ... html_to_text_from_row
	-- The reason for the changes is to Use the new HTML cleaning routine 
	-- ... and becuase UPDATETEXT isn't working now thet teh datatypes have changed to NTEXT
	-- I have removed the old code to keep things neat - to get a delta of what changed use VSS and diff the history.

	SET @v_invalidhtmlind=1
	IF LEN(COALESCE(@v_commenttext,''))=0 SET @v_invalidhtmlind=0
	IF @v_invalidhtmlind<>0 SET @v_invalidhtmlind=dbo.udf_IsHtml(@v_commenttext)
	IF @v_invalidhtmlind=0 SET @v_invalidhtmlind=dbo.udf_IsValidHtml(@v_commenttext)
	IF @v_invalidhtmlind=0 AND LEFT(LTRIM(@v_commenttext),LEN('<div'))<>'<div' SET @v_commenttext='<div>'+@v_commenttext+'</div>'

	IF @v_citationind = 1 AND @v_commenttypecode IS NOT NULL AND @v_commenttypesubcode IS NOT NULL
	BEGIN
		--process citaion (insert only)
		UPDATE keys
		SET generickey = generickey + 1

		SELECT @v_qsiobjectkey = generickey
		FROM keys

		UPDATE keys
		SET generickey = generickey + 1

		SELECT @v_commentkey = generickey
		FROM keys

		INSERT INTO qsicomments (
			commentkey
			,commenttypecode
			,commenttypesubcode
			,commenthtml
			,commenthtmllite
			,commenttext
			,lastuserid
			,lastmaintdate
			,releasetoeloquenceind
			,invalidhtmlind
			)
		VALUES (
			@v_qsiobjectkey
			,@v_commenttypecode
			,@v_commenttypesubcode
			,@v_commenttext
			,dbo.udf_StripSelectedHTMLTags(@v_commenttext, 1)
			,dbo.udf_StripSelectedHTMLTags(@v_commenttext, 0)
			,@i_userid
			,getdate()
			,@v_text_releasetoelo_ind
			,@v_invalidhtmlind
			)

		SELECT @v_textauthor_d107 = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey AND row_id = @i_row AND elementkey = 100022604 AND elementseq = @i_elementseq

		SELECT @v_textsource_d108 = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey AND row_id = @i_row AND elementkey = 100022605 AND elementseq = @i_elementseq

		SELECT @v_textpubdate_d019 = originalvalue
		FROM imp_batch_detail
		WHERE batchkey = @i_batchkey AND row_id = @i_row AND elementkey = 100022606 AND elementseq = @i_elementseq

		IF ISDATE(@v_textpubdate_d019) = 0 AND @v_textpubdate_d019 IS NOT NULL
		BEGIN
			SET @v_textpubdate_d019 = NULL
			SET @v_warnmsg = 'ignoring bad source date (' + coalesce(@v_textpubdate_d019, 'n/a') + ')'

			EXECUTE imp_write_feedback @i_batchkey
				,@i_row
				,100022606
				,@i_elementseq
				,300022701001
				,@v_warnmsg
				,2
				,3
		END

		SELECT @v_history_order = count(*) + 1
		FROM citation
		WHERE bookkey = @v_bookkey

		INSERT INTO citation (
			bookkey
			,citationkey
			,citationsource
			,citationauthor
			,citationdate
			,releasetoeloquenceind
			,qsiobjectkey
			,sortorder
			,citationtypecode
			,history_order
			,lastuserid
			,lastmaintdate
			)
		VALUES (
			@v_bookkey
			,@v_commentkey
			,@v_textsource_d108
			,@v_textauthor_d107
			,@v_textpubdate_d019
			,@v_text_releasetoelo_ind
			,@v_qsiobjectkey
			,@v_sortorder
			,@v_commenttypecode
			,@v_history_order
			,@i_userid
			,getdate()
			)
	END

	IF @v_citationind = 0 AND @v_commenttypecode IS NOT NULL AND @v_commenttypesubcode IS NOT NULL
	BEGIN
		--process book comment
		SELECT @v_count = count(*)
		FROM bookcomments
		WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey AND commenttypecode = @v_commenttypecode AND commenttypesubcode = @v_commenttypesubcode

		IF @v_count = 0
		BEGIN
			UPDATE keys
			SET generickey = generickey + 1

			SELECT @v_commentkey = generickey
			FROM keys

			INSERT INTO bookcomments (
				bookkey
				,printingkey
				,commenttypecode
				,commenttypesubcode
				,commenthtml
				,commenthtmllite
				,commenttext
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
				,@v_commenttext
				,dbo.udf_StripSelectedHTMLTags(@v_commenttext, 1)
				,dbo.udf_StripSelectedHTMLTags(@v_commenttext, 0)
				,@i_userid
				,getdate()
				,@v_text_releasetoelo_ind
				,@v_invalidhtmlind
				)
		END
		ELSE
		BEGIN
			UPDATE bookcomments
			SET commenthtml = @v_commenttext
				,commenthtmllite = dbo.udf_StripSelectedHTMLTags(@v_commenttext, 1)
				,commenttext = dbo.udf_StripSelectedHTMLTags(@v_commenttext, 0)
				,lastmaintdate = getdate()
				,lastuserid = @i_userid
				,releasetoeloquenceind = @v_text_releasetoelo_ind
				,invalidhtmlind=@v_invalidhtmlind
			WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey AND commenttypecode = @v_commenttypecode AND commenttypesubcode = @v_commenttypesubcode
		END
	END

	IF @v_errcode >= @i_level
	BEGIN
		EXECUTE imp_write_feedback @i_batchkey
			,@i_row
			,NULL
			,@i_elementseq
			,300022701001
			,@v_errmsg
			,@v_errcode
			,3
	END

	fetch comment_cur into
	  	@v_elementval
		,@v_elementkey
		,@v_elementdesc
		,@v_lobkey
		,@v_addlqualifier
  end

close comment_cur
deallocate comment_cur

END
