/******************************************************************************
**  Name: imp_100050010001
**  Desc: IKE Data Setup for Org Levels
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
		WHERE id = object_id(N'[dbo].[imp_100050010001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_100050010001]
GO

CREATE PROCEDURE dbo.imp_100050010001 
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
		,@v_elementval as varchar(max)
		,@v_bookkey AS BIGINT
		,@v_errcode AS INT
		,@v_errmsg AS VARCHAR(4000)
		,@v_errseverity AS INT
		,@NEW_OrgEntryKey as INT
		,@NEW_OrgEntryParentKey as INT
		,@EXISTING_OrgEntryKey as INT
		,@EXISTING_OrgEntryParentKey as INT
		,@FirstNullOrgLevelNum as INT
		,@OrgLevelLoopCounter as INT
		,@MaxOrgLevel as INT

	SET @DEBUG = 0
	SET @v_errseverity=1
	SET	@NEW_OrgEntryKey = 0
	SET @NEW_OrgEntryParentKey = 0
	SET @v_elementkey = 100050010

	IF @DEBUG <> 0 PRINT 'dbo.imp_100050010001'
	IF @DEBUG <> 0 PRINT  '@i_batchkey  =  ' + coalesce(cast(@i_batchkey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_row  =  ' + coalesce(cast(@i_row as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_elementseq  =  ' + coalesce(cast(@i_elementseq as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_templatekey  =  ' + coalesce(cast(@i_templatekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_rulekey  =  ' + coalesce(cast(@i_rulekey as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_level  =  ' + coalesce(cast(@i_level as varchar(max)),'*NULL*') 
	IF @DEBUG <> 0 PRINT  '@i_userid  =  ' + coalesce(cast(@i_userid as varchar(max)),'*NULL*') 

	--Get the OrgLevels for the current BatchDetail row
	--drop table #MyOrgLevels
	CREATE TABLE #MyOrgLevels (
			OrgLevel	INT
			,Name		VARCHAR(MAX)
			,ElementKey BIGINT
			,Value		VARCHAR(MAX)
			,OrgKey		INT
			,ParentKey	INT
			,InsertOrg	INT
			)
	INSERT INTO #MyOrgLevels
	SELECT	DISTINCT 
			right(ed.elementmnemonic,1) as OrgLevel
			,ed.elementmnemonic
			,ed.elementkey
			,bd.originalvalue
			,null
			,null
			,null
	FROM	imp_batch_detail bd
			INNER JOIN imp_element_defs ed ON bd.elementkey = ed.elementkey
	WHERE	batchkey = @i_batchkey
			AND LEFT(ed.elementmnemonic, len('OrgGroup')) = 'OrgGroup'
			AND bd.row_id=@i_row
	ORDER BY ed.elementmnemonic
	
	--Look up the OrgEntries in the OrgEntry table and get the OrgEntryKeys
	SELECT	@MaxOrgLevel=MAX(orglevelkey) FROM orgentry
	SET		@OrgLevelLoopCounter=1
	SET		@EXISTING_OrgEntryKey = 0
	SET		@EXISTING_OrgEntryParentKey = NULL

	WHILE	@OrgLevelLoopCounter <= @MaxOrgLevel
	BEGIN
		SELECT	@EXISTING_OrgEntryKey=OrgEntryKey
				,@EXISTING_OrgEntryParentKey=OrgEntryParentKey
		FROM	#MyOrgLevels 
				LEFT JOIN orgentry	ON #MyOrgLevels.OrgLevel = orgentry.orglevelkey
									AND #MyOrgLevels.Value = CASE WHEN left(orgentrydesc,36)=left(altdesc1,36) and len(altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN altdesc1 ELSE orgentrydesc END
		WHERE	orglevelkey=@OrgLevelLoopCounter
				AND orgentry.orgentryparentkey=@EXISTING_OrgEntryKey
				
		IF @DEBUG <> 0 PRINT  '@EXISTING_OrgEntryKey  =  ' + coalesce(cast(@EXISTING_OrgEntryKey as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@EXISTING_OrgEntryParentKey  =  ' + coalesce(cast(@EXISTING_OrgEntryParentKey as varchar(max)),'*NULL*') 
		
		IF @EXISTING_OrgEntryParentKey IS NULL BREAK
		
		UPDATE	#MyOrgLevels
		SET		#MyOrgLevels.ParentKey=@EXISTING_OrgEntryParentKey
				,#MyOrgLevels.OrgKey=@EXISTING_OrgEntryKey
		WHERE	#MyOrgLevels.OrgLevel=@OrgLevelLoopCounter
		
		SET		@OrgLevelLoopCounter=@OrgLevelLoopCounter+1
		SET		@EXISTING_OrgEntryParentKey = NULL
	END
	
	--Look up the OrgEntries in the OrgEntry table and get the OrgEntryKeys
	--UPDATE	#MyOrgLevels
	--SET		#MyOrgLevels.ParentKey=orgentry.orgentryparentkey
	--		,#MyOrgLevels.OrgKey=orgentry.orgentrykey
	--FROM	#MyOrgLevels 
	--		LEFT JOIN orgentry	ON #MyOrgLevels.OrgLevel = orgentry.orglevelkey
	--							AND #MyOrgLevels.Value = CASE WHEN left(orgentrydesc,36)=left(altdesc1,36) and len(altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN altdesc1 ELSE orgentrydesc END


	--Rebuild the OrgEntry structure starting with the first missing one
	UPDATE	#MyOrgLevels
	SET		ParentKey = NULL
			,OrgKey = NULL
	WHERE	OrgKey IS NOT NULL 
			AND OrgLevel > (
				SELECT	MIN(OrgLevel)
				FROM	#MyOrgLevels
				WHERE	OrgKey IS NULL)	

	ValidateOrgEntries:
			
	--make sure all the org levels are present
	SELECT	@FirstNullOrgLevelNum=COALESCE(MIN(OrgLevel),0)
	FROM	#MyOrgLevels
	WHERE	OrgKey IS NULL	
	
	IF @FirstNullOrgLevelNum>0
	BEGIN
		--Get the next available OrgEntryKey
		IF @NEW_OrgEntryKey = 0 
		BEGIN
			SELECT	@NEW_OrgEntryKey = MAX(generickey)+1
			FROM	keys
		END
		
		--If the missing orglevel is > 1 then a parentorgkey must be set otherwise it will be 0
		-- ... thereafter the parentorgkey is set below and therefore wouldn't be 0
		IF @FirstNullOrgLevelNum > 1 AND @NEW_OrgEntryParentKey=0
		BEGIN
			SELECT	@NEW_OrgEntryParentKey=OrgKey 
			FROM	#MyOrgLevels 
			WHERE	OrgLevel=@FirstNullOrgLevelNum-1
		END
		
		--Update the temp table
		UPDATE	#MyOrgLevels 
		SET		OrgKey=@NEW_OrgEntryKey
				,ParentKey=@NEW_OrgEntryParentKey
				,InsertOrg=1
		WHERE	OrgLevel = (
				SELECT	MIN(OrgLevel)
				FROM	#MyOrgLevels
				WHERE	OrgKey IS NULL)

		--set the ParentKey for the next level to current key (starts at 0)
		SET @NEW_OrgEntryParentKey=@NEW_OrgEntryKey
		SET @NEW_OrgEntryKey=@NEW_OrgEntryKey+1
		
		--Make sure none of the new OrgEntrie are > 40 chars (max length on OrgEntryTable)
		IF EXISTS(SELECT * FROM #MyOrgLevels WHERE len(Value)>40)
		BEGIN
			SET @v_errseverity=3
			SET @v_errmsg='A missing OrgEntry Value was truncated because it is greater than 40 characters. The full Org Name is in altdesc1'
			EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq ,@i_rulekey, @v_errmsg, @v_errseverity, 1
			IF @DEBUG <> 0 PRINT @v_errmsg
		END 
		SET @v_errseverity=0
		SET @v_errmsg='A missing OrgEntry Value was added: OrgEntryKey = ' + CAST (@NEW_OrgEntryKey as varchar(10))
		IF @DEBUG <> 0 PRINT @v_errmsg
		EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq ,@i_rulekey, @v_errmsg, @v_errseverity, 1
			
		--Repeast this process until all Orgentries have been updated
		GOTO ValidateOrgEntries
	END

	IF @NEW_OrgEntryKey<>0
	BEGIN
		BEGIN TRY
			UPDATE KEYS
			SET generickey=@NEW_OrgEntryKey
		
			-- If there are any new Orgentries in #MyOrgLevels then insert them into OrgEntry
			INSERT INTO orgentry
			SELECT	mol.OrgKey
					,mol.OrgLevel
					,cast(mol.Value as varchar(40))
					,mol.ParentKey
					,cast(mol.Value as varchar(20))
					,'N'
					,'mkIKE'
					,GETDATE()
					,null
					,cast(mol.Value as varchar(100))
					,null
					,null
					,1
					,null
					,null
					,1
			FROM	#MyOrgLevels mol
			WHERE	mol.InsertOrg IS NOT NULL
		END TRY
		BEGIN CATCH
			--something really bad happened ?!?
			SET @v_errcode = @@ERROR
			SET @v_errmsg = ERROR_MESSAGE()
			SET @v_errseverity = 3
			IF @DEBUG <> 0 PRINT @v_errcode
			IF @DEBUG <> 0 PRINT @v_errmsg
			EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq ,@i_rulekey, @v_errmsg, @v_errseverity, 1			
		END CATCH
	END ELSE BEGIN
		SET @v_errmsg='No Org Levels Data Setup Required'
		SET @v_errseverity=1
		IF @DEBUG <> 0 PRINT @v_errmsg
		EXECUTE imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq ,@i_rulekey, @v_errmsg, @v_errseverity, 1
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_100050010001]
	TO PUBLIC
GO