/******************************************************************************
**  Name: imp_100050013001
**  Desc: IKE Data Setup for ISBN Prefix
**  Auth: Marcus Keyser     
**  Date: Jan 17, 2013
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
	SELECT	*
	FROM	dbo.sysobjects
	WHERE	id = object_id(N'[dbo].[imp_100050013001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[imp_100050013001]
GO

CREATE PROCEDURE dbo.imp_100050013001 
	@i_batchkey INT
	,@i_row INT
	,@i_elementseq INT
	,@i_templatekey INT
	,@i_rulekey BIGINT
	,@i_level INT
	,@i_userid VARCHAR(50)
AS

BEGIN
	DECLARE 
	@DEBUG AS INT
	,@v_elementkey AS INT
	,@v_elementkey_prodnum AS INT
	,@v_prodnum VARCHAR(20)
	,@v_bookkey AS BIGINT
	,@v_errcode AS INT
	,@v_errmsg AS VARCHAR(4000)
	,@v_errseverity AS INT

	SET @v_elementkey=100050013
	SET @v_errmsg='No ISBN Prefix Data Setup Required'
	SET @v_errseverity=1
	
	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT 'dbo.imp_100050013001'
	
	IF @DEBUG <> 0 PRINT  '@i_batchkey  =  ' + coalesce(cast(@i_batchkey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_row  =  ' + coalesce(cast(@i_row as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_elementseq  =  ' + coalesce(cast(@i_elementseq as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_templatekey  =  ' + coalesce(cast(@i_templatekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_rulekey  =  ' + coalesce(cast(@i_rulekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_level  =  ' + coalesce(cast(@i_level as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_userid  =  ' + coalesce(cast(@i_userid as varchar(max)),'*NULL*') 
	
	SELECT	@v_elementkey_prodnum=addlqualifier
	FROM	imp_template_detail
	WHERE	imp_template_detail.templatekey=@i_templatekey
			AND elementkey=@v_elementkey

	SELECT	@v_prodnum = originalvalue
	FROM	imp_batch_detail b 
	WHERE	b.batchkey = @i_batchkey
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND b.elementkey = @v_elementkey_prodnum

	IF @DEBUG <> 0 PRINT  '@v_elementkey_prodnum  =  ' + coalesce(cast(@v_elementkey_prodnum as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@v_prodnum  =  ' + coalesce(cast(@v_prodnum as varchar(max)),'*NULL*') 

	IF @v_prodnum IS NOT NULL
	BEGIN
		BEGIN TRY
			IF @DEBUG <> 0 PRINT  '@v_elementkey =  ' + cast(@v_elementkey as varchar(max))
			IF @DEBUG <> 0 PRINT  '@v_prodnum =  ' + cast(@v_prodnum as varchar(max))
			
			DECLARE 
				@v_GroupIdentifier VARCHAR(1)
				,@v_hyphen INT
				,@v_CheckSum VARCHAR(1)
				,@v_prefix VARCHAR(20)
				,@v_prodnum_formated VARCHAR(20)
				,@v_newcode INT
				,@v_count INT
				,@v_type INT
				,@v_errcode2 INT
				,@v_errmsg2 VARCHAR(200)		
						
			--Select the proper number from the 2 below.
			--SET @v_type = 0 --(ISBN-10: this is the 10-digit/13-character pre-2007 ISBN)
			SET @v_type = 1 --(ISBN-13/EAN: this is the NEW 13-digit/17-character ISBN)
			
			SELECT @v_GroupIdentifier = SUBSTRING(@v_prodnum, 1, 1)
			SELECT @v_CheckSum = SUBSTRING(@v_prodnum, 10, 1)
			
			IF @DEBUG <> 0 PRINT  '@v_type =  ' + cast(@v_type as varchar(max))
			IF @DEBUG <> 0 PRINT  '@v_GroupIdentifier =  ' + cast(@v_GroupIdentifier as varchar(max))
			IF @DEBUG <> 0 PRINT  '@v_CheckSum =  ' + cast(@v_CheckSum as varchar(max))

			EXECUTE qean_validate_product @v_prodnum,@v_type,0,NULL,@v_prodnum_formated out,@v_errcode2 out,@v_errmsg2 out

			SET @v_hyphen = charindex('-', @v_prodnum_formated)
			SET @v_hyphen = charindex('-', @v_prodnum_formated, @v_hyphen + 1)

			IF @DEBUG <> 0 PRINT  '@v_prodnum_formated =  ' + cast(@v_prodnum_formated as varchar(max))
			IF @DEBUG <> 0 PRINT  '@v_hyphen =  ' + cast(@v_hyphen as varchar(max))
			
			IF @v_hyphen > 0
			BEGIN
				IF @v_type = 0
				BEGIN
					SET @v_prefix = substring(@v_prodnum_formated, 1, @v_hyphen - 1)
				END ELSE BEGIN
					SET @v_hyphen = charindex('-', @v_prodnum_formated, @v_hyphen + 1)
					SET @v_prefix = substring(@v_prodnum_formated, 5, @v_hyphen - 5)
				END
			END

			IF @DEBUG <> 0 PRINT  '@v_prefix =  ' + cast(@v_prefix as varchar(max))

			SELECT	@v_count = count(*)
			FROM	subgentables
			WHERE	tableid = 138
					AND datacode = 1
					AND datadesc = LTRIM(RTRIM(@v_prefix))

			IF @v_count = 0
			BEGIN
				SELECT	@v_newcode = coalesce (max(datasubcode),0) + 1
				FROM	subgentables
				WHERE	tableid = 138
						AND datacode = 1

				IF @DEBUG <> 0 PRINT  'ADD @v_prefix =  ' + cast(@v_prefix as varchar(max))
				IF @DEBUG <> 0 PRINT  'ADD @v_newcode =  ' + cast(@v_newcode as varchar(max))
				
				IF LEN(COALESCE(@v_prefix,''))>0 
				BEGIN

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
						,'mkIKE_DataSetup'
						,getdate()
						) --update the lastuserid
				END
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
		SET @v_errmsg='No Valid EAN was found in ElementKey=' + CAST(@v_elementkey_prodnum as varchar(max)) + ' for ElementSequenceNum = ' + CAST(@i_elementseq as varchar(max))
		SET @v_errseverity=0
	END
	IF @DEBUG <> 0 PRINT @v_errmsg
	EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq ,@i_rulekey, @v_errmsg, @v_errseverity, 1
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_100050013001]
	TO PUBLIC
GO


