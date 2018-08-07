
IF OBJECT_ID('dbo.UpdFld_XVQ_QsiJob_ErrorStats') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_QsiJob_ErrorStats
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_QsiJob_ErrorStats
@i_qsijobkey		int,
@i_total_records	int,  -- total # in job
@o_summary_msg		varchar(255) output
AS
BEGIN

declare @abort_job int
declare @abort_rec int
declare @abort_grp int
declare @abort_fld int
declare @warn_fld  int
declare @info_fld  int

select	@abort_job = sum(case when messagetypecode = 5 then 1 else 0 end),
		@abort_rec = sum(case when messagetypecode = 2 and lower(messageshortdesc) = 'rejected record' then 1 else 0 end),
		@abort_grp = sum(case when messagetypecode = 2 and lower(messageshortdesc) = 'rejected group'  then 1 else 0 end),
		@abort_fld = sum(case when messagetypecode = 2 and lower(messageshortdesc) = 'rejected field'  then 1 else 0 end),
		@warn_fld  = sum(case when messagetypecode = 3 then 1 else 0 end),
		@info_fld  = sum(case when messagetypecode = 4 then 1 else 0 end)
from	qsijobmessages
where	qsijobkey = @i_qsijobkey

/*
set @o_summary_msg = 'Job Summary Totals - Input Records: ' + convert(varchar, isnull(@i_total_records,0)) +
                                ' / Rejections - Records: ' + convert(varchar, isnull(@abort_rec,0)) +
                                               ', Groups: ' + convert(varchar, isnull(@abort_grp,0)) +
                                               ', Fields: ' + convert(varchar, isnull(@abort_fld,0)) +
                                            ' / Warnings: ' + convert(varchar, isnull(@warn_fld,0))
*/
set @o_summary_msg = 'job summary totals - input records: ' + convert(varchar, isnull(@i_total_records,0)) +
                                     ', rejected records: ' + convert(varchar, isnull(@abort_rec,0)) +
                                      ', rejected groups: ' + convert(varchar, isnull(@abort_grp,0)) +
                                      ', rejected fields: ' + convert(varchar, isnull(@abort_fld,0)) +
                                             ', warnings: ' + convert(varchar, isnull(@warn_fld,0))

END
GO
