drop function qweb_get_www_events
go

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE function [dbo].[qweb_get_www_events] (@i_bookkey int) 

RETURNS varchar(8000)
as
BEGIN

  DECLARE @v_event_text varchar (8000),
  @i_www_event_fetchstatus int,
  @v_all_events varchar (8000),
  @v_authorbylineprepro varchar (255)

  select @v_authorbylineprepro =commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = 
@i_bookkey	

  select @v_all_events = (isnull(@v_authorbylineprepro,'')) + 
  dbo.qweb_get_isbn (@i_bookkey,16) + ',' + ' ' + '$' + dbo.qweb_get_bestUSPrice (@i_bookkey,8) + ', ' + ' '+ 
  dbo.qweb_get_Format (@i_bookkey,'E') + '<BR><BR>' 
  from qweb_www_events_view	
			where bookkey=@i_bookkey
			and eventdate>=getdate()
			order by eventdate		
  

  DECLARE c_qweb_www_events CURSOR 
	FOR	 
	  select (CASE when eventdate is not null and edate is not null and eventdate<>edate then
	       '<B>' + cast (DATENAME (m, eventdate) as varchar) +'' + 
			cast (DATENAME (d, eventdate)as varchar) +','+ cast(DATEPART(yyyy, eventdate) as varchar) + 
	       '-' + cast(DATENAME(m, edate) as varchar) +' '+ cast(DATENAME(d, edate) as varchar) +', '+ cast(DATEPART(yyyy, edate) as varchar)+ '</B><BR>' ELSE '' end + 
	       CASE when eventdate is not null and (edate is null or edate=eventdate) then
	       '<B>' + cast(DATENAME(m, eventdate) as varchar) +' '+ cast(DATENAME(d, eventdate) as varchar) +', '+ cast(DATEPART(yyyy, eventdate) as varchar) + 
	       '</B><BR>' ELSE '' end +  
			CASE WHEN stime is not null and etime is not null 
			Then substring (Isnull(stime,''),12,8) + '-' + substring (isnull(etime,''),12,8) + '<BR>' ELSE '' END +
			CASE WHEN stime is not null and etime is null
			then substring (Isnull(stime,''),12,8) + '<BR>' ELSE '' END +
			CASE WHEN companyname is not null Then (isnull(companyname,'')) + '<BR>'  ELSE '' END + 
			CASE WHEN addressln1 is not null Then (isnull(addressln1,'')) + '<BR>' ELSE '' END + 
			CASE WHEN addressln2 is not null Then (isnull(addressln2,'')) + '<BR>'  ELSE '' END +
			CASE WHEN addressln3 is not null Then (isnull(addressln3,'')) + '<BR>'  ELSE '' END +
			CASE WHEN deptname is not null Then (isnull(deptname,'')) + '<BR>'  ELSE '' END +
			CASE WHEN city is not null then (isnull(city,'')) + ', ' ELSE '' END +
			CASE WHEN state is not null then (isnull(state,'')) + ' ' ELSE '' END + 
			CASE WHEN zip is not null then (isnull(zip,'')) + '<BR>' ELSE '' + '<BR>' END + 
			CASE WHEN eventnotes is not null then (isnull(eventnotes,'')) ELSE '' END + '<BR>')
			from qweb_www_events_view	
			where bookkey=@i_bookkey
			and eventdate>=getdate()
			order by eventdate	
			
	FOR READ ONLY
			
	OPEN c_qweb_www_events 

	FETCH NEXT FROM c_qweb_www_events 
		INTO @v_event_text

	select  @i_www_event_fetchstatus  = @@FETCH_STATUS

	 while (@i_www_event_fetchstatus >-1 )
		begin
		 IF (@i_www_event_fetchstatus <>-2) 
		 begin
			Select @v_all_events = ISNULL(@v_all_events,'') + ISNULL(@v_event_text,'') + '<BR>'
		 end
	 
	FETCH NEXT FROM c_qweb_www_events
		INTO @v_event_text
	        select  @i_www_event_fetchstatus  = @@FETCH_STATUS
		end

	close c_qweb_www_events
	deallocate c_qweb_www_events
   	
    If ltrim(rtrim(@v_all_events)) = '' 
	begin
		select @v_all_events = null
	end
	
	return '<DIV>' + @v_all_events + '</DIV>'
end