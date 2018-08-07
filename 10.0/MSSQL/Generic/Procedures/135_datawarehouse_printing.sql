PRINT 'STORED PROCEDURE : dbo.datawarehouse_printing'
GO


if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_printing') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_printing 
end

GO

create proc dbo.datawarehouse_printing
@ware_bookkey int,@ware_illuspapchgcode int,@ware_textpapchgcode int,
@ware_logkey int, @ware_warehousekey int, @ware_system_date datetime 
AS 

DECLARE @ware_count int
DECLARE @ware_printingnum int 
DECLARE @ware_actbbdate  datetime
DECLARE @ware_estbbdate datetime
DECLARE @ware_requeststatus_long varchar(40) 
DECLARE @ware_printingstatus_long varchar(40) 
DECLARE @ware_notes  varchar(2000) 
DECLARE @ware_cartonqty int
DECLARE @ware_prepackind varchar(1)
DECLARE @ware_totaleditioncost  float
DECLARE @ware_totalplantcost float
DECLARE @ware_totalunitcost float
DECLARE @i_printingkey int
DECLARE @i_tentativeqty int
DECLARE @i_notekey int
DECLARE @i_printingnum int
DECLARE @i_statuscode int
DECLARE @c_ccestatus varchar(5)
DECLARE @d_dateccefinalized datetime
DECLARE @c_requestbatchid varchar(30)
DECLARE @d_approvedondate datetime
DECLARE @i_requeststatuscode int
DECLARE @c_requestcomment varchar(255)
DECLARE @c_requestid varchar(30)
DECLARE @c_requestbyname varchar(100)
DECLARE @d_requestdatetime datetime
DECLARE @i_approvedqty int
DECLARE @i_bookbulk float
DECLARE @i_pceqty1 int
DECLARE @i_pceqty2 int
DECLARE @i_printstatus int
DECLARE @c_impressionnumber varchar(10)
DECLARE @i_qtyreceived int
DECLARE @d_printingcloseddate datetime
DECLARE @c_jobnumberalpha VARCHAR(7)
DECLARE @c_boardtrimsizewidth VARCHAR(10)
DECLARE @c_boardtrimsizelength VARCHAR(10)
DECLARE @v_webscheduling  TINYINT

DECLARE warehouseprinting INSENSITIVE CURSOR
FOR
	SELECT  printingkey,tentativeqty,notekey, printingnum, statuscode,
         ccestatus,dateccefinalized,requestbatchid,approvedondate,
         requeststatuscode,requestcomment,requestid, requestbyname,
         requestdatetime, approvedqty, bookbulk,pceqty1,pceqty2,
	 impressionnumber,qtyreceived,printingcloseddate,
	 jobnumberalpha, boardtrimsizewidth, boardtrimsizelength
  		  FROM printing
			WHERE bookkey = @ware_bookkey
				AND printingkey > 0

FOR READ ONLY

/* Check the client option for Use Web Title Scheduling */
DECLARE option_cur CURSOR FOR
  SELECT optionvalue
  FROM clientoptions
  WHERE lower(optionname) = 'Use Web Title Scheduling'

OPEN option_cur 	
FETCH NEXT FROM option_cur INTO @v_webscheduling 

IF @@FETCH_STATUS < 0  /*option_cur%NOTFOUND */
  SET @v_webscheduling  = 0 

CLOSE option_cur 
DEALLOCATE option_cur 

OPEN warehouseprinting

FETCH NEXT FROM warehouseprinting
INTO @i_printingkey,@i_tentativeqty,@i_notekey,@i_printingnum,@i_statuscode,@c_ccestatus,
	@d_dateccefinalized,@c_requestbatchid,@d_approvedondate,@i_requeststatuscode,@c_requestcomment,
	@c_requestid,@c_requestbyname,@d_requestdatetime,@i_approvedqty,@i_bookbulk,@i_pceqty1,@i_pceqty2,
	@c_impressionnumber,@i_qtyreceived,@d_printingcloseddate, @c_jobnumberalpha, @c_boardtrimsizewidth,
	@c_boardtrimsizelength

