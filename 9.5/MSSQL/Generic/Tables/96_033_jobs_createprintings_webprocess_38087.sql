DECLARE @v_dbname VARCHAR(255),
		@v_jobname VARCHAR(255),
		@v_stepname VARCHAR(255)

SET @v_dbname = db_name()
SET @v_jobname = 'Create Printings Web Process'
SET @v_stepname = @v_dbname + ' execute tmwebprocess_copy_printings_from_titlelist'

USE msdb;

-- Check to see if SQL Server Agent is running
IF EXISTS (SELECT spid FROM master.dbo.sysprocesses WHERE program_name = N'SQLAgent - Generic Refresher')
BEGIN
	-- Check to see if the Update Statistics Job already exists
	IF NOT EXISTS (SELECT job_id FROM  msdb.dbo.sysjobs WHERE name = @v_jobname)
	BEGIN
		EXEC dbo.sp_add_job 
			@job_name = @v_jobname,
			@enabled=1;

		-- Check to see if the Schedule already exists
		IF NOT EXISTS (SELECT schedule_id FROM  msdb.dbo.sysschedules WHERE name = 'Every 15 minutes')
		BEGIN
			EXEC dbo.sp_add_schedule
				@schedule_name = 'Every 15 minutes',
				@freq_type = 4,
				@freq_interval = 1,
				@freq_recurrence_factor = 0,
				@freq_subday_type = 4,
				@freq_subday_interval = 15,
				@active_start_time = 0,
				@active_end_time = 235959;

			EXEC sp_attach_schedule
			   @job_name = @v_jobname,
			   @schedule_name = 'Every 15 minutes';
		END

		EXEC dbo.sp_add_jobserver @job_name = @v_jobname;
	END	
END

-- Check to see if the Job Step already exists
IF NOT EXISTS (SELECT step_id FROM  msdb.dbo.sysjobsteps WHERE step_name = @v_stepname)
BEGIN
	DECLARE @v_jobid UNIQUEIDENTIFIER

	SELECT @v_jobid = job_id
	FROM  msdb.dbo.sysjobs
	WHERE name = @v_jobname

	UPDATE msdb.dbo.sysjobsteps
	SET on_success_action = 3,
		on_fail_action = 3
	WHERE job_id = @v_jobid

	EXEC sp_add_jobstep 
		@job_name = @v_jobname,
		@database_name = @v_dbname,
		@step_name = @v_stepname,
		@subsystem = 'TSQL',
		@command = 'EXEC tmwebprocess_copy_printings_from_titlelist 1, 0, '''';',
		@on_success_action = 1,
		@on_fail_action = 2;
END

GO

--USE CLOUD
--GO