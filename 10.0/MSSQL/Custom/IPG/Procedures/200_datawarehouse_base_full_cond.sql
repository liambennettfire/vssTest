PRINT 'STORED PROCEDURE : dbo.datawarehouse_base_full_cond'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_base_full_cond') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_base_full_cond
end

GO

CREATE  proc dbo.datawarehouse_base_full_cond 
AS 

DECLARE @err_msg char(100)
DECLARE @ware_count int
DECLARE @ware_total  int
DECLARE @ware_count2 int

DECLARE @ware_warehousekey int
DECLARE @ware_newhousekey int
DECLARE @ware_activeind int
DECLARE @ware_logkey int
DECLARE @ware_illuspapchgcode int
DECLARE @ware_textpapchgcode int
DECLARE @ware_lastbookkey  int
DECLARE @ware_system_date datetime
DECLARE @ware_company  varchar(20)

DECLARE @ware_lasttypeofbuild  varchar(30) 
DECLARE @ware_laststarttime  datetime
DECLARE @ware_lastendtime datetime
DECLARE @ware_lastrowsprocessed  int
DECLARE @ware_lasttotalrows int

DECLARE @i_bookkey int
DECLARE @i_printingkey int
DECLARE @i_warestatus int

DECLARE @ware_associationtypecode int
DECLARE @ware_associatedtitles_count int

 SELECT @ware_system_date  = getdate()

/* delete all errors older than 1 week*/
 DELETE FROM wherrorlog
   WHERE lastmaintdate <= (getdate() - 7)

SELECT @ware_logkey = count(*)
 FROM wherrorlog

if @ware_logkey > 0
  begin
	SELECT @ware_logkey = max(logkey)
	     FROM wherrorlog
  end
else
   begin
	select @ware_logkey = 1
  end
select @ware_warehousekey = max(warehousekey)
	from whhistoryinfo

if @ware_warehousekey is null
   begin
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
           errorseverity, errorfunction,lastuserid, lastmaintdate)
	   VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_newhousekey),
	   'Unable to access whhistoryinfo- select max(warehousekey)',
	  'Warning/data error','Stored procedure startup','WARE_STORED_PROC', @ware_system_date)
  end
if @ware_warehousekey = 0
  begin
	select @ware_newhousekey = 1
  	select @ware_logkey = @ware_logkey + 1
   end
else
  begin
	select  @ware_warehousekey = @ware_warehousekey + 1
	select @ware_newhousekey = @ware_warehousekey 

 	 SELECT  @ware_activeind = COUNT(*) 
	     FROM whhistoryinfo
     			where warehousekey = @ware_warehousekey 

	if @ware_activeind is null
	  begin
		select @ware_activeind = 0
	  end 
	  if @ware_activeind = 0
 	    begin
BEGIN tran
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
      	     errorseverity, errorfunction,lastuserid, lastmaintdate)
		   VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_newhousekey),
		   'Unable to access whhistoryinfo- select max(warehousekey)',
		  'Warning/data error','Stored procedure startup','WARE_STORED_PROC', @ware_system_date)
commit tran
	   end

	 IF @ware_activeind > 0  
	    begin
		select  @ware_activeind = 0
   		SELECT @ware_activeind = activerunind
		      FROM whhistoryinfo
			      where warehousekey = @ware_warehousekey 
		if @ware_activeind is null
	 	 begin
			select @ware_activeind = 0   
	 	 end
   		 if @ware_activeind = 1 
  		  begin
BEGIN tran
			INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
      	  		  errorseverity, errorfunction,lastuserid, lastmaintdate)
			 VALUES ( convert(varchar,@ware_logkey)  ,convert(varchar,@ware_newhousekey),
				'Status indicates that a Warehouse build already in progress BUT it will be overwritten',
				'Warning/data error','Stored procedure startup','WARE_STORED_PROC', @ware_system_date)
commit tran
 		end
	end
 end

/* insert row into whhistoryinfo for this build*/
BEGIN tran

