/******************************************************************************
**  Name: imp_300011021001
**  Desc: IKE Skipped OrgLevels from OrgEntry Processing
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
		WHERE id = object_id(N'[dbo].[imp_300011021001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300011021001]
GO

CREATE PROCEDURE dbo.imp_300011021001 
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
BEGIN
	SET NOCOUNT ON

	DECLARE @DEBUG AS INT
		,@v_elementval AS BIGINT
		,@v_elementkey AS INT
		,@v_bookkey AS BIGINT
		,@v_errcode AS INT
		,@v_errmsg AS VARCHAR(4000)
		,@v_errseverity AS INT
		,@v_orgentrydesc AS VARCHAR(255)
		,@ProcessUpdate AS INT

	
	SET @DEBUG = 1
	IF @DEBUG <> 0 PRINT 'dbo.imp_300011021001'
	
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

	
	SET @v_errseverity=1
	SET @v_errmsg='Skipped OrgLevels from OrgEntry Processing'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)

	SELECT	@v_elementval = originalvalue
			,@v_elementkey = b.elementkey
	FROM	imp_batch_detail b
			INNER JOIN imp_DML_elements d ON b.elementkey = d.elementkey
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND d.DMLkey = @i_dmlkey

	SELECT	@v_orgentrydesc = originalvalue
	FROM	imp_batch_detail b
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementkey=100011025
	SET @v_bookkey = coalesce(@v_bookkey, 0)
	SET @v_elementval = coalesce(@v_elementval, 0)
	SET @v_orgentrydesc = coalesce(@v_orgentrydesc, '')

	IF @DEBUG <> 0 PRINT '@v_bookkey = ' + cast(@v_bookkey AS VARCHAR(max))
	IF @DEBUG <> 0 PRINT '@v_elementval = ' + cast(@v_elementval AS VARCHAR(max))
	IF @DEBUG <> 0 PRINT '@v_orgentrydesc = ' + cast(@v_orgentrydesc AS VARCHAR(max))

	IF len(@v_orgentrydesc)>0
	BEGIN
		BEGIN TRY	
			IF @DEBUG <> 0 PRINT 'PROCESSING ORG LEVELS'

			DECLARE	@v_Level1 AS INT
					,@v_Level2 AS INT
					,@v_Level3 AS INT
					,@v_Level4 AS INT
					,@v_Level5 AS INT
					,@v_Level6 AS INT
					,@v_Key1 AS INT
					,@v_Key2 AS INT
					,@v_Key3 AS INT
					,@v_Key4 AS INT
					,@v_Key5 AS INT
					,@v_Key6 AS INT

			SELECT	@v_Level1=o1.orglevelkey,@v_Key1=o1.orgentrykey
					,@v_Level2=o2.orglevelkey,@v_Key2=o2.orgentrykey
					,@v_Level3=o3.orglevelkey,@v_Key3=o3.orgentrykey
					,@v_Level4=o4.orglevelkey,@v_Key4=o4.orgentrykey
					,@v_Level5=o5.orglevelkey,@v_Key5=o5.orgentrykey
					,@v_Level6=o6.orglevelkey,@v_Key6=o6.orgentrykey
			FROM	orgentry o1
					LEFT JOIN orgentry o2 ON o1.orgentryparentkey = o2.orgentrykey
					LEFT JOIN orgentry o3 ON o2.orgentryparentkey = o3.orgentrykey
					LEFT JOIN orgentry o4 ON o3.orgentryparentkey = o4.orgentrykey
					LEFT JOIN orgentry o5 ON o4.orgentryparentkey = o5.orgentrykey
					LEFT JOIN orgentry o6 ON o5.orgentryparentkey = o6.orgentrykey
			WHERE	o1.orgentrydesc = @v_orgentrydesc

			CREATE TABLE #MyOrgLevels (OrgLevel INT, OrgKey INT)

			INSERT INTO #MyOrgLevels VALUES (@v_Level1, @v_Key1)
			INSERT INTO #MyOrgLevels VALUES (@v_Level2, @v_Key2)
			INSERT INTO #MyOrgLevels VALUES (@v_Level3, @v_Key3)
			INSERT INTO #MyOrgLevels VALUES (@v_Level4, @v_Key4)
			INSERT INTO #MyOrgLevels VALUES (@v_Level5, @v_Key5)
			INSERT INTO #MyOrgLevels VALUES (@v_Level6, @v_Key6)
						
			SELECT	@ProcessUpdate = count(*)
			FROM	bookorgentry AS boe
					INNER JOIN #MyOrgLevels ol ON ol.OrgLevel = boe.orglevelkey
			WHERE	bookkey = @v_bookkey
					AND boe.orgentrykey <> ol.Orgkey
			
			SET		@ProcessUpdate=coalesce(@ProcessUpdate, 0)			
			
			IF @DEBUG <> 0 PRINT '@ProcessUpdate = ' + cast(@ProcessUpdate AS VARCHAR(max))
			IF @ProcessUpdate>0
			BEGIN
				UPDATE	bookorgentry
				SET		bookorgentry.orgentrykey = ol.OrgKey
				FROM	bookorgentry AS boe
						INNER JOIN #MyOrgLevels ol ON ol.OrgLevel = boe.orglevelkey
				WHERE	bookkey = @v_bookkey
				
				SET @v_errmsg='Updated BookOrgLevels for bookkey ('+CAST(@v_bookkey as varchar(max))+') to imprint '''+@v_orgentrydesc + ''''
			END 

			DROP TABLE #MyOrgLevels

		END TRY
		BEGIN CATCH
			set @v_errcode=@@ERROR
			set @v_errmsg=ERROR_MESSAGE () 
			set @v_errseverity=3
			IF @DEBUG <> 0 PRINT @v_errcode
			IF @DEBUG <> 0 PRINT @v_errmsg					
		END CATCH
		
	END
	IF @DEBUG <> 0 PRINT @v_errmsg
	EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errseverity, 3
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300011021001]
	TO PUBLIC
GO