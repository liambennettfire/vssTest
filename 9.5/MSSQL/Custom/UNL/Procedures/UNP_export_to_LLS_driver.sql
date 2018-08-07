/****** Object:  StoredProcedure [dbo].[UNP_export_to_LLS_driver]    Script Date: 03/08/2010 11:01:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UNP_export_to_LLS_driver]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[UNP_export_to_LLS_driver]
GO

USE [PSS5]
GO

/****** Object:  StoredProcedure [dbo].[UNP_export_to_LLS_driver]    Script Date: 03/08/2010 11:01:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[UNP_export_to_LLS_driver] @i_jobtypecode int, @i_jobtypesubcode int


AS
BEGIN

-- jobtype 2,1 = new title feed
-- jobtype 2,2 = change feed

declare     @v_error  INT,
	@v_rowcount INT,
	@start_datetime	datetime,
	@prevstart_datetime		datetime,
	@i_bookkey			int,
	@numrows			int,
	@counter			int,
	@userid				varchar(30),
	@o_error_code   integer ,
	@o_error_desc   varchar(2000),
	@qsibatchkey		int,
	@qsijobkey			int,
	@count				int


SET @o_error_code = 0
SET @o_error_desc = ''  
set @userid = 'LLS_Feed'

SET NOCOUNT ON

set @qsibatchkey = null
set @qsijobkey = null


select @count = count(*)
from qsijob q
where jobtypecode = @i_jobtypecode
and statuscode = @i_jobtypesubcode

if @count > 0 begin
	exec write_qsijobmessage @qsibatchkey output, @qsijobkey output, @i_jobtypecode,@i_jobtypesubcode,null,null,'QSIADMIN',0,0,0,1,'job started','started',@o_error_code output, @o_error_desc output
	if @o_error_code = 1 begin
		set @o_error_code = 0
	end
	set @o_error_code = -1
	set @o_error_desc = 'There is a qsijob record indicating this job is running.  Job will not run again until previous job completes or qsijob record is cleaned up.  (jobtypecode = 2, statuscode = 3)'
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, @i_jobtypecode,@i_jobtypesubcode,null,null,'QSIADMIN',0,0,0,5,@o_error_desc,'error',@o_error_code output, @o_error_desc output
	RETURN
end

exec write_qsijobmessage @qsibatchkey output, @qsijobkey output, @i_jobtypecode,@i_jobtypesubcode,null,null,'QSIADMIN',0,0,0,1,'job started','started',@o_error_code output, @o_error_desc output
if @o_error_code = 1 begin
	set @o_error_code = 0
end


--pulling data from just after the previous start time to this run's start time.  this will ignore records written
--after this job begins but will possibly fall before this run's enddatetime.  Next run will pick up those records.
set @prevstart_datetime = null

select @prevstart_datetime = isnull(max(startdatetime),'11/1/2009')
from qsijob
where jobtypecode = @i_jobtypecode
and  jobtypesubcode = @i_jobtypesubcode
and statuscode = 3
and qsijobkey <> @qsijobkey
and qsibatchkey <> @qsibatchkey


select @start_datetime = startdatetime
from qsijob where jobtypecode = @i_jobtypecode
and jobtypesubcode = @i_jobtypesubcode
and qsijobkey = @qsijobkey
and qsibatchkey = @qsibatchkey

create table #tmp_bookkeys
(bookkey		int		not null,
seqnum int identity (1,1))


-- jobtype 2,2 = change feed
If @i_jobtypecode = 2 and @i_jobtypesubcode = 2
begin
	insert into #tmp_bookkeys (bookkey)
	Select bookkey from book 
	where (bookkey in (Select distinct bookkey from titlehistory where lastmaintdate > @prevstart_datetime and columnkey in (1,3,41,90,260,45,10,11,4,23,50,84,55))
	   or bookkey in (Select bookkey from titlehistory where lastmaintdate > @prevstart_datetime and columnkey = 226 and fielddesc IN ('Original Unit Cost est.','Current Reprint Unit Cost est.')) -- added 1/8/10 - was using just column key 226 that was bringing in all bookmisc float changes
	   or bookkey in (Select bookkey from titlehistory where lastmaintdate > @prevstart_datetime and columnkey = 248 and fielddesc = 'Major Discipline') -- added 1/8/10 - was using just column key 226 that was bringing in all bookmisc float changes
	   or bookkey in (Select bookkey from titlehistory where lastmaintdate > @prevstart_datetime and columnkey = 66 and currentstringvalue like '%Acquisition Editor%') -- added 3/8/10 - just pull Acq Ed
	   or bookkey in (Select bookkey from titlehistory where columnkey = 9 and currentstringvalue like '%USDL%' and fielddesc like '%Retail%' and  lastmaintdate >= @prevstart_datetime)
	   or bookkey in (Select bookkey from datehistory where lastmaintdate > @prevstart_datetime and datetypecode in (8))
	   or bookkey in (Select bookkey from datehistory where lastmaintdate > @prevstart_datetime and datetypecode in (47) and datestagecode=2)
	   or bookkey in (Select bookkey from booksubjectcategory where categorytableid = 413 and lastmaintdate > @prevstart_datetime)
	     )
		
	and bookkey not in (Select bookkey from bookdetail where mediatypecode = 6) -- exclude journals
	and bookkey not in (Select bookkey from bookdetail where mediatypecode = 2 and mediatypesubcode = 20001) -- exclude ebooks
	and bookkey not in (Select bookkey from bookmisc where misckey = 39 and longvalue = 2) -- LL Status = 'Do Not Send'
	and bookkey not in (Select bookkey from book where creationdate > @prevstart_datetime)
	and ((bookkey in (Select bookkey from titlehistory where columnkey = 200 and currentstringvalue = 'Title Verified (Complete)') -- titleverified at some point
		and bookkey not in (Select bookkey from bookdetail where bisacstatuscode = 4))
    or (bookkey in (Select bookkey from titlehistory where columnkey = 200 and currentstringvalue = 'Title Verified (Complete)') -- titleverified at some point
		and bookkey in (Select bookkey from bookdetail where bisacstatuscode = 4)))    

print 'Title Change Feed'
print '@prevstart_datetime'
print @prevstart_datetime

end

-- jobtype 2,1 = new title feed
If @i_jobtypecode = 2 and @i_jobtypesubcode = 1
begin
	insert into #tmp_bookkeys (bookkey)
		Select bookkey from book b 
		where bookkey in (Select bookkey from titlehistory where columnkey = 200 and lastmaintdate > @prevstart_datetime and currentstringvalue = 'Title Verified (Complete)')
		and bookkey not in (Select bookkey from bookdetail where mediatypecode = 6) -- exclude journals
		and bookkey not in (Select bookkey from bookdetail where mediatypecode = 2 and mediatypesubcode = 20001) -- exclude ebooks
		or (bookkey in (Select referencekey1 from qsijobmessages m, qsijob j 
						where m.qsijobkey = j.qsijobkey 
						and messagetypecode = 4
						and j.jobtypecode = 2
						and j.jobtypesubcode = 1)
			and not exists (Select *  from bookmisc where bookmisc.bookkey = b.bookkey and misckey = 39 and longvalue = 1))




print 'New Title Feed'
print '@prevstart_datetime'
print @prevstart_datetime

end


truncate table unp_export_to_LLS

select @numrows = count(*)
from #tmp_bookkeys 

if @numrows is null or @numrows = 0
begin
	SET @o_error_desc = 'There are no changes to process.'
	exec write_qsijobmessage @qsibatchkey, @qsijobkey, @i_jobtypecode,@i_jobtypesubcode,null,null,'QSIADMIN',0,0,0,6,'job completed - There are no changes to process','completed',@o_error_code output, @o_error_desc output
	RETURN
end

set @counter = 1

while @counter <= @numrows
begin
--	select @prevstart_datetime = isnull(activedate,@prevstart_datetime)
--	from bookdates bd
--	where bookkey = @minbookkey
--	and datetypecode = 20004

    

	Select @i_bookkey  = bookkey from #tmp_bookkeys where seqnum = @counter

	exec [UNP_export_to_LLS_detail] @i_bookkey, @userid, @prevstart_datetime, @start_datetime, @i_jobtypecode, @i_jobtypesubcode, @o_error_code output, @o_error_desc output
	set @v_error = @@ERROR
	IF @o_error_code = -1 BEGIN
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, @i_jobtypecode,@i_jobtypesubcode,null,null,'QSIADMIN',@i_bookkey,0,0,5,@o_error_desc,null,@o_error_code output, @o_error_desc output
		RETURN
	END    

	IF @v_error <> 0 BEGIN
		set @o_error_code = -1
		set @o_error_desc = 'Error executing export to LLS detail procedure.  Error #' + cast(@v_error as varchar(20))
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, @i_jobtypecode,@i_jobtypesubcode,null,null,'QSIADMIN',@i_bookkey,0,0,5,@o_error_desc,null,@o_error_code output, @o_error_desc output
		RETURN
	END    

	--error code if record was not written for bookkey, write msg and continue with other bookkeys	
	if @o_error_code = 1 begin	
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, @i_jobtypecode,@i_jobtypesubcode,null,null,'QSIADMIN',@i_bookkey,0,0,4,@o_error_desc,null,@o_error_code output, @o_error_desc output
	end

	-- row sent successfully, update Long Leaf Status to Sent
	If @o_error_code = 0 and not exists (Select * from bookmisc where misckey = 39 and bookkey = @i_bookkey)
	begin
		insert into bookmisc (bookkey, misckey, longvalue, lastuserid, lastmaintdate)
		Select @i_bookkey, 39, 1, 'fbt_lls_feed', getdate()
	end
	else if @o_error_code = 0 and exists (Select * from bookmisc where misckey = 39 and bookkey = @i_bookkey)
	begin
		update bookmisc 
		set longvalue = 1,
			lastmaintdate = getdate(),
			lastuserid = 'fbt_lls_feed'
		where misckey = 39
		  and bookkey = @i_bookkey
	end

set @counter = @counter + 1
	end



exec write_qsijobmessage @qsibatchkey, @qsijobkey, @i_jobtypecode,@i_jobtypesubcode,null,null,'QSIADMIN',0,0,0,6,'job completed','completed',@o_error_code output, @o_error_desc output



END
GO


