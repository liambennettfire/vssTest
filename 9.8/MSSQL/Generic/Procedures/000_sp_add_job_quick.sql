USE [msdb]
GO

/****** Object:  StoredProcedure [dbo].[sp_add_job_quick]    Script Date: 9/19/2016 2:07:46 PM ******/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('sp_add_job_quick') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.sp_add_job_quick
END
GO

/****** Object:  StoredProcedure [dbo].[sp_add_job_quick]    Script Date: 9/19/2016 2:07:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create  procedure [dbo].[sp_add_job_quick] 
@job nvarchar(128),
@mycommand nvarchar(max), 
@servername nvarchar(28),
@startdate nvarchar(8),
@starttime nvarchar(8)
as
--Add a job
EXEC dbo.sp_add_job
    @job_name = @job ;
--Add a job step named process step. This step runs the stored procedure
EXEC sp_add_jobstep
    @job_name = @job,
    @step_name = N'Delete qsrpt_instance_item Table',
    @subsystem = N'TSQL',
    @command = @mycommand
--Schedule the job at a specified date and time
exec sp_add_jobschedule @job_name = @job,
@name = 'Delete qsrpt_instance_item Table',
@freq_type=4,
@freq_interval=1,
@active_start_date = @startdate,
@active_start_time = @starttime
-- Add the job to the SQL Server Server
EXEC dbo.sp_add_jobserver
    @job_name =  @job,
    @server_name = @servername
GO


