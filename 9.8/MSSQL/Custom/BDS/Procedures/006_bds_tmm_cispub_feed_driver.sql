IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bds_tmm_cispub_feed_driver]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[bds_tmm_cispub_feed_driver]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[bds_tmm_cispub_feed_driver]
AS

BEGIN
declare 
@numrows			int,
@minsort			int,
@rownum			int,
@numcols			int,
@minbookkey		int,
@v_qsibatchkey		int,
@v_qsijobkey			int,
@o_error_code			int,
@o_error_desc			varchar(300),
@error_var				int,
@rowcount_var		int,
@bookkey				int, 
@v_count				int, 
@v_count2				int,
@v_userid 				varchar(30),
@maxlength				int,
@counter				int, 
@messagelongdesc	varchar(200),
@prevstart_datetime datetime,
@start_datetime		datetime,
@v_error		int

set @maxlength = 4000
set @v_qsibatchkey = null
set @v_qsijobkey = null
SET @o_error_code = 0
SET @o_error_desc = ''
SET @v_userid = 'TMM_TO_CISPUB'
SET @v_count = 0
SET @v_count2 = 0

---TMM to CIS Pub
select @v_count = count(*)
   from qsijob q
 where jobtypecode = 3
     and statuscode = 1

print '@v_count'
print @v_count

IF @v_count > 0 
BEGIN
	EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, 3,0,null,null,'QSIADMIN',0,0,0,1,'job started','started',@o_error_code output, @o_error_desc output
print '@v_qsijobkey'
print @v_qsijobkey
	IF @o_error_code = 1
		 BEGIN
			SET @o_error_code = 0
		 END
		SET @o_error_code = -1
		SET @o_error_desc = 'There is a qsijob record indicating this job is running. Job will not run again until previous job completes or qsijob record is cleaned up. (jobtype =3, statuscode = 3)'
		EXEC write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, 3,0,null,null,'QSIADMIN',0,0,0,5,@o_error_desc,'error',@o_error_code output, @o_error_desc output
		RETURN
END 

exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, 3,0,null,null,'QSIADMIN',0,0,0,1,'job started','started',@o_error_code output, @o_error_desc output 
IF @o_error_code = 1
    BEGIN
		SET @o_error_code = 0
    END
print '@v_qsibatchkey'
print @v_qsibatchkey
print '@v_qsijobkey'
print @v_qsijobkey

--pulling data from just after the previous start time to this run's start time.
set @prevstart_datetime = null
select @prevstart_datetime = isnull(max(startdatetime),'01/01/2001')
  from qsijob
 where jobtypecode = 3
    and statuscode = 3
    and qsijobkey <> @v_qsijobkey
    and qsibatchkey <> @v_qsibatchkey
print '@prevstart_datetime'
print  cast(@prevstart_datetime as varchar)

select @start_datetime = startdatetime
   from qsijob
  where jobtypecode = 3
       and qsijobkey = @v_qsijobkey
    and qsibatchkey = @v_qsibatchkey

print '@start_datetime'
print  cast(@start_datetime as varchar)

create table #tmp_bookkey (bookkey int not null)

insert into #tmp_bookkey
select th.bookkey 
from titlehistory th, isbn i
where columnkey in (248,89,39,9,10,11,3,1,23,4,90,248,43,45,104,57,58,40,261,8,96,89,22,21,214,16,235,38,39,34,75,220,221,225,227)
and th.lastmaintdate between cast(@prevstart_datetime as varchar) and cast(@start_datetime as varchar) and i.ean13 is not null and i.bookkey = th.bookkey

insert into #tmp_bookkey
select dh.bookkey 
from datehistory dh, isbn i
where datetypecode in (8,47)
and dh.lastmaintdate between cast(@prevstart_datetime as varchar) and cast(@start_datetime as varchar) and i.ean13 is not null and i.bookkey = dh.bookkey

select @minbookkey = min(bookkey), @numrows = count(distinct bookkey)
from #tmp_bookkey
---print '@numrows'
--print @numrows
IF @numrows is null or @numrows = 0
 begin
 	SET @o_error_desc = 'There are no changes to process.'
	exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, 3,0,null,null,'QSIADMIN',0,0,0,6,'job completed - There are no changes to process','completed',@o_error_code output, @o_error_desc output 
	RETURN
end
 	
set @counter = 1

IF @counter > 0
BEGIN
    SELECT @v_count = 0
	SELECT @v_count = count(*)
      FROM  bds_tmm_cispub_feed
	IF @v_count > 0
    BEGIN
      DELETE FROM bds_tmm_cispub_feed
    END
END

while @counter <= @numrows
begin
	exec bds_tmm_cispub_feed_detail @minbookkey,@o_error_code output, @o_error_desc output
 	set @v_error = @@ERROR
	IF @o_error_code = -1 BEGIN
		exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, 3,0,null,null,'QSIADMIN',@minbookkey,0,0,5,@o_error_desc,null,@o_error_code output, @o_error_desc output 
		RETURN
	end
	IF @v_error <> 0 BEGIN
		set @o_error_code = -1
         set @o_error_desc = 'Error executing tmm to cispub interface feed detail procedure. Error #' + cast(@v_error as varchar(20)) 
 		exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, 3,0,null,null,'QSIADMIN',@minbookkey,0,0,5,@o_error_desc,null,@o_error_code output, @o_error_desc output 
		RETURN
	END
    IF @o_error_desc = 1 begin --error code if record was not written for bookkey, write msg and continue with other bookkey
		exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, 3,0,null,null,'QSIADMIN',@minbookkey,0,0,4,@o_error_desc,null,@o_error_code output, @o_error_desc output 
	END
 	select @minbookkey = min(bookkey)
		from #tmp_bookkey
        where bookkey > @minbookkey
 	set @counter = @counter + 1
END 

exec write_qsijobmessage @v_qsibatchkey output, @v_qsijobkey output, 3,0,null,null,'QSIADMIN',0,0,0,6,'job completed','completed',@o_error_code output, @o_error_desc output 

END

SET NOCOUNT OFF