select @i_printstatus = @@FETCH_STATUS

if @i_printstatus <> 0 /** NO PRINTING **/
    begin
BEGIN tran
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
     	   		 errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'No Printing rows for this title,  inserting blanks in whprinting table',
			('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)),
			'Stored procedure datawarehouse_printing','WARE_STORED_PROC',@ware_system_date)

		INSERT into whprinting
			(bookkey, printingkey,lastuserid,lastmaintdate)
		VALUES (@ware_bookkey,1,'WARE_STORED_PROC',@ware_system_date)
commit tran
close warehouseprinting
deallocate warehouseprinting
	RETURN
   end
 while (@i_printstatus<>-1 )
   begin

	IF (@i_printstatus<>-2)
	  begin

	if @i_requeststatuscode is null
	  begin
		select @i_requeststatuscode = 0
	  end	
 	if @i_statuscode is null
	  begin
		select @i_statuscode = 0
	  end	

	if @i_requeststatuscode > 0 
	  begin
		exec gentables_longdesc 375,@i_requeststatuscode,@ware_requeststatus_long  OUTPUT
	  end
	else
	  begin
		select @ware_requeststatus_long = ''
	end 

	if  @i_statuscode > 0 
	  begin
		exec gentables_longdesc 64,@i_statuscode,@ware_printingstatus_long OUTPUT
	  end
	else
	  begin
		select @ware_printingstatus_long = ''
	 end

/* bound book dates specific to printingkey*/
	select @ware_count = 0
	SELECT @ware_count = count(*)
   		FROM BOOKDATES
   			WHERE  bookkey = @ware_bookkey
				AND  printingkey = @i_printingkey
				AND  datetypecode = 30 
	if @ware_count > 0 
	  begin
  		SELECT @ware_actbbdate = ACTIVEDATE,@ware_estbbdate = ESTDATE
	   		FROM BOOKDATES
   				WHERE  bookkey = @ware_bookkey
					AND  printingkey = @i_printingkey
					AND  datetypecode = 30 
		if @ware_estbbdate is null
		  begin
			select @ware_estbbdate = ''
		  end
		if @ware_actbbdate is null
		  begin
			select @ware_actbbdate = ''
		  end
		if datalength(@ware_estbbdate) > 0
		  begin
			select @ware_estbbdate = @ware_actbbdate
		  end
		if datalength(@ware_actbbdate) >= 0
		  begin
			select @ware_actbbdate = @ware_estbbdate
		  end
	  end

/*notes keys */
select @ware_count = 0

	  SELECT @ware_count = count(*)
		    FROM note
		   WHERE note.notekey = @i_notekey 

	if @ware_count > 0 
	  begin
		SELECT @ware_notes = text	
  			  FROM note
   				WHERE note.notekey = @i_notekey 
	  end
	else
	  begin
		select @ware_notes = ''
	end
BEGIN tran
	INSERT into whprinting
		(bookkey, printingkey,printingnumber,printingstatus ,
		tentativeqty,approvedqty,approvedondate,bookbulk,
		requestbatchid,requeststatus,requestid,requestbyname,
		requestcomment,pceqty1,pceqty2,estboundbookdate,
		actualboundbookdate,printingnotes,impressionnumber,
		qtyreceived,printingcloseddate,jobnumberalpha, 
		boardtrimsizewidth, boardtrimsizelength,lastuserid,lastmaintdate)

	VALUES (@ware_bookkey, @i_printingkey,@i_printingnum,
		@ware_printingstatus_long,@i_tentativeqty,
		@i_approvedqty,@d_approvedondate,@i_bookbulk,@c_requestbatchid,
		@ware_requeststatus_long,@c_requestid,@c_requestbyname,
		@c_requestcomment,@i_pceqty1,@i_pceqty2,@ware_estbbdate,
		@ware_actbbdate,@ware_notes,@c_impressionnumber,
		@i_qtyreceived,@d_printingcloseddate,@c_jobnumberalpha,@c_boardtrimsizewidth,
		@c_boardtrimsizelength,'WARE_STORED_PROC',@ware_system_date)
