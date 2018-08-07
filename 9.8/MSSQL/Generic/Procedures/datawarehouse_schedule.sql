PRINT 'STORED PROCEDURE : dbo.datawarehouse_schedule'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_schedule') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_schedule
end

GO

create proc dbo.datawarehouse_schedule
@ware_bookkey int,@ware_printingkey int,
@ware_sched int,@ware_logkey int, @ware_warehousekey int, @ware_system_date datetime 
AS 

DECLARE @ware_count int
DECLARE @ware_dateline  int
DECLARE @estdate  datetime
DECLARE @actdate  datetime
DECLARE @bestdate  datetime
DECLARE @ware_role_long  varchar(40) 
DECLARE @i_elementtypecode int
DECLARE @d_estimatedate datetime
DECLARE @d_actualdate datetime
DECLARE @i_datetypecode int
DECLARE @i_duration int 
DECLARE @i_roletypecode  int 
DECLARE @i_contributorkey int 
DECLARE @c_displayname varchar(80) 
DECLARE @i_schedstatus int
DECLARE @c_tasknote varchar(255)

DECLARE @nc_sqlstring NVARCHAR(4000)
DECLARE @nc_sqlparameters NVARCHAR(4000)

DECLARE @c_userid varchar(30)
DECLARE @temp_actdate datetime

/*7-12-04 -CRM 01463 10 new schedule...change to execute immediate, only need 1 insert instead of 20*/
/*8-5-04 CRM 1666 : fix missing @ in @ware_count from dateline 6 to 40*/
/*8-11-04 change to sp_execute syntax*/

select @c_userid = 'WARE_STORED_PROC'

BEGIN tran
	set @nc_sqlstring = N' insert into whschedule' + convert (varchar (10),@ware_sched) +
	' (bookkey, printingkey, lastuserid, lastmaintdate) VALUES (@ware_bookkey, @ware_printingkey, @c_userid , @ware_system_date)'
		 
	set @nc_sqlparameters = '@ware_bookkey INT, @ware_printingkey INT, @c_userid  varchar (30),@ware_system_date datetime'

	EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_bookkey,@ware_printingkey,@c_userid ,@ware_system_date

commit tran

DECLARE warehousesched INSENSITIVE CURSOR
FOR

 SELECT ELEMENT.ELEMENTTYPECODE, TASK.ESTIMATEDDATE,
         TASK.ACTUALDATE, TASK.DATETYPECODE,TASK.DURATION,
		TASK.ROLETYPECODE,TASK.CONTRIBUTORKEY,
		PERSON.DISPLAYNAME,TASK.TASKNOTE
		    FROM  BOOKELEMENT, ELEMENT , 
         		 WHCSCHEDULETYPE , TASK 

	LEFT OUTER JOIN person ON task.contributorkey = person.contributorkey  
	 where ( BOOKELEMENT.ELEMENTKEY = ELEMENT.ELEMENTKEY ) and
         ( ELEMENT.ELEMENTKEY = TASK.ELEMENTKEY) and
	 ( ELEMENT.ELEMENTTYPECODE = WHCSCHEDULETYPE.SCHEDULETYPECODE) and
         ( BOOKELEMENT.bookkey = @ware_bookkey ) AND
         ( BOOKELEMENT.printingkey = @ware_printingkey ) and
	   (WHCSCHEDULETYPE.linenumber = @ware_sched)


FOR READ ONLY

OPEN warehousesched

FETCH NEXT FROM warehousesched
INTO @i_elementtypecode,@d_estimatedate,@d_actualdate,
@i_datetypecode,@i_duration,@i_roletypecode,@i_contributorkey,
@c_displayname,@c_tasknote