insert into whhistoryinfo (warehousekey,starttime,endtime,
	typeofbuild,activerunind)
VALUES (@ware_newhousekey, getdate(),null,'FULL COND',1)
commit tran

 SELECT @ware_total = count(*)
	    FROM bookwhupdate

	select @ware_count= count(*)
			from defaults

if @ware_count <> 1 
  begin
BEGIN tran

	 INSERT INTO wherrorlog (logkey,warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_newhousekey),
		'Unable to access defaults table',
		'Warning/data error','Stored procedure startup','WARE_STORED_PROC', @ware_system_date)

commit tran 
 end
else
  begin
	 select @ware_illuspapchgcode = textpaperchgcode, @ware_textpapchgcode	 = illuspaperchgcode
	   from defaults

 	select ware_count  = 0
BEGIN tran
	truncate table whtitleinfo
	truncate table whauthor
	truncate table whtitleclass
	truncate table whtitledates
	truncate table whtitlefiles
	truncate table whtitlecomments
	truncate table whtitlepersonnel
	truncate table whtitleprevworks
	truncate table whcatalog
	truncate table whcatalogtitle
	truncate table whprinting
	truncate table whfinalcostest
	truncate table whest
	truncate table whestcost
	truncate table whschedule1
	truncate table whschedule2
	truncate table whschedule3
	truncate table whschedule4
	truncate table whschedule5
	truncate table whschedule6
	truncate table whschedule7
	truncate table whschedule8
	truncate table whschedule9
	truncate table whschedule10
	truncate table whprintingkeydates
	truncate table whtitlecustom
	truncate table whprintingkeydates2
	truncate table whtitlecomments2
	truncate table whtitlecomments3
	truncate table whauthorsalestrack
	truncate table whcompetitivetitles
	truncate table whcomparativetitles
	truncate table whschedule11
	truncate table whschedule12
	truncate table whschedule13
	truncate table whschedule14
	truncate table whschedule15
	truncate table whschedule16
	truncate table whschedule17
	truncate table whschedule18
	truncate table whschedule19
	truncate table whschedule20
	truncate table whschedule21
	truncate table whschedule22
	truncate table whtitlepositioning

commit tran

	DECLARE datawarehouse_base INSENSITIVE CURSOR
	  FOR

 		 SELECT bu.bookkey
   			 FROM bookwhupdate bu,book b
				WHERE bu.bookkey=b.bookkey
					and b.standardind <> 'Y'
   				ORDER BY  bu.bookkey DESC
	  FOR READ ONLY

		select @ware_count = 1
		OPEN datawarehouse_base

		FETCH NEXT FROM datawarehouse_base
 		 INTO @i_bookkey

			select @i_warestatus = @@FETCH_STATUS

	   IF @ware_activeind = 0 
 		 begin
   	
 			while (@i_warestatus<>-1 )
			   begin
				   IF (@i_warestatus<>-2)
					  begin

						-- merge and format custom fields into bookcomment 20005
			  			exec Merge_Custom_IPG @i_bookkey
			  			-- resume normal warehouse processing
			  			exec datawarehouse_author @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date
	  					exec datawarehouse_bookinfo @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitleinfo and whtitleclass*/
	 					exec datawarehouse_bisac @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitleclass*/
						exec datawarehouse_category @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitleclass*/
	 					exec datawarehouse_audience @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitleclass*/
						exec datawarehouse_orgentry @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date  /*whtitleclass*/
	  					exec datawarehouse_bookprice @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitleinfo*/
	  					exec datawarehouse_bookdates @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitledates*/
	  					exec datawarehouse_bookfiles @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitlefiles*/
	  					exec datawarehouse_bookrole @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date  /*whtitlepersonnel*/
	  					exec datawarehouse_bookcomment @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitlecomments*/
	  					exec datawarehouse_prevauth @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitleprevworks*/
	  					exec datawarehouse_printing @i_bookkey,@ware_illuspapchgcode,@ware_textpapchgcode,
	 					@ware_logkey,@ware_newhousekey,@ware_system_date /*whprinting*/

	  					exec datawarehouse_bookcustom @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date /*whtitlecustom*/
	  					exec datawarehouse_bookmisc @i_bookkey, 'WARE_STORED_PROC', @ware_system_date

						exec datawarehouse_bookqtybreakdown @i_bookkey, @ware_system_date
						exec datawarehouse_whtitlecatalog @i_bookkey, @ware_logkey,@ware_newhousekey, @ware_system_date
  
						select @ware_associatedtitles_count = 0
						
						  select @ware_associationtypecode = 3   /* whauthorsalestrack */
						  exec datawarehouse_titlepositioning @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date,@ware_associationtypecode
		
	 					 select @ware_associationtypecode = 1     /* whcompetitivetitles */
						  exec datawarehouse_titlepositioning @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date,@ware_associationtypecode
 
	 					 select @ware_associationtypecode = 2     /* whcomparativetitles */
						  exec datawarehouse_titlepositioning @i_bookkey,@ware_logkey,@ware_newhousekey,@ware_system_date,@ware_associationtypecode
						
						exec dw_whtitlepositioning @i_bookkey, @ware_logkey,@ware_newhousekey, @ware_system_date  /* whtitlepositioning */
 
						select @ware_lastbookkey = @i_bookkey
						select @ware_count2 = 0 
						select @ware_count2 = count(*)
     							from bookwhupdate
	    						  where bookkey = @i_bookkey
	  					if @ware_count2 > 0  
						 begin
							delete from bookwhupdate
								where bookkey = @i_bookkey
						  end
						select @ware_count  = @ware_count  + 1
					end  /*<>*/
				FETCH NEXT FROM datawarehouse_base 
					INTO @i_bookkey
 				select @i_warestatus = @@FETCH_STATUS
  			end  /*end while*/

