PRINT 'STORED PROCEDURE : dbo.datawarehouse_whest_base_full'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_whest_base_full') and (type = 'P' or 
type = 'RF'))
begin
 drop proc dbo.datawarehouse_whest_base_full
end

GO

CREATE  proc dbo.datawarehouse_whest_base_full

AS

DECLARE @ware_count int

DECLARE @ware_system_date datetime
DECLARE @i_estkey int
DECLARE @i_bookkey int
DECLARE @i_printingkey int
DECLARE @i_eststatus int
DECLARE @ware_logkey int
DECLARE @ware_warehousekey  int
DECLARE @ware_newhousekey int
DECLARE @wareest_total int
DECLARE @ware_count2 int
DECLARE @ware_count3 int
DECLARE @ware_lastestkey  int
DECLARE @ware_activeind tinyint
DECLARE @ware_total int
DECLARE @ware_company  varchar (20) 

select  @ware_system_date = getdate()

select @ware_logkey = count(*)
	from wherrorlog

if @ware_logkey > 0 
  begin
	select @ware_logkey = max(logkey)
		from wherrorlog
  end
else
  begin
	select	@ware_logkey = 1
  end

 select @ware_warehousekey = max(warehousekey)
	from whhistoryinfo

 if @ware_warehousekey is null 
  begin
	select @ware_warehousekey = 0
  end
if @ware_warehousekey = 0  
  begin
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_newhousekey),
		'Unable to access whtitlehistory - select max(warehousekey)',
	'Warning/data error','Stored procedure startup','WAREEST_STORED_PROC', @ware_system_date)

	select @ware_newhousekey = @ware_warehousekey + 1
  end
else
  begin
	select @ware_newhousekey = @ware_warehousekey + 1
	select @ware_logkey = @ware_logkey + 1

	SELECT @ware_activeind =activerunind
		FROM whhistoryinfo
			where warehousekey = @ware_warehousekey

	if @ware_activeind is null
	  begin
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
        	  errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES ( convert(varchar, @ware_logkey ) ,convert(varchar,@ware_newhousekey),
			'Unable to access whtitlehistory - select max(warehousekey)',
			'Warning/data error','Stored procedure startup','WAREEST_STORED_PROC',@ware_system_date);
	 end
	if @ware_activeind = 2 
	  begin
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
        		  errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES ( convert(varchar,@ware_logkey ) ,convert(varchar,@ware_newhousekey),
			'Status indicates that a Warehouse EST build already',
			'Warning/data error','Stored procedure startup','WAREEST_STORED_PROC', @ware_system_date)
	 end
end

if @ware_activeind <> 2  
  begin

BEGIN tran

/* insert row into whhistoryinfo for this build*/
	insert into whhistoryinfo (warehousekey,starttime,endtime,
		typeofbuild,activerunind)
	VALUES (@ware_newhousekey, getdate(),null,'FULL EST',2)

				delete from whestfields1
				delete from whestfields2
				delete from whestfields3
				delete from whestfields4
				delete from whestfields5
				delete from whestcostfields1
				delete from whestcostfields2
				delete from whestcostfields3
				delete from whestcostfields4
				delete from whestcostfields5
commit tran

	DECLARE cur_whest_base_full  INSENSITIVE CURSOR
	FOR
		SELECT estkey,bookkey, printingkey
			    FROM estbook 
				ORDER BY estkey
	FOR READ ONLY

	select @ware_count = 1

	OPEN cur_whest_base_full
 
		FETCH NEXT FROM cur_whest_base_full
			INTO @i_estkey,@i_bookkey,@i_printingkey

		select @i_eststatus = @@FETCH_STATUS

		if @i_eststatus  <> 0  /** NO rows**/
		  begin
			close cur_whest_base_full
			deallocate cur_whest_base_full
			update whhistoryinfo
			  set endtime = getdate(),
				activerunind = 0,
				totalrows =  0,
				rowsprocessed = 0,
				lastuserid  ='WAREEST_STORED_PROC',
				lastmaintdate = @ware_system_date,
				lastbookkey =  0
					where warehousekey=@ware_newhousekey
			RETURN
		  end
		while (@i_eststatus <>-1 )
		   begin

			IF (@i_eststatus<>-2)
			  begin
				select @ware_count = 0
Begin tran
				INSERT into whestfields1 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)

				INSERT into whestfields2 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)
	
				INSERT into whestfields3 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)
	
				INSERT into whestfields4 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)

				INSERT into whestfields5 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)

				INSERT into whestcostfields1 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)

				INSERT into whestcostfields2 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)

				INSERT into whestcostfields3 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)

				INSERT into whestcostfields4 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)

				INSERT into whestcostfields5 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
				VALUES (@i_estkey,0,@i_bookkey,@i_printingkey,'WAREEST_STORED_PROC',@ware_system_date)
commit tran

				exec datawarehouse_whesttables @i_estkey,@i_bookkey,@i_printingkey,0,0,
				/*@ware_logkey,@ware_newhousekey,*/ @ware_system_date /*whesttables*/

				select @wareest_total = @wareest_total  + 1
				select @ware_count3  = @ware_count3  + 1
				select @ware_lastestkey = @i_estkey
 		    end /*<>2*/

		FETCH NEXT FROM cur_whest_base_full
		INTO @i_estkey,@i_bookkey,@i_printingkey

		select @i_eststatus = @@FETCH_STATUS

		select @ware_count3  = @ware_count3  + 1
		select @ware_lastestkey = @i_estkey
	end
  end

/* do only if build complete*/
begin tran
	update whhistoryinfo
		set endtime = getdate(),
			activerunind = 0,
			totalrows =  @wareest_total,
			rowsprocessed = @ware_count3,
			lastuserid  ='WAREEST_STORED_PROC',
			lastmaintdate = @ware_system_date,
			lastbookkey =  @ware_lastestkey
				where warehousekey=@ware_newhousekey
commit tran

close cur_whest_base_full
deallocate cur_whest_base_full

/* CRM 01540 7-20-04*/
/* insert any rows not on whestfields1-5 that is on whprinting... use whprinting instead of whtitleinfo to match by printingkey*/
BEGIN tran

insert into whestfields1 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestfields1 w2 where  w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

insert into whestfields2 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestfields2 w2 where w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

insert into whestfields3 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestfields4 w2 where w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

insert into whestfields4 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestfields4 w2 where w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

insert into whestfields5 (estkey,estversion,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestfields5 w2 where  w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

/* insert any rows not on whestcostfields1-5 that is on whprinting... use whprinting instead of whtitleinfo to match by printingkey*/
insert into whestcostfields1 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestcostfields1 w2 where  w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

insert into whestcostfields2 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestcostfields2 w2 where  w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

insert into whestcostfields3 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestcostfields3 w2 where w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

insert into whestcostfields4 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestcostfields4 w2 where w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

insert into whestcostfields5 (estkey,estversionkey,bookkey,printingkey,lastuserid,lastmaintdate)
select 0,0, bookkey,printingkey, 'WAREEST_STORED_PROC',lastmaintdate from whprinting  w
where not exists (select bookkey from
whestcostfields5 w2 where  w.bookkey=w2.bookkey and w.printingkey=w2.printingkey )

commit tran

GO