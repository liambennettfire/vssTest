
IF OBJECT_ID('dbo.UpdFld_XVQ_QsiJob_End') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_QsiJob_End
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_QsiJob_End
@i_qsijobkey		int,
@i_userid			varchar(30),
@i_aborted			int,            -- 1=aborted, 0=completed
@i_nonstandard_msg	varchar(4000),  -- should be non-null if @i_aborted=1; might also indicate no recs processed when @i_aborted=0
@i_total_records	int,            -- total records processed (null if didn't keep track)
@o_error_code		int output,
@o_error_desc		varchar(2000) output
AS
BEGIN

declare @job_is_already_running int

-- Check to see if this batch job is running
set @job_is_already_running = (SELECT COUNT(*) FROM qsijob WHERE qsijobkey = @i_qsijobkey AND statuscode = 1)
if @job_is_already_running = 0
begin
	set @o_error_code = -1
	set @o_error_desc = 'Unable to end the specified job because it is not running.'
	RETURN
end


declare @msg_stats   varchar(255)

EXEC dbo.UpdFld_XVQ_QsiJob_ErrorStats @i_qsijobkey, @i_total_records, @msg_stats output


declare @qsistatuscode int
declare @msg_long      varchar(4000)
declare @msg_short     varchar(255)

if @i_aborted = 1 begin
	set @qsistatuscode = 5
	set @msg_short = 'Aborted'
	set @msg_long = 'Job aborted - ' + @msg_stats
end
else begin
	set @qsistatuscode = 6
	set @msg_short = 'Completed'
	set @msg_long = 'Job completed - ' + @msg_stats
end

if @i_nonstandard_msg is not null
	set @msg_long = @msg_long + ' - ' + @i_nonstandard_msg


-- Write the job msg to qsijob tables
EXEC dbo.UpdFld_XVQ_QsiJob_WriteMessage @i_qsijobkey, @i_userid,
	0, 0, 0, @qsistatuscode, @msg_long, @msg_short, @o_error_code output, @o_error_desc output

if @o_error_code >= 0               -- if no error on writing qsi message,
	set @o_error_desc = @msg_long   -- pass the msg up the call stack for reporting elsewhere (e.g. in native log file)

END
GO
