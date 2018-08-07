
IF OBJECT_ID('dbo.UpdFld_XVQ_QsiJob_Start') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_QsiJob_Start
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_QsiJob_Start
@i_externalcode		varchar(30),  -- Identifier of interface or qsi job in gentables tableid=543, or null if specifying @i_jobtypecode
@i_jobtypecode		int,          -- Alternative id to @i_externalcode parameter if externalcode is null or non-unique
@i_jobtypesubcode	int,
@i_userid			varchar(30),
@o_qsijobkey		int output,
@o_error_code		int output,
@o_error_desc		varchar(2000) output
AS
BEGIN

declare @v_jobdesc varchar(2000)

if @i_externalcode is not null
begin
	SELECT @i_jobtypecode = datacode,
		   @v_jobdesc     = datadesc
	FROM   gentables
	WHERE  tableid = 543 and externalcode = @i_externalcode

	-- if not found, look for @externalcode in subgentables
	if @i_jobtypecode is null
	begin
		SELECT @i_jobtypecode    = datacode,
			   @i_jobtypesubcode = datasubcode
		FROM   subgentables
		WHERE  tableid = 543 and externalcode = @i_externalcode

		SELECT @v_jobdesc = datadesc
		FROM   gentables
		WHERE  tableid = 543 and datacode = @i_jobtypecode
	end
end
else if @i_jobtypecode is null begin
	set @o_error_code = -1
	set @o_error_desc = 'Job identifier not specified.'
	RETURN
end
else begin
	SELECT @v_jobdesc = datadesc
	FROM   gentables
	WHERE  tableid = 543 and datacode = @i_jobtypecode
end



-- This handling for unspecified jobtypesubcode is not as generic as it should be but write_qsijobmessage sproc needs
-- to have it specified, so default to this (delta-feed, instead of full-feed=1)
if isnull(@i_jobtypesubcode, 0) = 0
	set @i_jobtypesubcode = 2

-- Check to see if an instance of this batch job is already running
declare @job_is_already_running int
set @job_is_already_running = ( SELECT COUNT(*)
                                FROM   qsijob
                                WHERE  jobtypecode = @i_jobtypecode
                                  AND  jobtypesubcode = @i_jobtypesubcode
                                  AND  statuscode = 1 )

declare @qsijobkey   int
declare @qsibatchkey int

-- Write the job start msg to qsijobmessage tables, and get this job's assigned qsijobkey and qsibatchkey
EXEC write_qsijobmessage @qsibatchkey output, @qsijobkey output, @i_jobtypecode, @i_jobtypesubcode, @v_jobdesc, null, @i_userid,
	0, 0, 0, 1, 'job started', 'started', @o_error_code output, @o_error_desc output

if @o_error_code < 0
	RETURN
set @o_error_code = 0     -- write_qsijobmessage sets @o_error_code=1 on success, but we want success=0
set @o_error_desc = null  -- write_qsijobmessage sets @o_error_desc='' on success, but we want success=null

-- Now that we've registered the start of this job instance, if another instance of the job
-- was already running, then write abort message and abort.
if @job_is_already_running <> 0
begin
	EXEC write_qsijobmessage @qsibatchkey, @qsijobkey, @i_jobtypecode, @i_jobtypesubcode, @v_jobdesc, null, @i_userid,
		0, 0, 0, 5,
		'There is a qsijob record indicating this job is running.  Job will not run again until previous job completes or qsijob record is cleaned up.',
		null, @o_error_code output, @o_error_desc output

	if @o_error_code > 0 begin
		set @o_error_code = 1
		set @o_error_desc = 'Aborted job-start due to this job already running.'
	end
end

set @o_qsijobkey = @qsijobkey

END
GO