commit tran
	/** need a success indicator
		if SQL%ROWCOUNT > 0 then
		commit
	**/
		exec datawarehouse_component @ware_bookkey,@i_printingkey,@i_tentativeqty,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprinting*/

		exec datawarehouse_cce @ware_bookkey,@i_printingkey,@i_tentativeqty,
		@c_ccestatus,@d_dateccefinalized,@ware_illuspapchgcode,@ware_textpapchgcode,
		@ware_logkey,@ware_warehousekey,@ware_system_date /* whfinalcostest*/

/* bindingspecs*/

		select @ware_count = 0
		select @ware_cartonqty  = 0
		select @ware_prepackind = 'N'

		SELECT  @ware_count = count(*) 
				from bindingspecs
					where bookkey= @ware_bookkey
						and printingkey= @i_printingkey
		if @ware_count > 0 
		  begin
			SELECT  @ware_cartonqty = cartonqty1,@ware_prepackind =prepackind
					from bindingspecs
						where bookkey= @ware_bookkey
						and printingkey= @i_printingkey
		  end
		if @ware_prepackind is null 
		  begin
			select @ware_prepackind = 'N'
		  end
BEGIN tran
		update whprinting
			set cartonqty = @ware_cartonqty,
			  prepackind = @ware_prepackind
				where bookkey= @ware_bookkey
				and printingkey= @i_printingkey
commit tran
/* materialspecs*/
		exec datawarehouse_materialspecs @ware_bookkey,@i_printingkey,@ware_logkey,@ware_warehousekey,@ware_system_date  /*whprinting*/

/* bookprice overrides */
		exec datawarehouse_bookprice_prtg @ware_bookkey,@i_printingkey,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprinting*/

/*printingdates*/
		exec datawarehouse_printdates @ware_bookkey,@i_printingkey,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/

/*printingdates2 */
		exec datawarehouse_printdates2 @ware_bookkey,@i_printingkey,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates2*/

/*schedules 1 to 20*/

         IF @v_webscheduling = 0
         BEGIN
			exec datawarehouse_schedule @ware_bookkey,@i_printingkey,1,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
			exec datawarehouse_schedule @ware_bookkey,@i_printingkey,2,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             exec datawarehouse_schedule @ware_bookkey,@i_printingkey,3,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             exec datawarehouse_schedule @ware_bookkey,@i_printingkey,4,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
			exec datawarehouse_schedule @ware_bookkey,@i_printingkey,5,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        		exec datawarehouse_schedule @ware_bookkey,@i_printingkey,6,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
       		exec datawarehouse_schedule @ware_bookkey,@i_printingkey,7,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
         	exec datawarehouse_schedule @ware_bookkey,@i_printingkey,8,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        		exec datawarehouse_schedule @ware_bookkey,@i_printingkey,9,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
         	exec datawarehouse_schedule @ware_bookkey,@i_printingkey,10,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        		exec datawarehouse_schedule @ware_bookkey,@i_printingkey,11,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        		exec datawarehouse_schedule @ware_bookkey,@i_printingkey,12,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        		exec datawarehouse_schedule @ware_bookkey,@i_printingkey,13,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             	exec datawarehouse_schedule @ware_bookkey,@i_printingkey,14,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
          	exec datawarehouse_schedule @ware_bookkey,@i_printingkey,15,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
         	exec datawarehouse_schedule @ware_bookkey,@i_printingkey,16,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             	exec datawarehouse_schedule @ware_bookkey,@i_printingkey,17,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        	  	exec datawarehouse_schedule @ware_bookkey,@i_printingkey,18,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             	exec datawarehouse_schedule @ware_bookkey,@i_printingkey,19,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             exec datawarehouse_schedule @ware_bookkey,@i_printingkey,20,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
		    exec datawarehouse_schedule @ware_bookkey,@i_printingkey,21,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
			exec datawarehouse_schedule @ware_bookkey,@i_printingkey,22,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
         END

          IF @v_webscheduling = 1
          BEGIN
          	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,1,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
			exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,2,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
	    		exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,3,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,4,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
          	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,5,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        		exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,6,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
       		exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,7,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
         	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,8,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        		exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,9,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        		exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,10,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
         	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,11,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
       		exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,12,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
         	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,13,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,14,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
          	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,15,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
        		exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,16,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,17,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
           	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,18,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
             	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,19,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
          	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,20,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
			exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,21,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
          	exec datawarehouse_webschedule @ware_bookkey,@i_printingkey,22,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/
         END
        /*	exec datawarehouse_schedule @ware_bookkey,@i_printingkey,21,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/

		exec datawarehouse_schedule @ware_bookkey,@i_printingkey,22,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprintingkeydates*/ */

		select @ware_count = 0
		select @ware_count = count(*)
				from  whfinalcostest
					where	bookkey = @ware_bookkey
						and printingkey=@i_printingkey
		if @ware_count = 0 
		  begin
