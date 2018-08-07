/******************************************************************************
**  Name: imp_300100060004
**  Desc: IKE globalcontact title association
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/20/16      Kusum       Case 37304 - increased size of datadesc VARCHAR(MAX) 
**                           to allow for alternatedesc1
*******************************************************************************/

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_300100060004]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300100060004]
GO

CREATE PROCEDURE dbo.imp_300100060004 @i_batch INT
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
		,@v_FN AS VARCHAR(255)
		,@v_MN AS VARCHAR(255)
		,@v_LN AS VARCHAR(255)
		,@v_ROLE AS VARCHAR(255)
		,@v_ROLECODE as INT
		
		,@v_elementkey AS INT
		,@v_bookkey AS BIGINT
		,@v_globalcontactkey AS BIGINT
		,@v_errcode AS INT
		,@v_errmsg AS VARCHAR(4000)
		,@v_errseverity AS INT
		,@v_datadesc as varchar(MAX)
		,@v_sortorder as int
		,@v_count as int
		,@v_historycode as int
		,@v_historymsg  as varchar(50)
	
	SET @DEBUG = 1
	IF @DEBUG <> 0 PRINT 'dbo.imp_300100060004'
	
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
	SET @v_errmsg='Succesfully associated global contacts with the title.'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)

	SELECT	@v_FN = originalvalue
	FROM	imp_batch_detail b
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq=@i_elementseq
			AND b.elementkey=100060001

	SELECT	@v_LN = originalvalue
	FROM	imp_batch_detail b
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq=@i_elementseq
			AND b.elementkey=100060002

	SELECT	@v_MN = originalvalue
	FROM	imp_batch_detail b
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq=@i_elementseq
			AND b.elementkey=100060003
	
	SELECT	@v_ROLE = originalvalue
	FROM	imp_batch_detail b
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq=@i_elementseq
			AND b.elementkey=100060004
			
	SET @v_bookkey = coalesce(@v_bookkey, 0)

	IF @DEBUG <> 0 PRINT '@v_bookkey = ' + cast(@v_bookkey AS VARCHAR(max))
	IF @DEBUG <> 0 PRINT '@v_FN = ' + coalesce(@v_FN, '*NULL*')
	IF @DEBUG <> 0 PRINT '@v_LN = ' + coalesce(@v_LN, '*NULL*')
	IF @DEBUG <> 0 PRINT '@v_MN = ' + coalesce(@v_MN, '*NULL*')
	IF @DEBUG <> 0 PRINT '@v_ROLE = ' + coalesce(@v_ROLE, '*NULL*')

	IF @v_bookkey > 0 AND @v_FN is not null and @v_LN is not null 
	BEGIN
		BEGIN TRY	
			SELECT	TOP 1 @v_globalcontactkey=globalcontactkey
			FROM	globalcontact
			WHERE	firstname=@v_FN
					and lastname=@v_LN
					and (middlename=@v_MN OR (middlename=middlename and @v_MN is null))
			
			IF @v_globalcontactkey is null
			BEGIN
				SET @v_errmsg='Global contacts were not associated: The author could not be found in the Globalcontacts table'
			END ELSE BEGIN
				--get role code
				EXEC dbo.find_gentables_mixed @v_ROLE,134,@v_ROLECODE output,@v_datadesc output
				
				--get sort order
				SELECT	@v_sortorder=max(sortorder)+1
				FROM	bookauthor
				WHERE	bookkey=@v_bookkey
				
				--don't reapply the same contact to the same role
				SELECT	@v_count = COUNT(authorkey) 
				FROM	bookauthor
				WHERE	bookkey=@v_bookkey
						and authorkey=@v_globalcontactkey
						and authortypecode=@v_ROLECODE
				
				IF coalesce(@v_count,0)=0 
				BEGIN
					INSERT INTO bookauthor
							   (bookkey
							   ,authorkey
							   ,authortypecode
							   ,reportind
							   ,primaryind
							   ,authortypedesc
							   ,lastuserid
							   ,lastmaintdate
							   ,sortorder
							   ,history_order)
						 VALUES					 
							   (@v_bookkey				--<bookkey, int,>
							   ,@v_globalcontactkey		--<authorkey, int,>
							   ,@v_ROLECODE				--<authortypecode, smallint,>
							   ,0						--<reportind, tinyint,>
							   ,0						--<primaryind, tinyint,>
							   ,@v_datadesc				--<authortypedesc, varchar(15),>
							   ,@i_userid				--<lastuserid, varchar(30),>
							   ,GETDATE()				--<lastmaintdate, datetime,>
							   ,@v_sortorder			--<sortorder, int,>
							   ,0)						--<history_order, int,>

					EXECUTE qtitle_update_titlehistory 'bookauthor', 'authortypecode', @v_bookkey, 1, 0, @v_ROLECODE, 'insert', @i_userid, @v_sortorder, NULL, @v_historycode OUTPUT, @v_historymsg OUTPUT
				END
			END
		END TRY
		BEGIN CATCH
				set @v_errcode=@@ERROR
				set @v_errmsg=ERROR_MESSAGE () 
				set @v_errseverity=3
				IF @DEBUG <> 0 PRINT @v_errcode
				IF @DEBUG <> 0 PRINT @v_errmsg					
		END CATCH
		
	END ELSE BEGIN
		SET @v_errmsg='Global contacts were not associated: Either the title or the author could not be found'
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
	ON dbo.[imp_300100060004]
	TO PUBLIC
GO