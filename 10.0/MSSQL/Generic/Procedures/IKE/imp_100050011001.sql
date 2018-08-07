/******************************************************************************
**  Name: imp_100050011001
**  Desc: IKE Data Setup for AuthorType
**  Auth: Marcus Keyser     
**  Date: Jan 17, 2013
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/19/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
*******************************************************************************/

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_100050011001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100050011001]
GO

CREATE PROCEDURE dbo.imp_100050011001 
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
	,@v_elementkey_target AS INT
	,@v_elementval as varchar(max)
	,@v_bookkey AS BIGINT
	,@v_errcode AS INT
	,@v_errmsg AS VARCHAR(4000)
	,@v_errseverity AS INT
	,@v_datacode AS INT
	,@v_datadesc AS varchar(MAX)

	SET @v_elementkey=100050011
	SET @v_errmsg='No AuthorType Data Setup Required'
	SET @v_errseverity=1
	SET @v_datacode=0
		
	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT 'dbo.imp_100050011001'
	
	IF @DEBUG <> 0 PRINT  '@i_batchkey  =  ' + coalesce(cast(@i_batchkey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_row  =  ' + coalesce(cast(@i_row as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_elementseq  =  ' + coalesce(cast(@i_elementseq as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_templatekey  =  ' + coalesce(cast(@i_templatekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_rulekey  =  ' + coalesce(cast(@i_rulekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_level  =  ' + coalesce(cast(@i_level as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_userid  =  ' + coalesce(cast(@i_userid as varchar(max)),'*NULL*') 

	SET @v_errseverity=1

	SELECT	@v_elementkey_target=addlqualifier
	FROM	imp_template_detail
	WHERE	imp_template_detail.templatekey=@i_templatekey
			AND elementkey=@v_elementkey
			
	SELECT	@v_elementval = originalvalue
	FROM	imp_batch_detail b 
	WHERE	b.batchkey = @i_batchkey
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND b.elementkey = @v_elementkey_target

	IF @DEBUG <> 0 PRINT  '@v_elementkey =  ' + coalesce(cast(@v_elementkey_target as varchar(max)), '*NULL*')
	IF @DEBUG <> 0 PRINT  '@v_elementval =  ' + coalesce(cast(@v_elementval as varchar(max)), '*NULL*')
			
	SET @v_elementval = coalesce(@v_elementval, '')
	IF LEN(@v_elementval)>0
	BEGIN
		BEGIN TRY
			--See if this value exists on the gentable (tableid=134)
			EXEC find_gentables_mixed @v_elementval,134,@v_datacode output,@v_datadesc output		
			IF @DEBUG <> 0 PRINT  '@v_elementval =  ' + coalesce(cast(@v_elementval as varchar(max)), '*NULL*')
			IF @DEBUG <> 0 PRINT  '@v_datacode =  ' + coalesce(cast(@v_datacode as varchar(max)), '*NULL*')
			IF @DEBUG <> 0 PRINT  '@v_datadesc =  ' + coalesce(cast(@v_datadesc as varchar(max)), '*NULL*')
			
			SET @v_datacode=coalesce(@v_datacode,0)
			IF @v_datacode=0
			BEGIN
				IF @DEBUG <> 0 PRINT  'START INSERT'
				INSERT INTO gentables (
					tableid
					,datacode
					,datadesc
					,deletestatus
					,applid
					,sortorder
					,tablemnemonic
					,externalcode
					,datadescshort
					,lastuserid
					,lastmaintdate
					,numericdesc1
					,numericdesc2
					,bisacdatacode
					,gen1ind
					,gen2ind
					,acceptedbyeloquenceind
					,exporteloquenceind
					,lockbyqsiind
					,lockbyeloquenceind
					,eloquencefieldtag
					,alternatedesc1
					,alternatedesc2
					,qsicode)
				VALUES (
					134
					,(SELECT MAX(datacode) FROM gentables WHERE tableid=134) +1
					,@v_elementval
					,'N'
					,NULL
					,NULL
					,'AuthorTy'
					,UPPER(@v_elementval)
					,NULL
					,'mkIKE_DataSetup'
					,GETDATE()
					,NULL
					,NULL
					,UPPER(@v_elementval)
					,NULL
					,NULL
					,1
					,1
					,0
					,0
					,UPPER(@v_elementval)
					,NULL
					,NULL
					,NULL)
				IF @DEBUG <> 0 PRINT  'END INSERT'
				SET @v_errseverity=0
				SET @v_errmsg='An AuthorRole of ''' + cast(@v_elementval as varchar(max)) + '''was inserted in gentables'
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
		SET @v_errseverity=2
		SET @v_errmsg='No AuthorRole value was found in ElementKey = ' + CAST(@v_elementkey_target as varchar(max))
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
	ON dbo.[imp_100050011001]
	TO PUBLIC
GO


