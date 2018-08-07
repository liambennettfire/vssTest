PRINT 'STORED PROCEDURE : dbo.datawarehouse_whest_base'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_whest_base') and (type = 'P' or 
type = 'RF'))
begin
 drop proc dbo.datawarehouse_whest_base
end

GO

CREATE  proc dbo.datawarehouse_whest_base
@ware_estkey int,
@ware_company varchar,
@ware_logkey int,
@ware_warehousekey int,
@ware_system_date datetime

AS

DECLARE @ware_count int
DECLARE @i_estkey int
DECLARE @i_bookkey int
DECLARE @i_printingkey int
DECLARE @i_eststatus_pl int

DECLARE cur_whest_base_incr  INSENSITIVE CURSOR
	FOR
		SELECT ew.estkey,bookkey, printingkey
			    FROM estwhupdate ew, estbook e
				where ew.estkey=e.estkey and ew.estkey = @ware_estkey
					 ORDER BY ew.estkey
	FOR READ ONLY

	OPEN cur_whest_base_incr
 
		FETCH NEXT FROM cur_whest_base_incr 
			INTO @i_estkey,@i_bookkey,@i_printingkey

		select @i_eststatus_pl = @@FETCH_STATUS



		if @i_eststatus_pl <> 0  /** NO rows**/
		  begin
			close cur_whest_base_incr
			deallocate cur_whest_base_incr
			RETURN
		  end

		while (@i_eststatus_pl <> -1 )
		   begin

			IF (@i_eststatus_pl <> -2)
			  begin
				select @ware_count = 0
BEGIN tran
				delete from whestfields1
				where estkey = @i_estkey

				delete from whestfields2
				where estkey = @i_estkey

				delete from whestfields3
				where estkey = @i_estkey

				delete from whestfields4
				where estkey = @i_estkey

				delete from whestfields5
				where estkey = @i_estkey

				delete from whestcostfields1
				where estkey = @i_estkey

				delete from whestcostfields2
				where estkey = @i_estkey

				delete from whestcostfields3
				where estkey = @i_estkey

				delete from whestcostfields4
				where estkey = @i_estkey

				delete from whestcostfields5
				where estkey = @i_estkey

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

				exec datawarehouse_whesttables @i_estkey,@i_bookkey,@i_printingkey,
				@ware_logkey,@ware_warehousekey,@ware_system_date /*whesttables*/

			 end /*<>2*/

			FETCH NEXT FROM cur_whest_base_incr 
			INTO @i_estkey,@i_bookkey,@i_printingkey

			select @i_eststatus_pl = @@FETCH_STATUS
		
		end
	

		close cur_whest_base_incr
		deallocate cur_whest_base_incr

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