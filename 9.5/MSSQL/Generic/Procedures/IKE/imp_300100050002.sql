/******************************************************************************
**  Name: imp_300100050002
**  Desc: IKE update TaqProjectTasks
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
		WHERE id = object_id(N'[dbo].[imp_300100050002]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300100050002]
GO

CREATE PROCEDURE dbo.imp_300100050002 
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
		,@v_TaskViewKey AS BIGINT
		,@v_TaskViewName AS VARCHAR(4000)
		,@v_elementkey AS INT
		,@v_bookkey AS BIGINT
		,@v_errcode AS INT
		,@v_errmsg AS VARCHAR(4000)
		,@v_errseverity AS INT

	
	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT 'dbo.imp_300100050002'
	
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

	
	SELECT	@v_TaskViewKey = tv.taskviewkey
			,@v_elementkey = b.elementkey
			,@v_TaskViewName=tv.taskviewdesc
	FROM	taskview tv
			INNER JOIN imp_batch_detail b ON tv.taskviewdesc=b.originalvalue
			INNER JOIN imp_DML_elements d ON b.elementkey = d.elementkey
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND d.DMLkey = @i_dmlkey
			AND tv.taskgroupind=1

	SET @v_TaskViewName = coalesce(@v_TaskViewName,'*NULL*')
	SET @v_TaskViewKey = coalesce(@v_TaskViewKey, 0)
	
	SET @v_errseverity=1
	SET @v_errmsg='Succesfully added TaskTemplate ('+@v_TaskViewName+')'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
	SET @v_bookkey = coalesce(@v_bookkey, 0)
	SET @v_TaskViewKey = coalesce(@v_TaskViewKey, 0)

	IF @DEBUG <> 0 PRINT '@v_bookkey = ' + cast(@v_bookkey AS VARCHAR(max))
	IF @DEBUG <> 0 PRINT '@v_TaskViewKey = ' + cast(@v_TaskViewKey AS VARCHAR(max))
	IF @DEBUG <> 0 PRINT '@v_TaskViewName = ' + cast(@v_TaskViewName AS VARCHAR(max))

	IF @v_TaskViewKey > 0 AND @v_bookkey > 0
	BEGIN
		--check to see if there are any tasks (datetypes) in the template that already exist in TaqProjectTasks
		-- ... if there are then don't process this template at all and report this in the feedback
		BEGIN TRY	
			DECLARE	@v_count AS INT

			SELECT	@v_count = count(*)
			FROM	taskviewdatetype tvdt
					INNER JOIN taqprojecttask tpt ON tvdt.datetypecode = tpt.datetypecode
			WHERE	taskviewkey = @v_TaskViewKey 
					AND tpt.bookkey = @v_bookkey

			IF @v_count>0
			BEGIN
				SET @v_errmsg = 'This template (' + CAST(@v_TaskViewName as varchar(max)) + ') cannot be applied because it contains tasks that are already associated to the title (bookkey=' + CAST(@v_bookkey as varchar(max)) + ')'
				SET @v_errseverity = 2
				IF @DEBUG <> 0 PRINT @v_errmsg
				EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errseverity, 3
				RETURN			
			END
		END TRY
		BEGIN CATCH
			--something really bad happened ?!?
			SET @v_errcode = @@ERROR
			SET @v_errmsg = ERROR_MESSAGE()
			SET @v_errseverity = 3
			IF @DEBUG <> 0 PRINT @v_errcode
			IF @DEBUG <> 0 PRINT @v_errmsg

			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errseverity, 3
			RETURN
		END CATCH
		
		BEGIN TRY
			--now get the tasks from taskviewdatetype along with the correct people and apply to taqprojecttask
			INSERT INTO	taqprojecttask (
					taqtaskkey
					,bookkey
					,datetypecode
					,lastuserid
					,lastmaintdate
					,printingkey
					,globalcontactkey
					,rolecode
					,globalcontactkey2
					,rolecode2
					,duration)
			SELECT	(SELECT max(taqtaskkey)
					FROM taqprojecttask) + row_number() 
					OVER (ORDER BY taskviewdatetype.datetypecode)
					,@v_bookkey
					,taskviewdatetype.datetypecode
					,@i_userid
					,getdate()
					,1
					,gc.globalcontactkey
					,taskviewdatetype.rolecode
					,gc2.globalcontactkey
					,taskviewdatetype.rolecode2
					,taskviewdatetype.duration
									
			FROM	taskviewdatetype
					LEFT JOIN gentables gt		ON gt.datacode=taskviewdatetype.rolecode 
												AND gt.tableid=285
					LEFT JOIN gentables gt2		ON gt2.datacode=taskviewdatetype.rolecode2
												AND gt2.tableid=285
					
					LEFT JOIN	(select	bd_RL.batchkey			as BATCHKEY
										,bd_RL.row_id			as ROWID
										,bd_RL.elementseq		as ELEMSEQ
										,bd_RL.originalvalue	as ROLE
										,bd_FN.originalvalue	as FNAME
										,bd_LN.originalvalue	as LNAME
										,bd_MN.originalvalue	as MNAME
								from	imp_batch_detail bd_RL
										left join imp_batch_detail bd_FN	on bd_RL.batchkey=bd_FN.batchkey 
																			and bd_RL.row_id=bd_FN.row_id
																			and bd_RL.elementseq=bd_FN.elementseq
																			and bd_FN.elementkey=100060001
										left join imp_batch_detail bd_LN	on bd_RL.batchkey=bd_LN.batchkey 
																			and bd_RL.row_id=bd_LN.row_id
																			and bd_RL.elementseq=bd_LN.elementseq
																			and bd_LN.elementkey=100060002
										left join imp_batch_detail bd_MN	on bd_RL.batchkey=bd_MN.batchkey 
																			and bd_RL.row_id=bd_MN.row_id
																			and bd_RL.elementseq=bd_MN.elementseq
																			and bd_MN.elementkey=100060003
								where	bd_RL.batchkey=@i_batch 
										and bd_RL.elementkey=100060004) AS SourceContacts
												ON SourceContacts.ROLE=gt.datadesc											

					LEFT JOIN	(select	bd_RL.batchkey			as BATCHKEY
										,bd_RL.row_id			as ROWID
										,bd_RL.elementseq		as ELEMSEQ
										,bd_RL.originalvalue	as ROLE
										,bd_FN.originalvalue	as FNAME
										,bd_LN.originalvalue	as LNAME
										,bd_MN.originalvalue	as MNAME
								from	imp_batch_detail bd_RL
										left join imp_batch_detail bd_FN	on bd_RL.batchkey=bd_FN.batchkey 
																			and bd_RL.row_id=bd_FN.row_id
																			and bd_RL.elementseq=bd_FN.elementseq
																			and bd_FN.elementkey=100060001
										left join imp_batch_detail bd_LN	on bd_RL.batchkey=bd_LN.batchkey 
																			and bd_RL.row_id=bd_LN.row_id
																			and bd_RL.elementseq=bd_LN.elementseq
																			and bd_LN.elementkey=100060002
										left join imp_batch_detail bd_MN	on bd_RL.batchkey=bd_MN.batchkey 
																			and bd_RL.row_id=bd_MN.row_id
																			and bd_RL.elementseq=bd_MN.elementseq
																			and bd_MN.elementkey=100060003
								where	bd_RL.batchkey=@i_batch 
										and bd_RL.elementkey=100060004) AS SourceContacts2
												ON SourceContacts2.ROLE=gt2.datadesc

												
					LEFT JOIN globalcontact gc	on gc.firstname=SourceContacts.FNAME
												and gc.lastname=SourceContacts.LNAME
												and (gc.middlename=SourceContacts.MNAME OR (gc.middlename=gc.middlename and SourceContacts.MNAME is null))
					LEFT JOIN globalcontact gc2	on gc2.firstname=SourceContacts2.FNAME
												and gc2.lastname=SourceContacts2.LNAME
												and (gc2.middlename=SourceContacts2.MNAME OR (gc2.middlename=gc2.middlename and SourceContacts2.MNAME is null))												
					LEFT JOIN taqprojecttask	ON taqprojecttask.datetypecode=taskviewdatetype.datetypecode
												AND taqprojecttask.bookkey=@v_bookkey
					
			WHERE	taskviewkey = @v_TaskViewKey
					AND taqprojecttask.datetypecode IS NULL		
		
			
			--check to see if task contacts/roles were updated ... if not see if there are any matching contacts already assoced to the title
			UPDATE	taqprojecttask
			SET		globalcontactkey=bc.globalcontactkey
			FROM	taqprojecttask	tpt 
					inner join bookcontact bc on bc.bookkey=tpt.bookkey
					inner join bookcontactrole bcr on bc.bookcontactkey=bcr.bookcontactkey and bcr.rolecode=tpt.rolecode
			WHERE	tpt.bookkey=@v_bookkey
					and tpt.globalcontactkey is null
						
			UPDATE	taqprojecttask
			SET		globalcontactkey2=bc.globalcontactkey
			FROM	taqprojecttask	tpt 
					inner join bookcontact bc on bc.bookkey=tpt.bookkey
					inner join bookcontactrole bcr on bc.bookcontactkey=bcr.bookcontactkey and bcr.rolecode=tpt.rolecode2
			WHERE	tpt.bookkey=@v_bookkey
					and tpt.globalcontactkey2 is null

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
		SET @v_errmsg='Either the Template Key or a BookKey are missing'
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
	ON dbo.[imp_300100050002]
	TO PUBLIC
GO