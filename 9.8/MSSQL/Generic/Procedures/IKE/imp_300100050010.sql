/******************************************************************************
**  Name: imp_300100050010
**  Desc: IKE TaqProjectTask update
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
		WHERE id = object_id(N'[dbo].[imp_300100050010]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300100050010]
GO

CREATE PROCEDURE dbo.imp_300100050010 @i_batch INT
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
		,@v_ScheduleDate AS DATETIME
		,@v_CountOfTasksWithDates as INT
		,@v_TaskViewKey AS INT
		,@v_elementkey AS INT
		,@v_bookkey AS BIGINT
		,@v_errcode AS INT
		,@v_errmsg AS VARCHAR(4000)
		,@v_errseverity AS INT
		,@v_TaskViewName AS VARCHAR(4000)

	
	SET @DEBUG = 0
	IF @DEBUG <> 0 PRINT 'dbo.imp_300100050010'
	
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
	SET @v_errmsg='Succesfully updated task template dates'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)

	SELECT	@v_ScheduleDate = originalvalue
	FROM	imp_batch_detail b
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementkey=100050010

	SELECT	@v_TaskViewKey = cast(tv.taskviewkey as int)
			,@v_TaskViewName=cast(b.originalvalue as varchar(max))
	FROM	taskview tv
			INNER JOIN imp_batch_detail b ON tv.taskviewdesc=cast(b.originalvalue as varchar(max))
	WHERE	b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq=@i_elementseq
			AND b.elementkey=100050002
			AND tv.taskgroupind=1
			
	SET @v_TaskViewName = coalesce(@v_TaskViewName,'*NULL*')
	SET @v_TaskViewKey = coalesce(@v_TaskViewKey, 0)
	SET @v_bookkey = coalesce(@v_bookkey, 0)
	SET @v_ScheduleDate = coalesce(@v_ScheduleDate, 0)

	IF @DEBUG <> 0 PRINT '@v_bookkey = ' + cast(@v_bookkey AS VARCHAR(max))
	IF @DEBUG <> 0 PRINT '@v_ScheduleDate = ' + cast(@v_ScheduleDate AS VARCHAR(max))
	IF @DEBUG <> 0 PRINT '@v_TaskViewKey = ' + cast(@v_TaskViewKey AS VARCHAR(max))
	IF @DEBUG <> 0 PRINT '@v_TaskViewName = ' + cast(@v_TaskViewName AS VARCHAR(max))

	IF @v_ScheduleDate > 0 AND @v_bookkey > 0 and @v_TaskViewKey>0
	BEGIN
		BEGIN TRY
			--make sure that none of the tasks in the applied template already has a date in TaqProjectTask
			-- ... if it does then don't apply dates for any task belonging to this templatekey
			SELECT	DISTINCT
					@v_CountOfTasksWithDates=COUNT(tvdt.taskviewkey)
			FROM	taskviewdatetype tvdt
					inner join taqprojecttask tpt on tpt.datetypecode=tvdt.datetypecode
			WHERE	tvdt.taskviewkey=@v_TaskViewKey
					AND tpt.activedate is not null
			
			SET @v_CountOfTasksWithDates=coalesce(@v_CountOfTasksWithDates,0)
			IF @v_CountOfTasksWithDates>0
			BEGIN
				-- don't schedule any task on this template
				SET @v_errmsg = 'This template (taskviewkey=' + CAST(@v_TaskViewKey as varchar(max)) + ') cannot be applied because it contains tasks that are already scheduled in the title (bookkey=' + CAST(@v_bookkey as varchar(max)) + ')'
				SET @v_errseverity=2
				IF @DEBUG <> 0 PRINT @v_errmsg
				EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @v_errseverity, 3				
			END 
		
			--build a temp table that applies a running total to the durations for a taskviewkey
			DECLARE @Durations TABLE (
				taskviewkey		INT
				,datetypecode	INT
				,sortorder		INT
				,duration		INT
				,RunningTotal	INT
				,TaskDate		DATETIME
				)
			DECLARE @RunningTotal INT
			SET @RunningTotal = 0
			
			-- ... populate basic @Durations table with sort order and durations from the taskviewdatetype table
			INSERT INTO 
					@Durations
			SELECT	taskviewkey
					,datetypecode
					,sortorder
					,duration
					,NULL
					,NULL
			FROM	taskviewdatetype
			WHERE	duration > 0
					AND taskviewkey=@v_TaskViewKey
			ORDER BY sortorder DESC

			-- ... now update the RunningTotal column that will then drive the TaskDate column
			-- ... @RunningTotal is in terms of the # of WORKING days from the SeedDate which is usually pubdate
			UPDATE	@Durations
			SET		@RunningTotal = RunningTotal = @RunningTotal + duration
					,TaskDate=dbo.udf_dateaddworkdays(@v_ScheduleDate, -@RunningTotal)
			FROM	@Durations
			
			--select * from @Durations
			
			-- once the TaskDates have been figured out for each task for the task view go ahead and update taqprojecttask
			UPDATE	taqprojecttask
			SET		taqprojecttask.activedate = d.TaskDate
			FROM	taqprojecttask
					INNER JOIN taskviewdatetype ON taskviewdatetype.datetypecode=taqprojecttask.datetypecode
					INNER JOIN @Durations d		ON d.taskviewkey=taskviewdatetype.taskviewkey
												AND d.sortorder=taskviewdatetype.sortorder
												AND taqprojecttask.datetypecode=d.datetypecode
			WHERE	taqprojecttask.bookkey=@v_bookkey
					AND taqprojecttask.activedate IS null
					AND taskviewdatetype.taskviewkey=@v_TaskViewKey
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
		SET @v_errmsg='Task template dates were not updated: Either the TaskKey or the ScheduleDate was not specified'
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
	ON dbo.[imp_300100050010]
	TO PUBLIC
GO