BEGIN tran
			insert into whfinalcostest
			(bookkey,printingkey,chargecodekey,lastuserid,lastmaintdate)

			VALUES (@ware_bookkey,@i_printingkey,0,'WARE_STORED_PROC', @ware_system_date)
commit tran
		 end
		else
		  begin
			select @ware_totaleditioncost = sum(unitcost)
				from whfinalcostest
				where	costtype ='E' and bookkey = @ware_bookkey
					and printingkey=@i_printingkey  and unitcost>0 /* 7-9-03 added to remove null aggregate warnings*/
			
			select @ware_totalplantcost = sum(totalcost)
				from whfinalcostest
				where	costtype ='P' and bookkey = @ware_bookkey
					and printingkey=@i_printingkey  and totalcost >0 /*7-9-03 added to remove null aggregate warnings*/

			if  @i_tentativeqty = 0 
			  begin
				select @ware_totalunitcost = 0
			  end
			else
			  begin
				select @ware_totalunitcost = @ware_totaleditioncost + (@ware_totalplantcost/@i_tentativeqty)
			 end
	BEGIN tran
			update whprinting
				set totalplantcost =  @ware_totalplantcost,
				  totaleditioncost = @ware_totaleditioncost,
					unitcost = 	@ware_totalunitcost
					where bookkey= @ware_bookkey
					and printingkey= @i_printingkey
	commit tran
		  end
	/**
	else
	  begin
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	          errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
			'Unable to insert whprinting table - for printing',
			('Warning/data error bookkey '||to_char(@ware_bookkey) || ' and printingkey ' ||to_char(cursor_row.printingkey)),
			'Stored procedure datawarehouse_printing',
			'WARE_STORED_PROC', @ware_system_date)
		commit
	end if
 **/
  end	/*<>2*/

	FETCH NEXT FROM warehouseprinting
		INTO @i_printingkey,@i_tentativeqty,@i_notekey,@i_printingnum,@i_statuscode,@c_ccestatus,
	@d_dateccefinalized,@c_requestbatchid,@d_approvedondate,@i_requeststatuscode,@c_requestcomment,
	@c_requestid,@c_requestbyname,@d_requestdatetime,@i_approvedqty,@i_bookbulk,@i_pceqty1,@i_pceqty2,
	@c_impressionnumber,@i_qtyreceived,@d_printingcloseddate,@c_jobnumberalpha,@c_boardtrimsizewidth,
	@c_boardtrimsizelength

select @i_printstatus = @@FETCH_STATUS

end

close warehouseprinting
deallocate warehouseprinting

GO