select @i_schedstatus= @@FETCH_STATUS

 while (@i_schedstatus<>-1 )
   begin
	IF (@i_schedstatus<>-2)
	  begin
			select @estdate = @d_estimatedate
			select @actdate = @d_actualdate
			select @temp_actdate = @d_actualdate
			select @ware_dateline = 0

			if @temp_actdate is null
			  begin
				select @bestdate = @estdate
			  end
			else
		  	  begin
				select @bestdate = @actdate
			  end

		 	if @i_roletypecode is null
			  begin
				select @i_roletypecode = 0
			  end
			if @i_roletypecode > 0
			  begin
				exec gentables_longdesc 285,@i_roletypecode, @ware_role_long OUTPUT
			  end
			else
			  begin	
				select @ware_role_long = ''
			  end

/*  change select of 20 individual whschedule to 1 sp_Execute syntax */
			select @ware_count = 0
			set @nc_sqlstring = N' select @ware_count = count(*)
				from whcschedule' + convert (varchar (10),@ware_sched) +
					' where scheduledatetype = @i_datetypecode'

			EXEC sp_executesql @nc_sqlstring,
		 	 N'@ware_count INT OUTPUT,@i_datetypecode INT', 
		  	@ware_count OUTPUT, @i_datetypecode
		
			if  @ware_count >0 
			  begin
				select @ware_dateline = 0

				 set @nc_sqlstring = N' select @ware_dateline = linenumber from whcschedule' + convert (varchar (10),@ware_sched) +
					' where scheduledatetype = @i_datetypecode'

				EXEC sp_executesql @nc_sqlstring,
		 		 N'@ware_dateline INT OUTPUT,@i_datetypecode INT', 
		  		@ware_dateline OUTPUT, @i_datetypecode

			 end

/*  change update of 40 individual columns per schedule to 1 sp_Execute syntax */

		if  @ware_dateline  > 0  and @ware_dateline < 41
		  begin

	BEGIN tran

			set @nc_sqlstring = N' update whschedule' + convert (varchar (10),@ware_sched) +  ' set estdate' + 
			   convert (varchar (10),@ware_dateline) + '= @estdate, ' + 'actualdate' +
			   convert (varchar (10),@ware_dateline) + '= @actdate, ' +
			  'bestdate' + convert (varchar (10),@ware_dateline) + '= @bestdate, ' +
			  'assignedperson' + convert (varchar (10),@ware_dateline) + '= @c_displayname, ' +
			  'role' + convert (varchar (10),@ware_dateline) + '= @ware_role_long, ' +
			  'duration' + convert (varchar (10),@ware_dateline) + '= @i_duration, ' +
			  'tasknote' + convert (varchar (10),@ware_dateline) + '= @c_tasknote' + 
			  ' where bookkey= @ware_bookkey and printingkey = @ware_printingkey'
				
			set @nc_sqlparameters = '@ware_bookkey INT, @ware_printingkey INT, @estdate datetime,
				 @actdate datetime,@bestdate datetime,@c_displayname varchar(80), @ware_role_long varchar(40),
				 @i_duration INT,@c_tasknote varchar(255)'

			EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_bookkey, @ware_printingkey,
 				@estdate,@actdate,@bestdate,@c_displayname, @ware_role_long,@i_duration,@c_tasknote
	commit tran
	
		if @@ERROR <> 0 
		  begin
		BEGIN tran
			INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
      			    errorseverity, errorfunction,lastuserid, lastmaintdate)
			 VALUES (convert(varchar (10), @ware_logkey)  ,convert(varchar (10),@ware_warehousekey),
			'Unable to insert whschedule' + convert(varchar (10),@ware_sched) + ' table - for book element',
			('Warning/data error bookkey '+ convert(varchar (10),@ware_bookkey)),
			'Stored procedure datawarehouse_schedule','WARE_STORED_PROC', @ware_system_date)
		commit tran
		end

	end
   end

	FETCH NEXT FROM warehousesched
	INTO @i_elementtypecode,@d_estimatedate,@d_actualdate,
	@i_datetypecode,@i_duration,@i_roletypecode,@i_contributorkey,
	@c_displayname,@c_tasknote

	select @i_schedstatus= @@FETCH_STATUS
end

close warehousesched
deallocate warehousesched


GO


