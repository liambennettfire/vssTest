/******************************************************************************
**  Name: imp_100000010001
**  Desc: IKE Insert ISBN Prefixes
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
		WHERE id = object_id(N'[dbo].[imp_100000010001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100000010001]
GO

CREATE PROCEDURE dbo.imp_100000010001 
	@i_batchkey INT
	,@i_row INT
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_level INT
	,@i_userid VARCHAR(50)
AS
/* Insert ISBN Prefixes */
BEGIN
	DECLARE 
		@v_errcode INT
		,@v_errmsg VARCHAR(200)
		,@v_errlevel INT
		,@v_msg VARCHAR(500)
		,@v_ProcessType INT
		,@v_ProdNum VARCHAR(20)
		,@v_ElementKey BIGINT
		,@v_hyphen INT
		,@v_prefix VARCHAR(20)
		,@v_prodnum_formated VARCHAR(20)
		,@v_newcode INT
		,@v_count INT
		,@v_type INT
		,@Debug INT
	
	BEGIN
		SET @Debug = 0
		SET @v_errlevel = 1
		SET @v_msg = 'ISBN Prefixes were successfully Inserted'
		SET @v_ProdNum = '0000000000'
		SET @v_ElementKey  =0
		
		if @Debug<>0 print 'imp_100000010001 :: Insert ISBN Prefixes'
		
		select	@v_ProcessType = imp_batch_master.processtype
		from	imp_batch_master
		where	templatekey = @i_templatekey	
				and batchkey = @i_batchkey
		
		if @v_ProcessType<>3
			begin
				set @v_msg = 'ISBN Prefixes were NOT processed because ''ProcessType'' <> 3'
				exec imp_write_feedback @i_batchkey, @i_row, 100000010, @i_elementseq, @i_rulekey, @v_msg ,@v_errlevel, 1
				if @Debug<>0 print @v_msg
				return
			end
		
		/*It is important that this loader rule runs AFTER all ProdNums have been written to imp_batch_detail (processorder=9999)*/
		select	top 1
				@v_ProdNum = originalvalue
				,@v_ElementKey = elementkey
		from	imp_batch_detail
		where	batchkey = @i_batchkey
				and row_id = @i_row
				and elementseq = @i_elementseq
				and elementkey IN
					(
						100010000	/*ISBN*/
						,100010001	/*ISBN10*/
						,100010002	/*EAN*/
						,100010003	/*EAN13*/
					)
		Order by elementkey desc
		
		if @Debug<>0 print '@v_ProdNum = ' + cast(@v_ProdNum as varchar(max))
		if @Debug<>0 print '@v_ElementKey = ' + cast(@v_ElementKey as varchar(max))
		
		if @v_ElementKey = 0
			begin
				set @v_msg = 'The Product Number could not be found in Batch Detail for this row'
				exec imp_write_feedback @i_batchkey, @i_row, 100000010, @i_elementseq, @i_rulekey, @v_msg ,@v_errlevel, 1
				if @Debug<>0 print @v_msg
				return				
			end
		
		--@i_type = 0  - ISBN-10      (this is the 10-digit/13-character pre-2007 ISBN)
		--@i_type = 1  - ISBN-13/EAN  (this is the NEW 13-digit/17-character ISBN)
		--@i_type = 2  - GTIN         (14-digit global trade item number)

		if @v_ElementKey = 100010000 set @v_type = 1	/*ISBN*/
		if @v_ElementKey = 100010001 set @v_type = 0	/*ISBN10*/
		if @v_ElementKey = 100010002 set @v_type = 1	/*EAN*/
		if @v_ElementKey = 100010003 set @v_type = 1	/*EAN13*/
								
		EXECUTE qean_validate_product @v_prodnum,@v_type,0,NULL,@v_prodnum_formated out,@v_errcode out,@v_errmsg out
		
		if @Debug<>0 print '@v_prodnum_formated = ' + cast(@v_prodnum_formated as varchar(max))
		
		SET @v_hyphen = charindex('-', @v_prodnum_formated)
		SET @v_hyphen = charindex('-', @v_prodnum_formated, @v_hyphen + 1)

		IF @v_hyphen > 0
		BEGIN
			IF @v_type = 0
			BEGIN
				SET @v_prefix = substring(@v_prodnum_formated, 1, @v_hyphen - 1)
			END
			ELSE
			BEGIN
				SET @v_hyphen = charindex('-', @v_prodnum_formated, @v_hyphen + 1)
				SET @v_prefix = substring(@v_prodnum_formated, 5, @v_hyphen - 5)
			END
		END
		
		if @Debug<>0 print 'looking up @v_prefix = ' + cast(@v_prefix as varchar(max))
		
		SELECT @v_count = count(*)
		FROM subgentables
		WHERE tableid = 138
			AND datacode = 1
			AND datadesc = LTRIM(RTRIM(@v_prefix))

		IF @v_count = 1
			BEGIN
				set @v_msg = 'The prefix (' + cast(@v_prefix as varchar(max)) + ') is already in the system.'
				exec imp_write_feedback @i_batchkey, @i_row, 100000010, @i_elementseq, @i_rulekey, @v_msg ,@v_errlevel, 1
				if @Debug<>0 print @v_msg			
			END
		ELSE
			BEGIN
				SELECT @v_newcode = max(datasubcode)
				FROM subgentables
				WHERE tableid = 138
					AND datacode = 1

				SET @v_newcode = @v_newcode + 1

				if @Debug<>0 print 'adding @v_prefix = ' + cast(@v_prefix as varchar(max))
				if @Debug<>0 print '@v_newcode = ' + cast(@v_newcode AS VARCHAR)

				INSERT INTO subgentables (
					tableid
					,datacode
					,datasubcode
					,datadesc
					,deletestatus
					,tablemnemonic
					,lastuserid
					,lastmaintdate
					)
				VALUES (
					138
					,1
					,@v_newcode
					,@v_prefix
					,'N'
					,'ISBNPrefix'
					,@i_userid
					,getdate()
					) --update the lastuserid
			END		
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_100000010001]
	TO PUBLIC
GO