/* Processing catalog*/
BEGIN tran
			 truncate table whcatalog
			 truncate table whcatalogtitle
commit tran	
			exec datawarehouse_catalog @ware_logkey,@ware_newhousekey,@ware_system_date /* whcatalog*/
			exec datawarehouse_catalogtitle @ware_logkey,@ware_newhousekey,@ware_system_date /*whcatalogtitle*/

/*Processing Estimates*/
			/*select @ware_company = upper(orgleveldesc)*/
			/*	from orglevel*/
			/*		where orglevelkey= 1*/
/*not sure exclude ss since inside Script account for SS */
			/*if @ware_company <> 'CONSUMER'*/  
 			/* begin*/
			/*	exec datawarehouse_estimate @ware_company,@ware_logkey,@ware_newhousekey,@ware_system_date*/  /*whest/whestcost*/
/******    3-8-04  runs  P and L full ******/
   			/*	exec datawarehouse_whest_base_full*/
			/*  end*/

	/* do only if build complete*/
BEGIN tran
			update whhistoryinfo
			set endtime = getdate(),
				activerunind = 0,
				totalrows =  @ware_total,
				rowsprocessed = @ware_count,
				lastuserid  ='WARE_STORED_PROC',
				lastmaintdate = @ware_system_date,
				lastbookkey =  @ware_lastbookkey
					where warehousekey=@ware_newhousekey
commit tran
		end /* activeind= 0*/
end  /*<>1*/

close datawarehouse_base
deallocate datawarehouse_base

/*
EXCEPTION
   when OTHERS then
	update whhistoryinfo
		set endtime = sysdate,
			activerunind = 0,
			totalrows =  ware_total,
			rowsprocessed = ware_count,
			lastuserid  ='WARE_STORED_PROC',
			lastmaintdate = ware_system_date,
			lastbookkey =  ware_lastbookkey
				where warehousekey=ware_newhousekey


 	INSERT INTO wherrorlog (logkey,warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(ware_logkey) ,to_char(ware_newhousekey),
		'Unable to access table',
		('build stop at bookkey ' || to_char(ware_lastbookkey)),'Stored procedure startup','WARE_STORED_PROC', ware_system_date)

*/

GO
