set nocount on
declare @v_date datetime

-- get the last complete run date 
select @v_date=max(rundate) from qweb_wh_log where runstatus like 'complete%'

-- by providing a date only titles updated after that date will be refreshed
exec qweb_wh_load 1,@v_date