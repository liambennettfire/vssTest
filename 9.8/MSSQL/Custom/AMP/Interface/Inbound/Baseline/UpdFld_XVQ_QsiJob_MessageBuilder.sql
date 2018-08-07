
IF OBJECT_ID('dbo.UpdFld_XVQ_QsiJob_MessageBuilder') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_QsiJob_MessageBuilder
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_QsiJob_MessageBuilder
@i_effect_code         int,                  -- input:  standardized scope/effect codes for UpdFld_XVQ_XXXX() exceptions
@i_qsijob_msg_suffix   varchar(2000),        -- input:  additional info to append to end of standard UpdFld_XVQ_XXXX msg content
@i_jobrec_id           varchar(255),         -- input:  job-specific identifier of job input record, not to be confused with bookkey
@i_datadesc            varchar(120),         -- input:  description of data item (e.g. from gentables), or if unavailable, target column name
@i_data                varchar(255),         -- input:  text representation of the data itself that constructed msg refers to
@o_qsijob_msgtype_code int output,           -- output: UpdFld_XVQ_XXXX scope/effect code mapped to qsijob messagetypecode
@o_qsijob_long_msg     varchar(4000) output, -- output: constructed qsijobmessages messagelongdesc value
@o_qsijob_short_msg    varchar(30) output    -- output: UpdFld_XVQ_XXXX-standardized qsijobmessages messageshortdesc value

-- Additional parameter notes:
--   @i_jobrec_id - Normally ISBN# or some other raw input data identifier, but can be null; bookkey is not normally
--                  used because it's an internal identifier and already placed in qsijobmessages table's record.
AS
BEGIN

declare @qsijob_msg          varchar(4000)  -- used to construct the qsijobmessages messagelongdesc value
declare @qsijob_msg_prefix   varchar(30)


set @o_qsijob_msgtype_code = case @i_effect_code
								when 1 then 5   -- abort job    --> qsijob abort
								when 2 then 2   -- abort record --> qsijob error
								when 3 then 2   -- abort group  --> qsijob error
								when 4 then 2   -- abort field  --> qsijob error
								when 5 then 3   -- write field  --> qsijob warning
								when 6 then 4   -- write field  --> qsijob information
								else        null
							end

set @o_qsijob_short_msg =	case @i_effect_code
								when 1 then 'fatal error'      -- abort job    --> qsijob abort
								when 2 then 'rejected record'  -- abort record --> qsijob error
								when 3 then 'rejected group'   -- abort group  --> qsijob error
								when 4 then 'rejected field'   -- abort field  --> qsijob error
								when 5 then 'warning'          -- write field  --> qsijob warning
								when 6 then 'information'      -- write field  --> qsijob information
								else        null
							end

set @qsijob_msg_prefix =	case @i_effect_code
								when 1 then 'Fatal error during or'   -- abort job    --> qsijob abort
								when 2 then 'Record rejection error'  -- abort record --> qsijob error
								when 3 then 'Field group rejection error' -- abort group  --> qsijob error
								when 4 then 'Field rejection error'   -- abort field  --> qsijob error
								when 5 then 'Warning'                 -- write field  --> qsijob warning
								when 6 then 'Information'             -- write field  --> qsijob information
								else        null
							end

set @qsijob_msg = @qsijob_msg_prefix + ' on job record identifier ' + isnull(@i_jobrec_id, '<null>')
if @i_effect_code in (1,2,3,4) AND @i_qsijob_msg_suffix is null
	set @qsijob_msg = @qsijob_msg + ' : invalid ' + isnull(@i_datadesc,'data') + ' (' + isnull(@i_data,'') + ')'
else begin
	-- NB: pre-rejection cases will have empty @i_data, so caller should put it in @i_qsijob_msg_suffix - better remedy when have time?
	set @qsijob_msg = @qsijob_msg + ', field ' + isnull(@i_datadesc,'data') + ' (' + isnull(@i_data,'') + ')'

	if @i_qsijob_msg_suffix is not null
		set @qsijob_msg = @qsijob_msg + ' : ' + @i_qsijob_msg_suffix
end

/*
set @qsijob_msg = @qsijob_msg_prefix + ' on job record identifier ' + isnull(@i_jobrec_id, '<null>')
if @i_effect_code in (1,2,3,4) AND @qsijob_msg_suffix is null
	set @qsijob_msg = @qsijob_msg + ' : invalid'
else
	set @qsijob_msg = @qsijob_msg + ', field'
set @qsijob_msg = @qsijob_msg + ' ' + @i_datadesc + ' (' + @i_data + ')'
if @qsijob_msg_suffix is not null
	set @qsijob_msg = @qsijob_msg + ' : ' + @qsijob_msg_suffix
*/

set @o_qsijob_long_msg = @qsijob_msg

END
GO
